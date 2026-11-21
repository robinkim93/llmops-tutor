from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    ok_message: str = "ok"
    model_config = SettingsConfigDict(env_file=".env")
    