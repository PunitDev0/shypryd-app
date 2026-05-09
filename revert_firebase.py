import os

files_to_revert = [
    "/Users/punitnigam/Desktop/Maxryd/app/android/app/google-services.json",
    "/Users/punitnigam/Desktop/Maxryd/app/firebase.json",
    "/Users/punitnigam/Desktop/Maxryd/app/lib/firebase_options.dart",
]

for file_path in files_to_revert:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Revert changes made by the previous script
        new_content = content.replace('shipryd', 'maxryd')
        new_content = new_content.replace('ShipRyd', 'Maxryd')
        new_content = new_content.replace('SHIPRYD', 'MAXRYD')
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Reverted in: {file_path}")
    else:
        print(f"File not found: {file_path}")
