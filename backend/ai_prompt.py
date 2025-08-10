import requests
import time
import json
import os
from functools import lru_cache
import hashlib

CACHE_FILE = os.path.expanduser("~/.terminal_assistant_cache.json")

def explain_command(command: str) -> str:
    prompt=f"What does the command '{command}' do? Provide a 2 lines explanation. \nExplanation:"

    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": "mistral",
                "prompt": prompt,
                "stream": False
            }
        )
        result= response.json()
        return result["response"].strip()
    
    except requests.RequestException as e:
        return f"Error explaining command: {str(e)}"
    
def complete_command(partial_command:str,model:str="mistral")->str:
    prompt=f"Complete the command: '{partial_command}'Only complete command. Dont give explanation \nCompletion:"
   
    try:
        response=requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": model,
                "prompt": prompt,
                "stream": False
            },
           
        )

        if response.status_code == 200:
            result = response.json()
            completion = result.get("response", "").strip()
           
            lines=completion.split("\n")
            return lines[0].strip()
        else:
            return partial_command
    except requests.RequestException as e:
        return f"Error completing command: {str(e)}"
    
def load_cache():
    try:
        with open(CACHE_FILE, 'r') as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}
    
def save_cache(cache):
    try:
      with open(CACHE_FILE, 'w') as f:
        json.dump(cache, f)
    except Exception:
         pass

def cached_complete_command(partial_command: str) -> str:

    cache = load_cache()
  
    if partial_command in cache:
        return cache[partial_command]
  
    completion = complete_command(partial_command)
    
  
    cache[partial_command] = completion
    save_cache(cache)
    
    return completion