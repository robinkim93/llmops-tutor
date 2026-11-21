# 파이썬 3.12 설치 이미지
FROM python:3.12-slim-trixie

# aws lambda web adapter를 추가하여 lambda에서 활용 가능하도록
# 현재 설치한 fastapi는 웹 요청만 알아듣기 때문에 lambda 호출 뒤에 정상적으로 요청이 들어갈 수 있게 그 사이에 adapter를 설치
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:1.1.0 /lambda-adapter /opt/extensions/lambda-adapter

# uv 설치
COPY --from=ghcr.io/astral-sh/uv:0.12.12 /uv /uvx /bin/

# 이미지 내부 기본 폴더 정의
WORKDIR /app

# 패키지 목록 파일 2개만 /app으로 복사
COPY pyproject.toml uv.lock ./

# uv로 패키지를 설치함
# --locked : uv.lock과 pyproject.toml 파일이 다르면 멈춘다. 내 환경의 버전과 다른 파일이 설치되는 것을 방지
# --no-install-project : 내 프로젝트 코드는 설치 안함 (지금 시점에는 src 내부 프로젝트 코드가 이미지 내부에 없음)
RUN uv sync --locked --no-install-project


# pyproject.toml에 readme = "README.md" 옵션이 있어 해당 파일이 없으면 에러가 발생함. 내용이 없더라도 넣어줘야 함
COPY README.md ./

# 프로젝트 폴더 전체를 /app에 복사
COPY src ./src

# uv로 프로젝트 코드 설치
# 위의 RUN과 나눈 이유는, 패키지는 바뀌지 않고 코드만 바뀌었을 때 위에서 패키지 설치 내용에 변동이 없으면 그냥 지나침. 코드부터 또는 코드와 같이 설치하게 되면 매번 패키지를 새로 설치해야 함
RUN uv sync --locked

# Lambda Web Adapter는 기본적으로 8080포트로 요청을 넘기기 때문에 8000포트를 명시해줘야 함
ENV AWS_LWA_PORT=8000

EXPOSE 8000

# Lambda
ENV PATH="/app/.venv/bin:$PATH"
CMD ["fastapi", "run", "src/llmops_tutor/main.py", "--port", "8000"]