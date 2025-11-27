CREATE TABLE configurations (
    conf_id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE,
    change_date TIMESTAMP NOT NULL DEFAULT NOW(),
    config_property TEXT
);

CREATE TABLE config_properties (
    conf_prop_id SERIAL PRIMARY KEY,
    conf_id INTEGER NOT NULL UNIQUE,
    property_name VARCHAR(100) NOT NULL UNIQUE,
    property_value TEXT,
    FOREIGN KEY (conf_id) REFERENCES configurations(conf_id) ON DELETE CASCADE
);
