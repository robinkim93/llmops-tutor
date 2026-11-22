from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    ok_message: str = "ok"
    claude_api_key: str = ""
    claude_model_tutor: str = "claude-sonnet-5-5"
    claude_max_tokens: int = 16000
    llm_call_password: str
    
    model_config = SettingsConfigDict(env_file=".env")

@lru_cache
def get_settings():
    return Settings()
    