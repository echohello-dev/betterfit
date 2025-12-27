# Fonts (BBH Hegarty)

Place the licensed BBH Hegarty font files here so headings and titles use the custom type.

Expected filenames (matching Info.plist UIAppFonts):
- BBHHegarty-Regular.ttf

Note: The upstream Google Fonts package currently provides BBH Hegarty Regular (400) only.

Notes:
- Ensure the internal font name matches one of the candidates in `Apps/iOS/BetterFitApp/AppTheme.swift`:
  - "BBH Hegarty", "BBHHegarty", "BBH-Hegarty", "BBHHegarty-Regular", "BBHHegarty-Bold"
- If your font’s PostScript name differs, share it and we’ll add it to the candidates.
- Respect licensing; do not commit fonts unless permitted.

Quick validation:
1. Drop the .ttf files into this folder.
2. Re-generate and build:
   ```bash
   mise run ios:open
   mise run ios:build:dev
   ```
3. In the app, any text using `.bfHeading(theme:size:relativeTo:)` should render in BBH Hegarty.
