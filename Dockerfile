FROM public.ecr.aws/docker/library/python:3.11-slim

# Copy Lambda Web Adapter from the official image
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 /lambda-adapter /opt/extensions/lambda-adapter

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    build-essential \
    gcc \
    bash \
    findutils \
    coreutils \
    wget \
    gcc-arm-none-eabi \
    dfu-util \
    dfu-programmer \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application files
COPY api.py db.py requirements.txt zip_gen.bash ./
COPY custom_keymap.json ./
COPY services/ ./services/

# Set environment variables
ENV QMK_HOME='/app/qmk_firmware'
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/bootstrap
ENV RUST_LOG=info
ENV AWS_LWA_INVOKE_MODE=response_stream

# Create necessary directories
RUN mkdir -p $QMK_HOME && chmod -R 755 $QMK_HOME && \
    mkdir -p /tmp/qmk_temp

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install qmk

# Make scripts executable
RUN chmod +x zip_gen.bash

# Setup QMK
RUN qmk setup -y

# The Lambda Web Adapter will look for a web app on port 8080 by default
# You can change this with AWS_LWA_PORT environment variable
EXPOSE 8080

# Start your web application
# Replace this with the actual command to start your web server
# For example, if using Flask:
# CMD ["python", "api.py"]
# For FastAPI with uvicorn:
# CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8080"]
# For a generic Python web server:
CMD ["python", "api.py"]
