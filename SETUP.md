# Setup Guide: Portfolio Impact Bot

Follow these steps to set up your AI-powered portfolio analysis system.

## 📋 Prerequisites

-   **n8n instance:** (Self-hosted, Desktop, or Cloud).
-   **PostgreSQL Database:** A running instance where you can create schemas and tables.
-   **OpenAI API Key:** For the AI analysis stages.
-   **Telegram Bot:** Created via [BotFather](https://t.me/botfather).
-   **Google Cloud Project:** With Gmail API enabled for OAuth2 credentials.

---

## 1. Database Setup 🗄️

Choose **one** of the following methods:

### Method A: PostgreSQL (Standard)
1. **Core Data Schema:** Run `database/invest_core.sql`. This creates the `invest_core` schema and the `security` and `position` tables.
2. **Audit/Logging Schema:** Run `database/invest_audit.sql`. This creates the `invest_audit` schema and the `n8n_portfolio_impact_workflow_log` table.
3. **Populate Portfolio:**
   ```sql
   INSERT INTO invest_core.security (symbol, name) VALUES ('NVDA', 'NVIDIA');
   INSERT INTO invest_core.position (security_id, quantity, open_price) 
   VALUES ((SELECT id FROM invest_core.security WHERE symbol = 'NVDA'), 10, 120.50);
   ```

### Method B: n8n Data Tables (Lite)
1. In n8n, go to **Data Tables** in the left sidebar.
2. **Create Table: `Portfolio`**
   - Add columns: `symbol` (String), `name` (String).
   - Add your stocks directly to the table (e.g., symbol: `AAPL`, name: `Apple`).
3. **Create Table: `Workflow Logs`**
   - Add columns: `run_id` (String), `message_id` (String), `email_subject` (String), `triage_priority` (String), `analysis_model` (String), `actionable_item_count` (Number), `total_item_count` (Number), `has_error` (Boolean), `error_message` (String).
4. When you import the **Lite** workflows (`n8n/Portfolio Impact - Lite.json` and `n8n/Portfolio Impact - Weekly Review - Lite.json`), open the `Data Table` nodes and select these tables from the dropdown.

---

## 2. Gmail Configuration 📧

1.  **Create a Label:** In your Gmail, create a label (e.g., `Investments`).
2.  **Set up a Filter:** Create a filter to automatically apply this label to the financial newsletters or news emails you want to analyze.
3.  **Find the Label ID:** Click on the label in Gmail and look at the URL. The ID is the part at the end (e.g., `Label_123456789`). You will need this for the `.env` file.

---

3.  **n8n Workflow Import 🤖**

1.  Open your n8n instance.
2.  Click on **Workflows** > **Add Workflow** > **Import from File**.
3.  Select `n8n/Portfolio Impact.json` (or the Lite version).
4.  Also import `n8n/Portfolio Impact - Weekly Review.json` (or the Lite version).

---

## 4. Credentials Setup in n8n 🔑

You need to create the following credentials in n8n:

-   **Postgres:** Using the host, user, and password for your database.
-   **OpenAI API:** Using your OpenAI API key.
-   **Telegram API:** Using your Bot Token.
-   **Gmail OAuth2:** Using your Google Cloud Client ID and Secret.

Once created, ensure each node in the imported workflow is using the correct credential.

---

## 5. Environment Variables ⚙️

Create a `.env` file based on `.env.example` in your n8n environment (or set them in your container/OS).

| Variable | Description |
| :--- | :--- |
| `POSTGRES_...` | Your database connection details. |
| `DB_SCHEMA_CORE` | Usually `invest_core`. |
| `TELEGRAM_BOT_TOKEN` | Your bot's token. |
| `TELEGRAM_CHAT_ID` | Your personal Telegram Chat ID (use @userinfobot to find it). |
| `OPENAI_API_KEY` | Your OpenAI key. |
| `OPEN_AI_EXPENSIVE_MODEL` | Recommended: `gpt-4o`. |
| `OPEN_AI_CHEAP_MODEL` | Recommended: `gpt-4o-mini`. |
| `GMAIL_LABEL_ID` | The ID of the Gmail label to watch. |

---

## 6. Testing & Activation 🚀

1.  **Manual Test:** Click "Execute Workflow" in n8n. It will fetch any **unread** emails with the specified label.
2.  **Verify Telegram:** You should receive a formatted message in Telegram.
3.  **Verify Database:** Check the `invest_audit.n8n_portfolio_impact_workflow_log` table to see if the run was logged.
4.  **Activate:** Once tested, toggle the workflow to **Active**.

*Note: The main workflow uses a manual trigger in the provided JSON. You should replace this with a **Gmail Trigger** (for real-time) or a **Schedule Trigger** (to check periodically).*
