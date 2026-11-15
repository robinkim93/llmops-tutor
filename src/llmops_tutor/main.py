from functools import lru_cache
from fastapi import FastAPI

from .config import Settings

app = FastAPI()

@lru_cache
def get_settings():
    return Settings()

@app.get("/")
async def root():
    return {"message": "Hello world"}

@app.get("/health")
async def health():
    return {"status": get_settings().ok_message}


