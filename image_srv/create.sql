CREATE TABLE image_datas (
    imgd_id SERIAL PRIMARY KEY,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    uploader_id INTEGER,
    size INTEGER NOT NULL,
    mime_type VARCHAR(50) NOT NULL,
    storage_path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (uploader_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE image_links (
    imgl_id SERIAL PRIMARY KEY,
    imgd_id INTEGER,
    url_path VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    access_token VARCHAR(255) NOT NULL,
    FOREIGN KEY (imgd_id) REFERENCES image_datas(imgd_id) ON DELETE CASCADE
);
