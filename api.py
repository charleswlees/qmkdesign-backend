# Charlie Lees
# Test file for sending a ZIP file over the network via an API

from flask import Flask, request, send_file
from cli import generate_firmware


app = Flask(__name__)

# Firmware Endpoint
@app.route("/firmware/<path:keyboard_name>", methods=["GET"])
def get_categories(keyboard_name):
    try:
        return send_file(generate_firmware(keyboard_name)), 200
    except:
        return("Internal Server Error", 500)





if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8080)

