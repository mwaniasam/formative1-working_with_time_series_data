# Energy Pipeline - Formative 1

This project analyses four years of hourly electricity data from Spain's 
national grid (2015–2018). We look at generation by source, demand, and 
market prices to understand patterns and build a forecasting model.

Dataset: ENTSO-E Hourly Energy Generation, Load and Price (Kaggle)

---

## Project Structure
```
├── data/                   # Dataset goes here (not tracked by git)
├── notebooks/              # EDA and modelling notebooks
├── database/
│   ├── sql/                # MySQL scripts
│   └── mongodb/            # MongoDB scripts
├── api/                    # API endpoints
├── models/                 # Trained model files
└── scripts/                # Prediction script
```

---

## Team Members

| Name | Role |
|---|---|
| Jok John Kur | EDA and Preprocessing |
| Samuel Mwania | Database Design (SQL + MongoDB) |
| Sharif Kiviiri | API Endpoints |
| Birasa Divine | Model Training and Prediction Script |

---

## Setup

### What You Need
- Python 3.x
- MySQL
- MongoDB
- pip packages (see below)

### 1. Clone the repo
```bash
git clone git@github.com:your-org/energy-pipeline.git
cd energy-pipeline
```

### 2. Install Python packages
```bash
pip install -r requirements.txt
```

### 3. Download the dataset
Go to Kaggle and download:
```
https://www.kaggle.com/datasets/nicholasjhana/energy-consumption-generation-prices-and-weather
```
Copy only `energy_dataset.csv` into the `data/` folder.

### 4. Set up MySQL
Log into MySQL and run:
```bash
sudo mysql -u root
```
```sql
CREATE DATABASE energy_db;
CREATE USER 'energy_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON energy_db.* TO 'energy_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Then run the schema and load scripts:
```bash
sudo mysql -u root energy_db < database/sql/schema.sql
sudo cp data/energy_dataset.csv /var/lib/mysql-files/
sudo mysql -u root energy_db < database/sql/load_data.sql
```

### 5. Create your .env file
```bash
nano .env
```
Add this:
```
MYSQL_USER=energy_user
MYSQL_PASSWORD=your_password
```

### 6. Load MongoDB
```bash
sudo systemctl start mongod
python3 database/mongodb/load_mongo.py
```

---

## Running the Queries

### MySQL
```bash
sudo mysql -u root energy_db < database/sql/queries.sql
```

### MongoDB
```bash
mongosh
use energy_db
load("database/mongodb/queries.js")
```

---
## Running the Prediction Script

The prediction script fetches live data from the API, preprocesses it, 
and uses the trained Ridge Regression model to forecast the next hour's 
electricity price.

### What You Need
- The API must be running (see below)
- Model files in the `models/` folder:
  - `model_ridge.pkl`
  - `scaler_standard.pkl`
  - `feature_columns.json`

### 1. Start the API
```bash
python -m uvicorn apis.main:app --reload
```

### 2. Open the prediction notebook
```bash
notebooks/Scripts.ipynb
```

### 3. Run all cells
The script will:
1. Fetch 500 records from `GET /mongo/records`
2. Flatten the nested JSON into a flat DataFrame
3. Apply feature engineering (lag features, moving averages, time features)
4. Scale features using StandardScaler
5. Load the Ridge Regression model and predict
6. Output the predicted electricity price in €/MWh

### Example Output
```
Predicted electricity price: 83.14 €/MWh
```

## Notes
- The `.env` file is not tracked by git — create your own with your credentials
- The dataset is not tracked by git — download it from Kaggle directly
- All timestamps are stored in UTC
