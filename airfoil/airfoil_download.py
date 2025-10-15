import os
import requests

# Configuration
BASE_URL = "https://m-selig.ae.illinois.edu/ads/coord/"
NAMES_FILE = "source.txt"
OUTPUT_DIR = "airfoils_data"

# Create the output folder if it doesn't exist
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Read the list of names
with open(NAMES_FILE, "r") as f:
    names = [line.strip() for line in f if line.strip()]

# Download each file
for name in names:
    url = f"{BASE_URL}{name}.dat"
    filename = os.path.join(OUTPUT_DIR, f"{name}.dat")

    print(f"Downloading {url} ...")
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()  # raise error for bad status
        with open(filename, "wb") as f_out:
            f_out.write(response.content)
        print(f"✔ Saved as {filename}")
    except requests.RequestException as e:
        print(f"✖ Failed to download {url}: {e}")