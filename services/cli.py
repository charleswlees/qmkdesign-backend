import subprocess

def generate_firmware(keyboard_name):
    result = subprocess.run(f'./zip_gen.bash {keyboard_name}', shell=True, capture_output=True, text=True)

    if result.returncode != 0:
        raise Exception('Firmware Generation Script Failed')

    firmware_file = subprocess.run('ls /tmp/*_qmk_design.bin', shell=True, capture_output=True, text=True)

    return firmware_file.stdout.strip()

    
