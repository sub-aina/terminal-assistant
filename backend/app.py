from fastapi import FastAPI,Query
from ai_prompt import explain_command,cached_complete_command,load_cache

app= FastAPI()

@app.get("/explain")
def explain(cmd: str=Query(...)):
    return {"explanation": explain_command(cmd)}


@app.get("/complete")
def complete(partial_command: str = Query(...)):

    if len(partial_command) < 1:
        return {"completion": "Command too short to complete"}
    
    completion = cached_complete_command(partial_command)
    was_cached= partial_command in load_cache()

    return {
        "completion": completion,
        "was_cached": was_cached,
        "original":partial_command
    }


@app.get("/health")
def health():
    return {"status": "ok", "service": "terminal-assistant"}