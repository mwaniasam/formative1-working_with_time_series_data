# Energy Pipeline - Formative 1

Time-series analysis and forecasting pipeline using the ENTSO-E Hourly Energy Dataset.

## Project Structure
- `data/`         — Raw dataset (not tracked by git)
- `notebooks/`    — EDA and modelling notebooks
- `database/sql/` — MySQL schema, loading, and query scripts
- `database/mongodb/` — MongoDB collection design and queries
- `api/`          — CRUD API endpoints
- `models/`       — Trained model files
- `scripts/`      — End-to-end prediction script

## Setup
```bash
pip install -r requirements.txt
```

## Team Members
- Jok John Kur – EDA & Preprocessing
- Samuel Mwania – Database Design (SQL + MongoDB)
- Sharif Kiviiri – API Endpoints
- Birasa Divine – Model Training & Prediction Script
