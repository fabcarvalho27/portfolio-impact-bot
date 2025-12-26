# AI-Powered Portfolio Impact Bot 📊

[![Support this project](https://img.buymeacoffee.com/button-api/?text=Support%20this%20project&emoji=☕&slug=fabcarvalho&button_colour=FFDD00&font_colour=000000&font_family=Inter&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/fabcarvalho)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A sophisticated, event-driven system built on **n8n** that performs AI-powered analysis of financial news and assesses its specific impact on your investment portfolio.

The system fetches unread emails from Gmail, uses a multi-stage AI pipeline (OpenAI) to summarize and analyze content, logs results in PostgreSQL for telemetry, and delivers structured, actionable alerts via Telegram.

## 🚀 Key Features

- **Two-Stage AI Pipeline:**
  - **Stage 1 (Triage):** Uses a fast/cheap model to summarize noisy emails, extract articles, and prioritize them (High, Normal, Junk).
  - **Stage 2 (Analysis):** Uses a high-capability model for high-priority news to perform deep portfolio impact analysis.
- **Cost Optimization:** Dynamically selects the AI model based on the priority of the news, ensuring you only pay for "expensive" tokens when they matter most.
- **Robust State Management:** Designed with a "Context Object" pattern to ensure reliability and clean data flow without messy visual merges.
- **Defensive Programming:** Includes "Parser" and "Guard" nodes to safely handle and sanitize unpredictable AI outputs.
- **Telemetry & Analytics:** Logs every run to a PostgreSQL database, including model usage, performance, and actionable item counts.
- **Weekly Automated Reports:** A secondary workflow that analyzes your logs and sends a comprehensive performance and cost report via Telegram.

## 🛠 Tech Stack

- **n8n:** Workflow automation platform.
- **OpenAI:** GPT-4o and GPT-4o-mini for summarization and analysis.
- **PostgreSQL:** For storing portfolio data and workflow telemetry.
- **Telegram:** For real-time delivery of impact alerts and weekly reports.
- **Gmail:** Source for financial news and newsletters.

## 📐 Architecture

```mermaid
graph TD
    A[Gmail - Financial News] -->|Unread Emails| B(n8n Workflow)
    B --> C[Postgres: Load Portfolio Symbols]
    B --> D[AI Stage 1: Summarize & Triage]
    D --> E{Priority?}
    E -->|High| F[AI Stage 2: Deep Analysis - GPT-4o]
    E -->|Normal| G[AI Stage 2: Light Analysis - GPT-4o-mini]
    E -->|Junk| H[Skip Analysis]
    F --> I[Postgres: Log Telemetry]
    G --> I
    H --> I
    I --> J[Telegram: Impact Alert]
    
    K[Weekly Trigger] --> L(n8n Weekly Review)
    L --> M[Postgres: Query Logs]
    M --> N[Telegram: Performance Report]
```

## 📸 Screenshots

### Impact Alerts
| Detailed Analysis (High Priority) | FYI / Summary (Normal Priority) |
| :---: | :---: |
| ![Detailed Alert Placeholder](docs/screenshots/telegram_detailed.jpg) | ![FYI Alert Placeholder](docs/screenshots/telegram_fyi.jpg) |

### Weekly Analytics Report
![Weekly Report Placeholder](docs/screenshots/telegram_weekly_report.jpg)

## 🏁 Getting Started

Choose the version that best fits your infrastructure:

### Option A: Standard (Professional)
Uses **PostgreSQL** for data storage. Best for long-term tracking and external analytics dashboards.
*   **Workflow:** `n8n/Portfolio Impact.json`
*   **Database:** Requires running scripts in `/database`.

### Option B: Lite (Built-in)
Uses **n8n Data Tables** (built-in). Best for quick setup and low maintenance (no external database required).
*   **Workflows:** 
    - `n8n/Portfolio Impact - Lite.json`
    - `n8n/Portfolio Impact - Weekly Review - Lite.json`
*   **Database:** None. Just create two Data Tables (`Portfolio` and `Workflow Logs`) inside n8n.

Follow the detailed guide in [SETUP.md](./SETUP.md) for step-by-step instructions.

---

## ❤️ Support the Project

If you find this bot useful and want to support its ongoing development, you can buy me a coffee!

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://www.buymeacoffee.com/fabcarvalho)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
