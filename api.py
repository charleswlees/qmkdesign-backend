# Charlie Lees
# Test file for sending a ZIP file over the network via an API

import os
import json
from flask import Flask, request, send_file
from flask_cors import CORS
from cli import generate_firmware


app = Flask(__name__)

CORS(app)

# Firmware Endpoint
@app.route("/firmware/<path:keyboard_name>", methods=["PUT"])
def get_categories(keyboard_name):
    file_name=None
    try:
        # Handles Request Body
        custom_keymap = request.get_json()
        with open('custom_keymap.json', 'w') as file:
            json.dump(custom_keymap, file, indent=4)

        file_name = generate_firmware(keyboard_name)
        return send_file(file_name), 200
    except:
        return("Internal Server Error", 500)
    finally:
        if(file_name):
            os.remove(file_name)

            






if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8080)

