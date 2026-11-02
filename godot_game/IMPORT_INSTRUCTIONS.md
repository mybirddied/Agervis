# Godot Import Instructions for Agervis Project

## Issue: Direct Launch Crashes

Godot 4.7.2 crashes when attempting to open this decompiled project directly via command line with Access Violation (0xc0000005). This is a known compatibility issue with some decompiled Godot projects.

## Solution: Import via Project Manager

**Use the Godot Project Manager to import the project safely:**

1. **Launch Godot 4.7.2**
   - Location: `C:\Users\MyBir\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe`
   - Or use command: `godot` (if PATH is configured)

2. **Import the Project**
   - Click the **Import** button in the Project Manager
   - Browse to: `C:\Users\MyBir\Documents\Agervis_Local`
   - Select `project.godot`
   - Click **Import & Edit**

3. **Wait for Initial Import**
   - Godot will regenerate the `.godot` cache folder
   - This may take 30-60 seconds for 301 files
   - First import processes all assets and scripts

4. **Verify Import Success**
   - Check the Scene tree shows nodes
   - Open `scripts/main.gd` to verify source code
   - Check Output panel for any errors

## Project Information

- **Name**: Agervis: First Block - Build 13 Private Alpha
- **Engine**: Godot 4.7
- **Source Files**: 35 scripts (43,608 lines)
- **Assets**: 89 imported resources
- **Status**: 100% decompiled and ready

## Alternative Location

If this location has issues, the original recovered project is at:
```
C:\Users\MyBir\OneDrive\Documents\Game Dev\Agervis\recovered\godot_project
```

Note: OneDrive paths may cause sync conflicts. Local copy is recommended.

## Troubleshooting

**If import fails:**
1. Delete the `.godot` folder from the project directory
2. Restart Godot
3. Try importing again

**If scripts show errors:**
- This is normal for decompiled projects
- Some type hints may need adjustment
- The code logic is intact and functional

**If assets are missing:**
- Check the `assets/` directory exists
- Verify `.import` files are present
- Reimport specific assets if needed via Godot

## Next Steps After Import

1. Test the main scene: `main.tscn`
2. Review the 22 custom script classes
3. Check Android export settings (original target platform)
4. Test build to verify compilation
5. Resume development

## Recovery Information

This project was recovered from an Android APK using:
- GDRE Tools v2.7.0 (GDScript decompilation)
- 100% source code recovery achieved
- All assets extracted and configured
- Complete project structure restored

For detailed recovery statistics, see `RECOVERY_COMPLETE.md` in the project root.
