-- Атомарная регистрация пользователя
CREATE OR REPLACE FUNCTION register_user(
    p_username VARCHAR(100),
    p_login VARCHAR(255),
    p_password VARCHAR(255),
    p_email VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100)
) RETURNS INTEGER AS $$
DECLARE
    v_user_id INTEGER;
BEGIN
    INSERT INTO users (username, authority) 
    VALUES (p_username, 'USER') 
    RETURNING user_id INTO v_user_id;
    
    INSERT INTO accounts (login, password, user_id) 
    VALUES (p_login, p_password, v_user_id);
    
    INSERT INTO user_profiles (user_id, email, first_name, last_name) 
    VALUES (v_user_id, p_email, p_first_name, p_last_name);
    
    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- Атомарное завершение генерации
CREATE OR REPLACE FUNCTION complete_generation(
    p_request_id INTEGER,
    p_image_id INTEGER,
    p_title VARCHAR(255) DEFAULT ''
) RETURNS INTEGER AS $$
DECLARE
    v_design_id INTEGER;
    v_user_id INTEGER;
    v_theme_id INTEGER;
    v_model_id INTEGER;
    v_prompt TEXT;
BEGIN
    SELECT user_id, theme_id, model_id, prompt 
    INTO v_user_id, v_theme_id, v_model_id, v_prompt
    FROM generation_requests 
    WHERE request_id = p_request_id;
    
    INSERT INTO designs (owner_id, title, original_prompt, theme_id, model_id, image_id, is_ai_generated, is_public)
    VALUES (v_user_id, p_title, v_prompt, v_theme_id, v_model_id, p_image_id, true, false)
    RETURNING design_id INTO v_design_id;
    
    UPDATE generation_requests 
    SET status = 'COMPLETED', result_design_id = v_design_id, completed_at = NOW()
    WHERE request_id = p_request_id;
    
    RETURN v_design_id;
END;
$$ LANGUAGE plpgsql;

-- Расчёт стоимости корзины
CREATE OR REPLACE FUNCTION calculate_cart_total(p_user_id INTEGER)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    v_total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(quantity * price), 0)
    INTO v_total
    FROM cart_items
    WHERE user_id = p_user_id;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Атомарное оформление заказа
CREATE OR REPLACE FUNCTION checkout_cart(
    p_user_id INTEGER,
    p_shipping_address_id INTEGER,
    p_shipping_cost DECIMAL(10,2) DEFAULT 0
) RETURNS INTEGER AS $$
DECLARE
    v_order_id INTEGER;
    v_total DECIMAL(10,2);
    v_cart_item RECORD;
    v_order_number VARCHAR(50);
BEGIN
    v_total := calculate_cart_total(p_user_id);
    
    IF v_total = 0 THEN
        RAISE EXCEPTION 'Cart is empty';
    END IF;
    
    v_order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                      LPAD(nextval('orders_order_id_seq')::TEXT, 6, '0');
    
    INSERT INTO orders (user_id, order_number, status, total_amount, shipping_address_id, shipping_cost)
    VALUES (p_user_id, v_order_number, 'PENDING', v_total + p_shipping_cost, p_shipping_address_id, p_shipping_cost)
    RETURNING order_id INTO v_order_id;
    
    FOR v_cart_item IN
        SELECT design_id, product_id, size, color, quantity, price, customization
        FROM cart_items
        WHERE user_id = p_user_id
    LOOP
        INSERT INTO order_items (order_id, design_id, product_id, size, color, quantity, unit_price, subtotal, customization)
        VALUES (v_order_id, v_cart_item.design_id, v_cart_item.product_id, v_cart_item.size, 
                v_cart_item.color, v_cart_item.quantity, v_cart_item.price, 
                v_cart_item.quantity * v_cart_item.price, v_cart_item.customization);
    END LOOP;
    
    DELETE FROM cart_items WHERE user_id = p_user_id;
    
    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- Проверка, является ли дизайн популярным
CREATE OR REPLACE FUNCTION is_popular_design(p_design_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_favorites_count INTEGER;
    v_orders_count INTEGER;
    v_favorites_threshold INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_favorites_count
    FROM user_favorites
    WHERE design_id = p_design_id;
    
    SELECT COUNT(*) INTO v_orders_count
    FROM order_items
    WHERE design_id = p_design_id;
    
    IF v_favorites_count >= 5 OR v_orders_count >= 3 THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Получение популярных дизайнов
CREATE OR REPLACE FUNCTION get_popular_designs(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    design_id INTEGER,
    title VARCHAR(255),
    favorites_count BIGINT,
    orders_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.design_id,
        d.title,
        COUNT(DISTINCT uf.favorite_id) as favorites_count,
        COUNT(DISTINCT oi.order_item_id) as orders_count
    FROM designs d
    LEFT JOIN user_favorites uf ON d.design_id = uf.design_id
    LEFT JOIN order_items oi ON d.design_id = oi.design_id
    WHERE d.is_public = true
    GROUP BY d.design_id, d.title
    ORDER BY (COUNT(DISTINCT uf.favorite_id) + COUNT(DISTINCT oi.order_item_id)) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
