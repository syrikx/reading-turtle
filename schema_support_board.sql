-- Customer Support Board Schema

-- Support posts table
CREATE TABLE IF NOT EXISTS support_posts (
    post_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open', -- open, answered, closed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_status CHECK (status IN ('open', 'answered', 'closed'))
);

-- Support post replies table (for developer responses)
CREATE TABLE IF NOT EXISTS support_replies (
    reply_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES support_posts(post_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE, -- true if reply is from admin/developer
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_support_posts_user_id ON support_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_support_posts_status ON support_posts(status);
CREATE INDEX IF NOT EXISTS idx_support_posts_created_at ON support_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_replies_post_id ON support_replies(post_id);
CREATE INDEX IF NOT EXISTS idx_support_replies_created_at ON support_replies(created_at);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_support_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_support_posts_updated_at
    BEFORE UPDATE ON support_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_support_posts_updated_at();

CREATE OR REPLACE FUNCTION update_support_replies_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_support_replies_updated_at
    BEFORE UPDATE ON support_replies
    FOR EACH ROW
    EXECUTE FUNCTION update_support_replies_updated_at();
