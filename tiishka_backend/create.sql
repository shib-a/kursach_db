CREATE TYPE generation_status AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'DECLINED');
CREATE TYPE order_status AS ENUM ('PENDING', 'PAID', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED');
CREATE TYPE ticket_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');
CREATE TYPE ticket_category AS ENUM ('TECHNICAL', 'BILLING', 'ACCOUNT', 'OTHER');
CREATE TYPE ticket_status AS ENUM ('OPEN', 'IN_PROGRESS', 'WAITING_ON_USER', 'RESOLVED', 'CLOSED');

CREATE TABLE user_profiles
(
    up_id                 SERIAL PRIMARY KEY,
    user_id               INTEGER      NOT NULL UNIQUE,
    email                 VARCHAR(255) NOT NULL UNIQUE,
    birth_date            DATE,
    country_id            INTEGER,
    first_name            VARCHAR(255) NOT NULL,
    last_name             VARCHAR(255) NOT NULL,
    phone                 VARCHAR(20),
    generation_quota_used INTEGER CHECK (generation_quota_used >= 0),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

CREATE TABLE countries
(
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code VARCHAR(10)  NOT NULL UNIQUE,
    timezone     VARCHAR(50)  NOT NULL
);

CREATE TABLE ai_models
(
    model_id     SERIAL PRIMARY KEY,
    model_name   VARCHAR(100) NOT NULL UNIQUE,
    api_endpoint VARCHAR(255) NOT NULL UNIQUE,
    is_active    BOOLEAN      NOT NULL DEFAULT true
);

CREATE TABLE generation_themes
(
    theme_id              SERIAL PRIMARY KEY,
    theme_name            VARCHAR(100) NOT NULL,
    theme_prompt_template TEXT         NOT NULL,
    preview_image_id      INTEGER,
    is_active             BOOLEAN      NOT NULL DEFAULT true,
    created_by            INTEGER,
    created_at            TIMESTAMP    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (preview_image_id) REFERENCES image_datas (imgd_id),
    FOREIGN KEY (created_by) REFERENCES users (user_id)
);

CREATE TABLE designs
(
    design_id       SERIAL PRIMARY KEY,
    owner_id        INTEGER      NOT NULL,
    title           VARCHAR(255) NOT NULL DEFAULT '',
    original_prompt TEXT         NOT NULL,
    theme_id        INTEGER,
    model_id        INTEGER,
    image_id        INTEGER,
    is_ai_generated BOOLEAN      NOT NULL,
    is_public       BOOLEAN      NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    modified_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
    FOREIGN KEY (owner_id) REFERENCES users (user_id),
    FOREIGN KEY (theme_id) REFERENCES generation_themes (theme_id),
    FOREIGN KEY (model_id) REFERENCES ai_models (model_id),
    FOREIGN KEY (image_id) REFERENCES image_datas (imgd_id)
);

CREATE TABLE generation_requests
(
    request_id       SERIAL PRIMARY KEY,
    user_id          INTEGER           NOT NULL,
    model_id         INTEGER           NOT NULL,
    prompt           TEXT              NOT NULL,
    theme_id         INTEGER,
    status           generation_status NOT NULL DEFAULT 'PENDING',
    result_design_id INTEGER,
    parameters       TEXT              NOT NULL,
    requested_at     TIMESTAMP         NOT NULL DEFAULT NOW(),
    completed_at     TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (model_id) REFERENCES ai_models (model_id),
    FOREIGN KEY (theme_id) REFERENCES generation_themes (theme_id),
    FOREIGN KEY (result_design_id) REFERENCES designs (design_id)
);

CREATE TABLE user_favorites
(
    favorite_id SERIAL PRIMARY KEY,
    user_id     INTEGER   NOT NULL,
    design_id   INTEGER   NOT NULL,
    added_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (design_id) REFERENCES designs (design_id),
    UNIQUE (user_id, design_id)
);

CREATE TABLE products
(
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(100)   NOT NULL,
    base_price   DECIMAL(10, 2) NOT NULL CHECK (base_price >= 0),
    size         VARCHAR(20)    NOT NULL,
    color        VARCHAR(50)    NOT NULL,
    material     VARCHAR(100)   NOT NULL
);

CREATE TABLE cart_items
(
    cart_item_id  SERIAL PRIMARY KEY,
    user_id       INTEGER        NOT NULL,
    design_id     INTEGER        NOT NULL,
    product_id    INTEGER        NOT NULL,
    size          VARCHAR(20)    NOT NULL,
    color         VARCHAR(50)    NOT NULL,
    quantity      INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    added_at      TIMESTAMP      NOT NULL DEFAULT NOW(),
    customization TEXT,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (design_id) REFERENCES designs (design_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE shipping_addresses
(
    address_id     SERIAL PRIMARY KEY,
    user_id        INTEGER      NOT NULL,
    country_id     INTEGER      NOT NULL,
    city           VARCHAR(255) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    postal_code    VARCHAR(20)  NOT NULL,
    is_default     BOOLEAN      NOT NULL DEFAULT false,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

CREATE TABLE orders
(
    order_id            SERIAL PRIMARY KEY,
    user_id             INTEGER        NOT NULL,
    order_number        VARCHAR(50)    NOT NULL UNIQUE,
    status              order_status   NOT NULL DEFAULT 'PENDING',
    total_amount        DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id INTEGER        NOT NULL,
    shipping_cost       DECIMAL(10, 2) NOT NULL CHECK (shipping_cost >= 0),
    created_at          TIMESTAMP      NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (shipping_address_id) REFERENCES shipping_addresses (address_id)
);

CREATE TABLE order_items
(
    order_item_id SERIAL PRIMARY KEY,
    order_id      INTEGER        NOT NULL,
    design_id     INTEGER        NOT NULL,
    product_id    INTEGER        NOT NULL,
    size          VARCHAR(20)    NOT NULL,
    color         VARCHAR(50)    NOT NULL,
    quantity      INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10, 2) NOT NULL,
    subtotal      DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED ,
    customization TEXT,
    print_file_id INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders (order_id),
    FOREIGN KEY (design_id) REFERENCES designs (design_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id),
    FOREIGN KEY (print_file_id) REFERENCES image_datas (imgd_id)
);

CREATE TABLE support_tickets
(
    ticket_id             SERIAL PRIMARY KEY,
    user_id               INTEGER         NOT NULL,
    assigned_moderator_id INTEGER,
    ticket_number         VARCHAR(50)     NOT NULL UNIQUE,
    category              ticket_category NOT NULL,
    description           TEXT            NOT NULL,
    status                ticket_status   NOT NULL DEFAULT 'OPEN',
    priority              ticket_priority NOT NULL DEFAULT 'MEDIUM',
    created_at            TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMP       NOT NULL DEFAULT NOW(),
    closed_at             TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (assigned_moderator_id) REFERENCES users (user_id)
);

CREATE TABLE ticket_messages
(
    message_id          SERIAL PRIMARY KEY,
    ticket_id           INTEGER   NOT NULL,
    sender_id           INTEGER   NOT NULL,
    message_text        TEXT      NOT NULL,
    is_staff_response   BOOLEAN   NOT NULL DEFAULT false,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    attachment_image_id INTEGER,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets (ticket_id),
    FOREIGN KEY (sender_id) REFERENCES users (user_id),
    FOREIGN KEY (attachment_image_id) REFERENCES image_datas (imgd_id)
);

CREATE TABLE ticket_ratings
(
    rating_id    SERIAL PRIMARY KEY,
    ticket_id    INTEGER   NOT NULL,
    user_id      INTEGER   NOT NULL,
    rating_value INTEGER   NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (ticket_id) REFERENCES support_tickets (ticket_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    UNIQUE (ticket_id, user_id)
);
