CREATE TYPE AUTH_AUTHORITY AS ENUM ('ADMIN', 'USER', 'MODERATOR');
CREATE TYPE AUTH_SOCIAL_NETWORK_TYPE AS ENUM ('TELEGRAM', 'VK', 'GOOGLE', 'YANDEX');
CREATE TYPE AUTH_TOKEN_TYPE AS ENUM ('RESET_PASSWORD', 'CONFIRM_ACCOUNT', 'OTHER');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE,
    authority AUTH_AUTHORITY NOT NULL DEFAULT 'USER',
    registered_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    login VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE social_network_auths (
    sna_id SERIAL PRIMARY KEY,
    account_id INTEGER,
    social_network_type AUTH_SOCIAL_NETWORK_TYPE NOT NULL,
    auth_token VARCHAR(255) NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

CREATE TABLE confirm_tokens (
    ct_id SERIAL PRIMARY KEY,
    token_val VARCHAR(255) NOT NULL UNIQUE,
    till_date TIMESTAMP NOT NULL,
    token_type AUTH_TOKEN_TYPE NOT NULL,
    token_body TEXT
);

CREATE TABLE reset_password_requests (
    rpr_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    request_date TIMESTAMP NOT NULL DEFAULT NOW(),
    token_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (token_id) REFERENCES confirm_tokens(ct_id) ON DELETE CASCADE
);
