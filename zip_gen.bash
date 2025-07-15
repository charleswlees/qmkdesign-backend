#!/bin/bash

# Set Default Value for firmware destination
QMK_HOME=${QMK_HOME:="$HOME/qmk_firmware"}

# Get Keyboard name from arguments
if [ $# -gt 0 ]
then
  KEYBOARD_NAME="$1" # Ex. zsa/planck_ez/glow
else
  exit 1 # Error if no keyboard name
fi

echo $KEYBOARD_NAME

# Remove any existing binaries/keymaps with our planned names
FILE_NAME="$QMK_HOME/keyboards/$KEYBOARD_NAME/keymaps/qmk_design"
OUTPUT_NAME=$HOME/qmk_firmware/*_qmk_design.bin

rm -r $FILE_NAME
rm $OUTPUT_NAME

qmk new-keymap -kb $KEYBOARD_NAME -km qmk_design

# Identify file type of existing keymap file
#Existing Keymap filename
EXISTING_KEYMAP=$(ls "$FILE_NAME"/*)

if [[ "$EXISTING_KEYMAP" == *.c ]]; then
    FILE_TYPE="c"
elif [[ "$EXISTING_KEYMAP" == *.json ]]; then
    FILE_TYPE="json"
    # Get Current layout name; Update keymap file
    LAYOUT_NAME=$(jq -r '.layout' "$FILE_NAME/keymap.json")
    jq --arg val "$LAYOUT_NAME" '.layout = $val' custom_keymap.json > temp.json && mv temp.json custom_keymap.json
else
    exit 1 # Error if neither json or C
fi

rm $FILE_NAME/*

# If C convert data from frontend to C
if [[ "$FILE_TYPE" == "c" ]]; then
  qmk json2c custom_keymap.json -o "$QMK_HOME/keyboards/$KEYBOARD_NAME/keymaps/qmk_design/keymap.c"
else
  cp custom_keymap.json "$QMK_HOME/keyboards/$KEYBOARD_NAME/keymaps/qmk_design/keymap.json"
fi

qmk compile -kb $KEYBOARD_NAME -km qmk_design

cp $HOME/qmk_firmware/*_qmk_design.bin .
rm custom_keymap.json
