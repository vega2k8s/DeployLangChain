# Python 3.12 slim 이미지 사용
FROM python:3.12-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 의존성 설치 (PDF 처리 및 컴파일을 위해 필요)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 환경변수 설정
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# pyproject.toml 복사 및 의존성 설치
COPY pyproject.toml ./

# pip로 의존성 직접 설치 (pyproject.toml의 dependencies 사용)
RUN pip install --no-cache-dir \
    "python-dotenv>=1.1.1,<2.0.0" \
    "langchain>=0.3.26,<0.4.0" \
    "langchain-openai>=0.3.25,<0.4.0" \
    "langchain-community>=0.3.26,<0.4.0" \
    "pypdf>=5.6.1,<6.0.0" \
    "gradio>=5.34.2,<6.0.0" \
    "gradio-pdf>=0.0.22,<0.0.23" \
    "faiss-cpu>=1.11.0,<2.0.0"

# 소스 코드 복사
COPY src/ ./src/

# 업로드된 PDF 파일을 저장할 디렉토리 생성
RUN mkdir -p /app/uploads

# Gradio가 사용하는 포트 노출
EXPOSE 7860

# 비root 사용자 생성 및 권한 설정
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

# 애플리케이션 실행 (모듈로 실행)
CMD ["python", "src/main.py"]