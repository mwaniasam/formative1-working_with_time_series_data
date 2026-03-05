from fastapi import FastAPI
from .routes import mysql_routes, mongo_routes

app = FastAPI(title="Energy Time Series API")

# Include routers
app.include_router(mysql_routes.router)
app.include_router(mongo_routes.router)


@app.get("/")
def home():
    return {"message": "Energy Time Series API is running"}
