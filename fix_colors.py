import os
import re

def fix_colors_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # Fix const TextStyle with non-const Colors.black.withOpacity(0.6)
        new_content = re.sub(
            r'const\s+TextStyle\s*\(\s*([^)]*?)\s*color:\s*Colors\.black\.withOpacity\(\s*0\.6\s*\)([^)]*)\)',
            r'TextStyle(\1color: Color(0x99000000)\2)',
            new_content
        )
        new_content = re.sub(
            r'const\s+TextStyle\s*\(\s*color:\s*Colors\.black\.withOpacity\(\s*0\.6\s*\)([^)]*)\)',
            r'TextStyle(color: Color(0x99000000)\1)',
            new_content
        )
        
        # Replace Colors.black.withOpacity(0.6)[xxx] or .shadeX
        new_content = re.sub(r'Colors\.black\.withOpacity\(\s*0\.6\s*\)\[\d+\]', 'Color(0x99000000)', new_content)
        new_content = re.sub(r'Colors\.black\.withOpacity\(\s*0\.6\s*\)\.shade\d+', 'Color(0x99000000)', new_content)
        
        # Replace remaining non-const Colors.black.withOpacity(0.6) in const contexts
        new_content = new_content.replace('color: Colors.black.withOpacity(0.6)', 'color: const Color(0x99000000)')
        
        # Replace Colors.black.shadeX
        new_content = re.sub(r'Colors\.black\.shade\d+', 'Colors.black12', new_content)

        # Replace const Color(...)54, etc.
        new_content = new_content.replace('const Color(0xFFf5c034)54', 'const Color(0x8AF5C034)')
        new_content = new_content.replace('const Color(0xFFf5c034)60', 'const Color(0x99F5C034)')
        new_content = new_content.replace('const Color(0xFFf5c034)70', 'const Color(0xB3F5C034)')

        # Colors.blackAccent -> Colors.black87
        new_content = new_content.replace('Colors.blackAccent', 'Colors.black87')

        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed colors in: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def walk_and_fix(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                fix_colors_in_file(file_path)

if __name__ == "__main__":
    app_dir = "/Users/punitnigam/Desktop/Maxryd/app/lib"
    walk_and_fix(app_dir)
