CREATE TABLE configurations (
    conf_id SERIAL PRIMARY KEY,
    key VARCHAR(512) NOT NULL UNIQUE,
    change_date TIMESTAMP NOT NULL,
    config_property TEXT NULL
);

CREATE TABLE config_properties (
    conf_prop_id SERIAL PRIMARY KEY,
    conf_id INTEGER NOT NULL,
    property_name VARCHAR(255) NOT NULL,
    property_value TEXT,
    FOREIGN KEY (conf_id) REFERENCES configurations(conf_id)
);