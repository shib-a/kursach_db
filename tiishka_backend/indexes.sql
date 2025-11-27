CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

CREATE INDEX idx_generation_requests_user_id ON generation_requests(user_id);

CREATE INDEX idx_generation_requests_status ON generation_requests(status) 
    WHERE status IN ('PENDING', 'PROCESSING');

CREATE INDEX idx_designs_public ON designs(is_public) WHERE is_public = true;

CREATE INDEX idx_designs_owner_id ON designs(owner_id);

CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);

CREATE INDEX idx_orders_user_id ON orders(user_id);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);

CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);

CREATE INDEX idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);

-- GIN индекс для полнотекстового поиска дизайнов по названию
CREATE INDEX idx_designs_title_gin ON designs USING GIN(to_tsvector('russian', title));

-- GIN индекс для поиска по промпту
CREATE INDEX idx_designs_prompt_gin ON designs USING GIN(to_tsvector('russian', original_prompt)) 
    WHERE original_prompt IS NOT NULL;
