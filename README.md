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

## Running the API

Make sure your `.env` file is set up and both MySQL and MongoDB are running, then:

```bash
uvicorn api.main:app --reload
```

The API will be available at `http://127.0.0.1:8000`

Interactive docs (Swagger UI) are at `http://127.0.0.1:8000/docs`

### Available endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | /sql/snapshots | Get latest 500 hourly snapshots from MySQL |
| GET | /sql/latest | Get most recent MySQL record |
| GET | /sql/range?start=&end= | Get MySQL records by date range |
| POST | /sql/snapshot | Create a new snapshot in MySQL |
| PUT | /sql/snapshot/{id} | Update a MySQL snapshot by ID |
| DELETE | /sql/snapshot/{id} | Delete a MySQL snapshot by ID |
| GET | /mongo/records | Get latest 500 records from MongoDB |
| GET | /mongo/latest | Get most recent MongoDB record |
| GET | /mongo/range?start=&end= | Get MongoDB records by date range |
| POST | /mongo/record | Create a new MongoDB record |
| PUT | /mongo/record/{id} | Update a MongoDB record by ObjectId |
| DELETE | /mongo/record/{id} | Delete a MongoDB record by ObjectId |

---

## Running the Prediction Script

The prediction script fetches live data from the API, preprocesses it, loads
the trained LSTM model, and forecasts the next hour's electricity price in €/MWh.

### Requirements
- The API must be running (see above)
- Trained model files must be present in the `models/` folder:
  - `model_lstm_deep.keras`
  - `scaler_minmax_X.pkl`
  - `scaler_minmax_y.pkl`
  - `feature_columns.json`

### Run
Open and run `scripts/Scripts.ipynb` in Jupyter or Google Colab.

The final cell will print:
```
Predicted electricity price: XX.XX €/MWh
```

---

## Notes
- The `.env` file is not tracked by git — create your own with your credentials
- The dataset is not tracked by git — download it from Kaggle directly
- All timestamps are stored in UTC
- Trained model files are not tracked by git — run `notebooks/Pipeline_formative.ipynb` first to generate them