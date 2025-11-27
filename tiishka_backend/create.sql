CREATE TYPE generation_status AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'DECLINED');
CREATE TYPE order_status AS ENUM ('PENDING', 'PAID', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED');
CREATE TYPE ticket_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');
CREATE TYPE ticket_category AS ENUM ('TECHNICAL', 'BILLING', 'ACCOUNT', 'OTHER');
CREATE TYPE ticket_status AS ENUM ('OPEN', 'IN_PROGRESS', 'WAITING_ON_USER', 'RESOLVED', 'CLOSED', 'AUTO_CLOSED');

CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE,
    country_code VARCHAR(3) UNIQUE,
    timezone VARCHAR(50)
);

CREATE TABLE ai_models (
    model_id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL UNIQUE,
    api_endpoint VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL CHECK (base_price >= 0),
    size VARCHAR(20) NOT NULL,
    color VARCHAR(50) NOT NULL,
    material VARCHAR(100) NOT NULL
);

CREATE TABLE user_profiles (
    up_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    email VARCHAR(255) NOT NULL UNIQUE,
    birth_date DATE,
    country_id INTEGER,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    generation_quota_used INTEGER NOT NULL DEFAULT 0 CHECK (generation_quota_used >= 0),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE SET NULL
);

CREATE TABLE generation_themes (
    theme_id SERIAL PRIMARY KEY,
    theme_name VARCHAR(100) NOT NULL,
    theme_prompt_template TEXT NOT NULL,
    preview_image_id INTEGER,
    is_active BOOLEAN NOT NULL,
    created_by INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (preview_image_id) REFERENCES image_datas(imgd_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE designs (
    design_id SERIAL PRIMARY KEY,
    owner_id INTEGER,
    title VARCHAR(255) NOT NULL,
    original_prompt TEXT,
    theme_id INTEGER,
    model_id INTEGER,
    image_id INTEGER,
    is_ai_generated BOOLEAN NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (theme_id) REFERENCES generation_themes(theme_id) ON DELETE SET NULL,
    FOREIGN KEY (model_id) REFERENCES ai_models(model_id) ON DELETE SET NULL,
    FOREIGN KEY (image_id) REFERENCES image_datas(imgd_id) ON DELETE SET NULL
);

CREATE TABLE generation_requests (
    request_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    model_id INTEGER,
    prompt TEXT NOT NULL,
    theme_id INTEGER,
    status generation_status NOT NULL,
    result_design_id INTEGER,
    parameters TEXT NOT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES ai_models(model_id) ON DELETE RESTRICT,
    FOREIGN KEY (theme_id) REFERENCES generation_themes(theme_id) ON DELETE SET NULL,
    FOREIGN KEY (result_design_id) REFERENCES designs(design_id) ON DELETE SET NULL,
    CHECK (completed_at IS NULL OR completed_at >= requested_at)
);

CREATE TABLE user_favorites (
    favorite_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE,
    design_id INTEGER UNIQUE,
    added_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (design_id) REFERENCES designs(design_id) ON DELETE CASCADE
);

CREATE TABLE shipping_addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    country_id INTEGER,
    city VARCHAR(100) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    is_default BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE RESTRICT
);

CREATE TABLE cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    design_id INTEGER,
    product_id INTEGER,
    size VARCHAR(20) NOT NULL,
    color VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP NOT NULL DEFAULT NOW(),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    customization TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (design_id) REFERENCES designs(design_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    status order_status NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id INTEGER,
    shipping_cost DECIMAL(10, 2) NOT NULL CHECK (shipping_cost >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (shipping_address_id) REFERENCES shipping_addresses(address_id) ON DELETE RESTRICT
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    design_id INTEGER,
    product_id INTEGER,
    size VARCHAR(20) NOT NULL,
    color VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) NOT NULL,
    customization TEXT,
    print_file_id INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (design_id) REFERENCES designs(design_id) ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    FOREIGN KEY (print_file_id) REFERENCES image_datas(imgd_id) ON DELETE SET NULL
);

CREATE TABLE support_tickets (
    ticket_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    assigned_moderator_id INTEGER,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    category ticket_category NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL,
    priority ticket_priority NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    closed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_moderator_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (closed_at IS NULL OR closed_at >= created_at)
);

CREATE TABLE ticket_messages (
    message_id SERIAL PRIMARY KEY,
    ticket_id INTEGER,
    sender_id INTEGER,
    message_text TEXT NOT NULL,
    is_staff_response BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    attachment_image_id INTEGER,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (attachment_image_id) REFERENCES image_datas(imgd_id) ON DELETE SET NULL
);

CREATE TABLE ticket_ratings (
    rating_id SERIAL PRIMARY KEY,
    ticket_id INTEGER UNIQUE,
    user_id INTEGER UNIQUE,
    rating_value INTEGER CHECK (rating_value BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
