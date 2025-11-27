-- Очистка просроченных токенов подтверждения
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM confirm_tokens WHERE till_date < NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cleanup_expired_tokens
    AFTER INSERT ON confirm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION cleanup_expired_tokens();

