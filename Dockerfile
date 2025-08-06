FROM public.ecr.aws/docker/library/python:3.11-slim

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
    && rm -rf /var/lib/apt/lists/*;

# Set working directory
WORKDIR /app

# Copy application files
COPY api.py db.py requirements.txt zip_gen.bash ./
COPY services/ ./services/

# Set environment variables
ENV QMK_HOME='/app/qmk_firmware'
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/bootstrap
ENV RUST_LOG=info
ENV AWS_LWA_INVOKE_MODE=response_stream

RUN mkdir -p $QMK_HOME && chmod -R 755 $QMK_HOME && \
    mkdir -p /tmp/qmk_temp;

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install qmk;

RUN chmod +x zip_gen.bash;

RUN qmk setup -y;

RUN echo '#!/bin/bash\n\
if [ "$AWS_LAMBDA_FUNCTION_NAME" != "" ] && [ ! -d "/tmp/qmk_firmware" ]; then\n\
    echo "Lambda environment detected, copying QMK to /tmp..."\n\
    cp -r /opt/qmk_firmware /tmp/\n\
    export QMK_HOME="/tmp/qmk_firmware"\n\
fi\n\
exec "$@"' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh
ENV QMK_HOME='/tmp/qmk_firmware'

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python", "api.py"]
