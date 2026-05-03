import os
import re

def replace_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace variations of Maxryd
        variations = {
            'Maxryd': 'ShipRyd',
            'maxryd': 'shipryd',
            'MAXRYD': 'SHIPRYD',
            'MaxRyd': 'ShipRyd',
            'Max Ryd': 'Ship Ryd',
            'MAX RYD': 'SHIP RYD'
        }
        
        new_content = content
        for old, new in variations.items():
            new_content = new_content.replace(old, new)
        
        # Color replacements for "Only Yellow and Black"
        # Yellow: Color(0xFFf5c034) or Colors.yellow
        # Black: Colors.black
        
        color_replacements = {
            'Colors.white': 'const Color(0xFFf5c034)',
            'Colors.blue': 'Colors.black',
            'Colors.green': 'Colors.black',
            'Colors.red': 'Colors.black',
            'Colors.orange': 'Colors.black',
            'Colors.purple': 'Colors.black',
            'Colors.teal': 'Colors.black',
            'Colors.grey': 'Colors.black.withOpacity(0.6)',
            'Colors.black87': 'Colors.black',
            'Colors.black54': 'Colors.black',
            '0xFF4CAF50': '0xFF000000', # Green hex
            '0xFF2196F3': '0xFF000000', # Blue hex
        }
        
        for old, new in color_replacements.items():
            new_content = new_content.replace(old, new)
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def walk_and_replace(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.dart', '.yaml', '.xml', '.json', '.md', '.gradle')):
                file_path = os.path.join(root, file)
                replace_in_file(file_path)

if __name__ == "__main__":
    app_dir = "/Users/punitnigam/Desktop/Maxryd/app"
    walk_and_replace(app_dir)
