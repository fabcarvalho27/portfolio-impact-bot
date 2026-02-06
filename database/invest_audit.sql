-- Schema for Telemetry and Audit Logs
CREATE SCHEMA IF NOT EXISTS invest_audit;

-- ============================================================================
-- LEGACY TABLE (from v1 - kept for backwards compatibility)
-- ============================================================================

-- Table to log every workflow execution and AI analysis result
CREATE TABLE IF NOT EXISTS invest_audit.n8n_portfolio_impact_workflow_log (
    id SERIAL PRIMARY KEY,
    run_id VARCHAR(255) NOT NULL,
    message_id VARCHAR(255),
    email_subject VARCHAR(255),
    triage_priority VARCHAR(20),
    analysis_model VARCHAR(100),
    actionable_item_count INTEGER DEFAULT 0,
    total_item_count INTEGER DEFAULT 0,
    has_error BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster queries in the Weekly Review workflow
CREATE INDEX IF NOT EXISTS idx_workflow_log_logged_at ON invest_audit.n8n_portfolio_impact_workflow_log(logged_at);
CREATE INDEX IF NOT EXISTS idx_workflow_log_run_id ON invest_audit.n8n_portfolio_impact_workflow_log(run_id);

-- ============================================================================
-- V2 TABLES (Weekly Digest Architecture)
-- ============================================================================

-- Core table for collecting news throughout the week
-- Used by: Portfolio Impact - Collector workflow
-- Migration: database/migrations/001_news_collection.sql
CREATE TABLE IF NOT EXISTS invest_audit.news_collection (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Time bucketing for weekly queries (populated on INSERT)
    week_year INTEGER NOT NULL,
    week_number INTEGER NOT NULL,

    -- Source identification
    run_id VARCHAR(100) NOT NULL,
    source_type VARCHAR(20) NOT NULL,  -- 'gmail', 'form', 'webhook'
    email_subject TEXT,
    email_from TEXT,
    email_date TIMESTAMP WITH TIME ZONE,

    -- Triage output
    triage_priority VARCHAR(20) NOT NULL,  -- 'high', 'normal', 'junk'
    triage_confidence DECIMAL(3,2),
    triage_summary TEXT NOT NULL,

    -- Analysis output
    analysis_summary TEXT,
    analysis_actions JSONB DEFAULT '[]',
    symbols_impacted TEXT[] DEFAULT '{}',
    thesis_impacts JSONB DEFAULT '[]',
    triggers_hit TEXT[] DEFAULT '{}',

    -- Scoring
    max_relevance_score INTEGER,
    max_materiality_score INTEGER,
    max_urgency_score INTEGER,
    composite_score INTEGER,

    -- Alert tracking
    alert_sent BOOLEAN DEFAULT FALSE,
    alert_reason VARCHAR(50),  -- 'urgency_threshold', 'watchlist_symbol', null
    alert_sent_at TIMESTAMP WITH TIME ZONE,

    -- Weekly digest tracking
    included_in_digest BOOLEAN DEFAULT FALSE,
    digest_date DATE,

    -- Categorization (for pattern tracking)
    news_categories TEXT[] DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_news_collection_week
    ON invest_audit.news_collection(week_year, week_number);
CREATE INDEX IF NOT EXISTS idx_news_collection_symbols
    ON invest_audit.news_collection USING GIN(symbols_impacted);
CREATE INDEX IF NOT EXISTS idx_news_collection_pending_digest
    ON invest_audit.news_collection(included_in_digest)
    WHERE included_in_digest = FALSE;
CREATE INDEX IF NOT EXISTS idx_news_collection_created
    ON invest_audit.news_collection(created_at DESC);

COMMENT ON TABLE invest_audit.news_collection IS 'Stores all processed news for weekly digest analysis';
COMMENT ON COLUMN invest_audit.news_collection.alert_reason IS 'Why immediate alert was sent: urgency_threshold or watchlist_symbol';

-- Track recurring news patterns per symbol
-- Used by: Portfolio Impact - Weekly Digest workflow
-- Migration: database/migrations/002_pattern_history.sql
CREATE TABLE IF NOT EXISTS invest_audit.news_pattern_history (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    news_category VARCHAR(50) NOT NULL,

    -- Occurrence tracking
    occurrence_count INTEGER DEFAULT 1,
    first_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Impact tracking (avg calculated as: total / occurrence_count)
    total_composite_score INTEGER DEFAULT 0,

    -- Thesis impact tracking
    validates_count INTEGER DEFAULT 0,
    challenges_count INTEGER DEFAULT 0,
    neutral_count INTEGER DEFAULT 0,

    UNIQUE(symbol, news_category)
);

CREATE INDEX IF NOT EXISTS idx_pattern_history_symbol
    ON invest_audit.news_pattern_history(symbol);
CREATE INDEX IF NOT EXISTS idx_pattern_history_recent
    ON invest_audit.news_pattern_history(last_seen_at DESC);

COMMENT ON TABLE invest_audit.news_pattern_history IS 'Aggregated news patterns for trend analysis';

-- Track weekly digest runs
-- Used by: Portfolio Impact - Weekly Digest workflow
-- Migration: database/migrations/003_weekly_digest_log.sql
CREATE TABLE IF NOT EXISTS invest_audit.weekly_digest_log (
    id SERIAL PRIMARY KEY,
    run_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Coverage
    week_year INTEGER NOT NULL,
    week_number INTEGER NOT NULL,
    news_items_count INTEGER DEFAULT 0,
    symbols_covered TEXT[] DEFAULT '{}',

    -- AI output
    digest_summary TEXT,
    requires_attention JSONB DEFAULT '[]',
    monitor_list JSONB DEFAULT '[]',
    week_ahead_outlook TEXT,

    -- Delivery
    telegram_sent BOOLEAN DEFAULT FALSE,
    telegram_sent_at TIMESTAMP WITH TIME ZONE,

    -- Performance
    processing_time_ms INTEGER,
    ai_model_used VARCHAR(50),
    ai_tokens_used INTEGER,

    UNIQUE(week_year, week_number)
);

COMMENT ON TABLE invest_audit.weekly_digest_log IS 'Tracks each weekly digest generation';
