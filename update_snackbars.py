import os
import re

lib_dir = "lib"

def process_file(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    original_content = content

    # Add maxWidth: 400 to Get.snackbar( if not present
    # Using regex to find Get.snackbar( and replace it.
    if "Get.snackbar(" in content and "maxWidth:" not in content:
        content = content.replace("Get.snackbar(", "Get.snackbar(maxWidth: 500, margin: const EdgeInsets.all(16), ")

    # For Get.bottomSheet, wrap the first argument in Center + ConstrainedBox
    # This is trickier with regex, but we can try to find Get.bottomSheet(
    # Actually, let's just do it manually for Get.bottomSheet since there are only a few.
    
    if content != original_content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated snackbars in {path}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            process_file(os.path.join(root, file))
