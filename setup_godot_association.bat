@echo off
echo Setting up Godot file association...
assoc .godot=GodotProject
ftype GodotProject="C:\Users\MyBir\OneDrive\Documents\Game Dev\Godot\Godot_v4.7-stable_win64.exe" "%%1"
echo Done! .godot files will now open with Godot 4.7
pause
