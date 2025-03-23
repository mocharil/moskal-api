# Use Python slim image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PORT=8080
ENV HOST=0.0.0.0
ENV TZ=Asia/Jakarta

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Create a non-root user and set up temp directory
RUN useradd -m myuser && \
    mkdir -p /app/temp && \
    chown -R myuser:myuser /app && \
    chmod -R 755 /app/temp

USER myuser

# Command to run the application
CMD exec uvicorn main:app --host ${HOST} --port ${PORT} --workers 1
