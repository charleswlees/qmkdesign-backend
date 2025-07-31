# Charlie Lees
# Test file for sending a ZIP file over the network via an API

import os
import json
from flask import Flask, request, send_file
from flask_cors import CORS
from services.cli import generate_firmware
from db import backup_check, healthcheck, get_layout, alter_layout, delete_layout

backup_present = False

app = Flask(__name__)

CORS(app)


@app.route("/healthcheck", methods=["GET"])
def api_healthcheck():
    global backup_present
    try:
        backup_present = backup_check(backup_present)
        output = healthcheck()
        if len(output) > 0:
            return "online", 200
        else:
            return "offline", 400
    except Exception as e:
        print(e)
        return ("Internal Server Error", 500)


# Firmware Endpoint
@app.route("/firmware/<path:keyboard_name>", methods=["PUT"])
def get_categories(keyboard_name):
    file_name = None
    global backup_present
    try:
        backup_present = backup_check(backup_present)
        # Handles Request Body
        custom_keymap = request.get_json()
        with open("custom_keymap.json", "w") as file:
            json.dump(custom_keymap, file, indent=4)

        file_name = generate_firmware(keyboard_name)
        return send_file(file_name), 200
    except Exception as e:
        print(e)
        return ("Internal Server Error", 500)
    finally:
        if file_name:
            os.remove(file_name)


# User Data Endpoints


@app.route("/savedata", methods=["GET"])
def get_savedata():
    global backup_present
    try:
        user_email = request.args.get("email")
        backup_present = backup_check(backup_present)
        output = get_layout(user_email)
        if user_email and len(output) > 0:
            return output, 200
        else:
            return "Error, Layout not found", 400
    except Exception as e:
        print(e)
        return ("Internal Server Error", 500)


@app.route("/savedata", methods=["PUT", "POST"])
def update_savedata():
    global backup_present
    try:
        backup_present = backup_check(backup_present)
        output = alter_layout(request.json)
        if len(output) > 0:
            return output, 200
        else:
            return "Error, Layout not found", 400
    except Exception as e:
        print(e)
        return ("Internal Server Error", 500)


@app.route("/savedata", methods=["DELETE"])
def delete_savedata():
    global backup_present
    try:
        user_email = request.args.get("email")
        backup_present = backup_check(backup_present)
        output = delete_layout(user_email)
        if user_email and len(output) > 0:
            return output, 200
        else:
            return "Error, Layout not found", 400
    except Exception as e:
        print(e)
        return ("Internal Server Error", 500)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)
