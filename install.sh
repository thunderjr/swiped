#!/bin/bash
set -e

INSTALL_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.swiped.plist"

echo "Building swiped..."
swift build -c release

echo "Installing binary to $INSTALL_DIR..."
sudo cp .build/release/swiped "$INSTALL_DIR/"

echo "Installing framework to $LIB_DIR..."
sudo cp -R .build/arm64-apple-macosx/release/OpenMultitouchSupportXCF.framework "$LIB_DIR/"

echo "Relinking binary to find framework..."
sudo install_name_tool -change \
  @rpath/OpenMultitouchSupportXCF.framework/Versions/A/OpenMultitouchSupportXCF \
  "$LIB_DIR/OpenMultitouchSupportXCF.framework/Versions/A/OpenMultitouchSupportXCF" \
  "$INSTALL_DIR/swiped"

echo "Installing launch agent..."
mkdir -p "$LAUNCH_AGENT_DIR"
cat > "$LAUNCH_AGENT_DIR/$PLIST_NAME" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.swiped</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/swiped</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/swiped.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/swiped.log</string>
</dict>
</plist>
EOF

echo "Loading launch agent..."
# Unload if already loaded (ignore errors)
launchctl bootout gui/$(id -u)/com.swiped 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$LAUNCH_AGENT_DIR/$PLIST_NAME"

echo ""
echo "Installation complete!"
echo "  - Binary: $INSTALL_DIR/swiped"
echo "  - Framework: $LIB_DIR/OpenMultitouchSupportXCF.framework"
echo "  - Launch agent: $LAUNCH_AGENT_DIR/$PLIST_NAME"
echo "  - Logs: /tmp/swiped.log"
echo ""
echo "Configure gestures in ~/.config/swiped/config.toml"
