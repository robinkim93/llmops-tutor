from fastapi import FastAPI
from pydantic import BaseModel

from .config import get_settings
from .llm import ask

app = FastAPI()

class QuestionBody(BaseModel):
    question: str
    token: str

@app.get("/")
async def root():
    return {"message": "Hello world"}

@app.get("/health")
async def health():
    return {"status": get_settings().ok_message}

@app.post("/ask")
async def get_ask(body: QuestionBody):
    message = await ask(question=body.question, token=body.token)
    return message


