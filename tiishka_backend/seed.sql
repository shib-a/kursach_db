INSERT INTO countries (country_name, country_code, timezone) VALUES
('Россия', 'RU', 'Europe/Moscow'),
('Беларусь', 'BY', 'Europe/Minsk'),
('Казахстан', 'KZ', 'Asia/Almaty');

INSERT INTO ai_models (model_name, api_endpoint, is_active) VALUES
('DALL-E 3', 'https://api.openai.com/v1/images/generations', true),
('Stable Diffusion XL', 'https://api.stability.ai/v1/generation', true);

INSERT INTO products (product_name, base_price, size, color, material) VALUES
('Футболка базовая', 1500.00, 'M', 'Белый', 'Хлопок 100%'),
('Футболка базовая', 1500.00, 'L', 'Черный', 'Хлопок 100%'),
('Худи', 3500.00, 'L', 'Серый', 'Хлопок/полиэстер'),
('Футболка премиум', 2500.00, 'M', 'Белый', 'Органический хлопок');

INSERT INTO users (username, authority) VALUES
('admin', 'ADMIN'),
('сергей_бессмертный_забрал_кофе', 'MODERATOR'),
('втшник_страдалец', 'USER');

INSERT INTO accounts (login, password, user_id) VALUES
('admin@tiishka.ru', '$2a$10$hashed', 1),
('s.bessmertny@itmo.ru', '$2a$10$hashed', 2),
('student@niuitmo.ru', '$2a$10$hashed', 3);

INSERT INTO user_profiles (user_id, email, first_name, last_name, country_id, generation_quota_used) VALUES
(1, 'admin@tiishka.ru', 'Админ', 'Системы', 1, 0),
(2, 's.bessmertny@itmo.ru', 'Сергей', 'Бессмертный', 1, 0),
(3, 'student@niuitmo.ru', 'Ваня', 'Курсач', 1, 9);

INSERT INTO generation_themes (theme_name, theme_prompt_template, is_active, created_by, created_at) VALUES
('Минимализм', 'minimalist design with {prompt}', true, 1, NOW()),
('ИС-style', 'design inspired by information systems with {prompt}', true, 2, NOW());

INSERT INTO image_datas (uuid, uploader_id, size, mime_type, storage_path, created_at) VALUES
('11111111-2222-3333-4444-555555555555', 3, 512000, 'image/png', '/uploads/is_love.png', NOW());

INSERT INTO designs (owner_id, title, original_prompt, theme_id, model_id, image_id, is_ai_generated, is_public, created_at, modified_at) VALUES
(3, 'ВТ ФЛУД', 'крутая резиновая желтая уточка', 2, 1, 1, true, true, NOW(), NOW());

INSERT INTO shipping_addresses (user_id, country_id, city, street_address, postal_code, is_default) VALUES
(3, 1, 'Санкт-Петербург', 'Кронверкский пр. 49', '197101', true);

INSERT INTO cart_items (user_id, design_id, product_id, size, color, quantity, added_at, price) VALUES
(3, 1, 3, 'L', 'Серый', 1, NOW(), 3500.00);

INSERT INTO support_tickets (user_id, assigned_moderator_id, ticket_number, category, description, status, priority, created_at) VALUES
(3, 2, 'TICKET-000001', 'TECHNICAL', 'Генерация зависла на PENDING уже 2 часа', 'IN_PROGRESS', 'HIGH', NOW());

INSERT INTO ticket_messages (ticket_id, sender_id, message_text, is_staff_response, created_at) VALUES
(1, 3, 'Генерация зависла на PENDING уже 2 часа, а мне курсач сдавать!', false, NOW()),
(1, 2, 'Проверьте подключение к API. Статус обновлён.', true, NOW());

INSERT INTO configurations (key, change_date, config_property) VALUES
('app.max_generation_time', NOW(), '120');
