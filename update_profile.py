import re

file_path = "lib/screens/profile_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Make ProfileScreen responsive
content = re.sub(
    r"(\s*)body: GlassBackground\(\s*child: SafeArea\(\s*child: SingleChildScrollView\(",
    r"\1body: GlassBackground(\n\1  child: SafeArea(\n\1    child: WebContentWrapper(\n\1      maxWidth: 800,\n\1      child: SingleChildScrollView(",
    content
)

# For the main ProfileScreen, we want maxWidth: kWebPageMaxWidth
# Since it's the first one, we can replace the first occurrence of maxWidth: 800 with maxWidth: kWebPageMaxWidth
content = content.replace("maxWidth: 800,", "maxWidth: kWebPageMaxWidth,", 1)

# Now we need to add the closing parenthesis `),` for the WebContentWrapper.
# Notice that `SingleChildScrollView` closes around `      ),` -> `    ),` -> `  ),`
# Let's just fix it manually if it fails, but we can do:
# Wait, replacing closing parenthesis is hard with simple regex. Let's do it using regex to match the end of SingleChildScrollView.

# Another way is to just wrap the padding for NotificationSettingsScreen
content = re.sub(
    r"(\s*)body: GlassBackground\(\s*child: SafeArea\(\s*child: Padding\(",
    r"\1body: GlassBackground(\n\1  child: SafeArea(\n\1    child: WebContentWrapper(\n\1      maxWidth: 800,\n\1      child: Padding(",
    content
)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated profile screen starts.")
