from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    APP_TIMEZONE: str = "Asia/Seoul"

    class Config:
        env_file = ".env"


settings = Settings()
