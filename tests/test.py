#import pytest
import requests

URL = "http://api:8080/"
#URL = "http://localhost:8080/"

mock_layout = [
    [
        [
            {"value": "Q", "span": '1'},
            {"value": "W", "span": '1'},
            {"value": "E", "span": '1'},
            {"value": "R", "span": '1'},
        ],
        [
            {"value": "A", "span": '1'},
            {"value": "Shift", "span": '1'},
            {"value": "Meta", "span": '1'},
            {"value": "F", "span": '1'},
        ],
        [
            None,
            {"value": "Z", "span": '1'},
            {"value": "X", "span": '1'},
            {"value": "C", "span": '1'},
        ],
    ],
]

mock_email = "john@smith.co";
mock_name = "John Smith";
mock_path = "picturepath";
mock_keyboard = "zsh/planck_ez";
mock_output = {
  "keyboard_layout": mock_layout,
  "user_id": mock_email,
  "keyboard_name": mock_keyboard,
};

mock_profile = {
  "name": mock_name,
  "picture": mock_path,
  "email": mock_email,
};


#/healthcheck
## GET
def test_healthcheck_get():
    response = requests.get(f"{URL}/healthcheck")
    assert response.status_code == 200

#/savedata
##PUT
def test_savedata_post_invalid():
    response = requests.post(f"{URL}/savedata")
    assert response.status_code == 500

def test_savedata_post_valid():
    response = requests.post(f"{URL}/savedata", json=mock_output)
    assert response.status_code == 200
    assert response.json() == mock_output


## GET
def test_savedata_get_invalid():
    response = requests.get(f"{URL}/savedata")
    assert response.status_code == 400

def test_savedata_get_valid():
    response = requests.get(f"{URL}/savedata?email={mock_email}")
    assert response.status_code == 200
    assert response.json() == mock_output


##DELETE
def test_savedata_delete_valid():
    response = requests.delete(f'{URL}/savedata?email={mock_email}')
    assert response.status_code == 200
    assert response.json()["Attributes"] == mock_output

