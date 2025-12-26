-- Schema for Telemetry and Audit Logs
CREATE SCHEMA IF NOT EXISTS invest_audit;

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
