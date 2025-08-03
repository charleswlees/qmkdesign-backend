FROM python:3.11-slim

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
RUN mkdir -p $QMK_HOME && chmod -R 755 $QMK_HOME;
RUN mkdir -p /tmp/qmk_temp;

RUN pip install --no-cache-dir -r requirements.txt;
RUN pip install qmk;

RUN chmod +x zip_gen.bash;

RUN qmk setup -y;


ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "lambda-wrapper.handler" ]







