CREATE TABLE image_datas(
    imgd_id SERIAL PRIMARY KEY,
    uuid CHAR(36) NOT NULL UNIQUE,
    uploader_id INTEGER,
    size INTEGER NOT NULL,
    FOREIGN KEY (uploader_id) REFERENCES users(user_id)
);
CREATE TABLE image_links(
    imgl_id SERIAL PRIMARY KEY,
    imgd_id INTEGER,
    FOREIGN KEY (imgd_id) REFERENCES image_datas(imgd_id)
);