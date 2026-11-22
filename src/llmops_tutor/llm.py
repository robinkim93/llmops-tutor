from functools import lru_cache
from typing import Literal
import anthropic

from .config import get_settings

Role = Literal["tutor"]

@lru_cache
def get_client() -> anthropic.AsyncAnthropic:
    return anthropic.AsyncAnthropic(api_key=get_settings().claude_api_key)

def pick_model(role: Role) -> str :
    models = {"tutor": get_settings().claude_model_tutor}
    return models[role]


async def ask(question: str, token: str, role: Role = "tutor"):
    if token != get_settings().llm_call_password:
        return {
            "message": "get out"
        }
    model = pick_model(role)
    response = await get_client().messages.create(
        max_tokens=get_settings().claude_max_tokens,
        messages=[
            {
                "role": "user",
                "content": question
            }
        ],
        model=model,
    )       
    text = "".join(block.text for block in response.content if block.type == "text")

    return {
        "answer": text,
        "model": model,
        "role": role,
        "stop_reason": response.stop_reason,
        "input_tokens": response.usage.input_tokens,
        "output_tokens": response.usage.output_tokens
    }

