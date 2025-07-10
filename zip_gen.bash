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

qmk compile -kb $KEYBOARD_NAME -km qmk_design

cp $HOME/qmk_firmware/*_qmk_design.bin .
