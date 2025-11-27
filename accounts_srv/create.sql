CREATE TYPE AUTH_AUTHORITY AS ENUM ('ADMIN', 'USER', 'MODERATOR');
CREATE TYPE AUTH_SOCIAL_NETWORK_TYPE AS ENUM ('TELEGRAM', 'VK', 'GOOGLE', 'YANDEX');
CREATE TYPE AUTH_TOKEN_TYPE AS ENUM ('RESET_PASSWORD', 'CONFIRM_ACCOUNT', 'OTHER');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    authority AUTH_AUTHORITY NOT NULL ,
    registered_date TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    login VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    user_id INTEGER UNIQUE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE social_network_auths (
    sna_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    social_network_type AUTH_SOCIAL_NETWORK_TYPE NOT NULL,
    auth_token VARCHAR(1024) NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE confirm_tokens (
    ct_id SERIAL PRIMARY KEY,
    token_val VARCHAR(256) NOT NULL UNIQUE,
    till_date TIMESTAMP NOT NULL,
    token_type AUTH_TOKEN_TYPE NOT NULL,
    token_body TEXT
);

CREATE TABLE reset_password_requests (
    rpr_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT NOW(),
    token_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (token_id) REFERENCES confirm_tokens(ct_id)
);