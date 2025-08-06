#!/bin/bash

cp -r /app/qmk_firmware /tmp/
export QMK_HOME="/tmp/qmk_firmware"

cd /tmp

exec "$@"
