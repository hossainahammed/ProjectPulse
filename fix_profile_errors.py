lines_to_fix = [1337, 1400, 1719, 2019, 2166]
with open('lib/screens/profile_screen.dart', 'r') as f:
    lines = f.readlines()

for line_num in lines_to_fix:
    idx = line_num - 1
    # Example line: "    );\n"
    # We want to change it to "      ),\n    );\n"
    original_line = lines[idx]
    # Count leading spaces
    spaces = len(original_line) - len(original_line.lstrip())
    new_line = (" " * spaces) + "),\n" + original_line
    lines[idx] = new_line

with open('lib/screens/profile_screen.dart', 'w') as f:
    f.writelines(lines)
