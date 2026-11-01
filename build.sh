#!/bin/bash

APP_NAME="keyboardClean"
SWIFT_FILE="keyboardClean.swift"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "🧹 Building $APP_NAME..."

# 1. Create clean build directories
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 2. Compile Swift source file with optimizations
echo "⚙️ Compiling Swift code..."
swiftc -O "$SWIFT_FILE" -o "$MACOS_DIR/$APP_NAME"
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed."
    exit 1
fi

# 3. Create Info.plist
echo "📝 Generating Info.plist..."
cat << EOF > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 4. Generate app icon using a robust native Swift script
echo "🎨 Designing app icon via Swift..."
ICONSET_DIR="build/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"

swift - "$ICONSET_DIR" << 'SWIFT_ICON_SCRIPT'
import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count > 1 else { exit(1) }
let iconsetDir = arguments[1]

let size: CGFloat = 512
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

// Background Rounded Square
let path = NSBezierPath(roundedRect: NSRect(x: 32, y: 32, width: 448, height: 448), xRadius: 100, yRadius: 100)
let gradient = NSGradient(starting: NSColor(calibratedRed: 0.12, green: 0.14, blue: 0.18, alpha: 1.0),
                         ending: NSColor(calibratedRed: 0.05, green: 0.06, blue: 0.08, alpha: 1.0))
gradient?.draw(in: path, angle: -90)

// Outer border glow
NSColor(calibratedRed: 0.3, green: 0.7, blue: 1.0, alpha: 0.3).set()
path.lineWidth = 4
path.stroke()

// Sparkles
func drawSparkle(x: CGFloat, y: CGFloat, scale: CGFloat) {
    NSColor(calibratedRed: 0.4, green: 0.85, blue: 1.0, alpha: 0.9).set()
    let sp = NSBezierPath()
    sp.move(to: NSPoint(x: x, y: y - 20 * scale))
    sp.curve(to: NSPoint(x: x, y: y + 20 * scale), controlPoint1: NSPoint(x: x, y: y - 5 * scale), controlPoint2: NSPoint(x: x, y: y + 5 * scale))
    sp.move(to: NSPoint(x: x - 20 * scale, y: y))
    sp.curve(to: NSPoint(x: x + 20 * scale, y: y), controlPoint1: NSPoint(x: x - 5 * scale, y: y), controlPoint2: NSPoint(x: x + 5 * scale, y: y))
    sp.fill()
}

drawSparkle(x: 360, y: 340, scale: 1.2)
drawSparkle(x: 140, y: 160, scale: 0.7)
drawSparkle(x: 380, y: 150, scale: 0.5)

// Central Keycap Icon symbol
let keyRect = NSRect(x: 146, y: 146, width: 220, height: 220)
let keyPath = NSBezierPath(roundedRect: keyRect, xRadius: 40, yRadius: 40)
NSColor(calibratedRed: 0.2, green: 0.23, blue: 0.3, alpha: 1.0).set()
keyPath.fill()

let innerRect = NSRect(x: 166, y: 176, width: 180, height: 160)
let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 30, yRadius: 30)
NSColor(calibratedRed: 0.15, green: 0.17, blue: 0.22, alpha: 1.0).set()
innerPath.fill()

// Lock text symbol
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 72, weight: .bold),
    .foregroundColor: NSColor(calibratedRed: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
]
let text = NSString(string: "🔒")
text.draw(at: NSPoint(x: 212, y: 220), withAttributes: attrs)

image.unlockFocus()

// Helper to export NSImage to PNG file
func savePng(from sourceImage: NSImage, targetSize: Int, filename: String) {
    let targetCGFloat = CGFloat(targetSize)
    let resized = NSImage(size: NSSize(width: targetCGFloat, height: targetCGFloat))
    resized.lockFocus()
    sourceImage.draw(in: NSRect(x: 0, y: 0, width: targetCGFloat, height: targetCGFloat),
                     from: NSRect(x: 0, y: 0, width: size, height: size),
                     operation: .copy, fraction: 1.0)
    resized.unlockFocus()
    
    if let tiffData = resized.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: filename))
    }
}

let sizes = [16, 32, 64, 128, 256, 512]
for s in sizes {
    savePng(from: image, targetSize: s, filename: "\(iconsetDir)/icon_\(s)x\(s).png")
    if s <= 256 {
        savePng(from: image, targetSize: s * 2, filename: "\(iconsetDir)/icon_\(s)x\(s)@2x.png")
    }
}
SWIFT_ICON_SCRIPT

# 5. Convert iconset to .icns and clean up temp files
if [ -d "$ICONSET_DIR" ]; then
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
    rm -rf "$ICONSET_DIR"
fi

# Force macOS Finder to update app icon cache
touch "$APP_BUNDLE"

echo "🎉 Build complete! App bundle is located at: $APP_BUNDLE"