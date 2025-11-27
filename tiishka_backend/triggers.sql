-- Автообновление modified_at при изменении дизайна
CREATE OR REPLACE FUNCTION update_design_modified_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_design_modified_at
    BEFORE UPDATE ON designs
    FOR EACH ROW
    EXECUTE FUNCTION update_design_modified_at();

-- Автообновление updated_at и closed_at для тикетов
CREATE OR REPLACE FUNCTION update_ticket_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    IF NEW.status IN ('RESOLVED', 'CLOSED', 'AUTO_CLOSED') 
       AND (OLD.status IS NULL OR OLD.status NOT IN ('RESOLVED', 'CLOSED', 'AUTO_CLOSED')) THEN
        NEW.closed_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ticket_updated_at
    BEFORE UPDATE ON support_tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_ticket_updated_at();
