import subprocess
import os

def generate_firmware(keyboard_name):
    # Ensure we're using the correct script path
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'zip_gen.bash')
    
    # Make sure the script is executable
    os.chmod(script_path, 0o755)
    
    # Run the script with explicit bash interpreter
    result = subprocess.run(
        ['bash', script_path, keyboard_name], 
        capture_output=True, 
        text=True,
        cwd='/tmp'  # Set working directory to /tmp
    )

    if result.returncode != 0:
        print(f"Script stdout: {result.stdout}")
        print(f"Script stderr: {result.stderr}")
        raise Exception(f'Firmware Generation Script Failed: {result.stderr}')

    # Find the generated firmware file
    firmware_file = subprocess.run(
        'ls /tmp/*_qmk_design.bin', 
        shell=True, 
        capture_output=True, 
        text=True
    )

    if firmware_file.returncode != 0:
        raise Exception(f'Could not find generated firmware: {firmware_file.stderr}')

    return firmware_file.stdout.strip()
