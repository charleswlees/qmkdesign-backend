FROM python:3.11-slim

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 /lambda-adapter /opt/extensions/lambda-adapter

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

RUN pip install awslambdaric;

COPY api.py db.py requirements.txt zip_gen.bash lambda-wrapper.py ./
COPY custom_keymap.json ./
COPY services/ ./services/

ENV QMK_HOME='$HOME/qmk_firmware'
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/bootstrap
ENV RUST_LOG=info
ENV AWS_LWA_INVOKE_MODE=response_stream

RUN mkdir -p $QMK_HOME && chmod -R 755 $QMK_HOME;
RUN mkdir -p /tmp/qmk_temp;

RUN pip install --no-cache-dir -r requirements.txt;
RUN pip install qmk;

RUN chmod +x zip_gen.bash;

RUN qmk setup -y;

EXPOSE 8080
CMD ["python", "api.py"]






