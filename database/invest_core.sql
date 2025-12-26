-- Schema for Core Investment Data
CREATE SCHEMA IF NOT EXISTS invest_core;

-- Table to store security information (Stocks, ETFs, etc.)
CREATE TABLE IF NOT EXISTS invest_core.security (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table to store portfolio positions
CREATE TABLE IF NOT EXISTS invest_core.position (
    id SERIAL PRIMARY KEY,
    security_id INTEGER NOT NULL REFERENCES invest_core.security(id),
    quantity DECIMAL NOT NULL,
    open_price DECIMAL NOT NULL,
    open_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    close_price DECIMAL,
    close_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster symbol lookups (used by the n8n workflow)
CREATE INDEX IF NOT EXISTS idx_security_symbol ON invest_core.security(symbol);
CREATE INDEX IF NOT EXISTS idx_position_close_time ON invest_core.position(close_time);
