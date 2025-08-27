from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="RAG + Agent Service")

class QueryRequest(BaseModel):
    query: str

@app.post("/ask")
async def ask(req: QueryRequest):
    return {"answer": f"Placeholder response for: {req.query}"}
