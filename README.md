# 🧹 Keyboard Cleaner for macOS

A lightweight, native macOS utility written entirely in **Swift** that blocks all physical keyboard strokes (including media, volume, and brightness keys) so you can safely wipe down your keyboard without triggering accidental keystrokes. 

It requires zero external dependencies, compiles instantly using `swiftc`, and bundles into a clean macOS `.app` with a custom app icon.

---

## ✨ Features

* **Complete Key Blocking:** Intercepts `keyDown`, `keyUp`, and system-defined events (volume, brightness, and media keys).
* **Mouse/Trackpad Safe:** Your cursor and mouse clicks remain fully functional so you can interact with the app window or click buttons.
* **Safe Exit / Unlock:** Easily exit cleaning mode using **Command + Q** or by clicking the on-screen **Unlock** button.
* **Zero Dependencies:** Pure Swift, no CocoaPods, Swift Package Manager, or heavy frameworks required.
* **Custom App Icon:** Automatically generates a sleek, dark-mode keycap icon with glowing accents during the build process.

---

## 🛠️ Project Files

Ensure your project directory contains the following two files:
1. `keyboardClean.swift` (The source code)
2. `build.sh` (The build script that compiles and packages the app)

---

## 🚀 Getting Started & Building

### 1. Make the build script executable
Open Terminal in your project directory and run:
```bash
chmod +x build.sh

```

### 2. Run the build script

Execute the script to compile the Swift source, generate the app icon, and bundle everything into an `.app` file:

```bash
./build.sh

```

The finished application will be located at:

```text
build/keyboardClean.app

```

You can drag `keyboardClean.app` directly into your system `Applications` folder.

---

## 🔒 Required Permissions (Accessibility)

Because this app uses a global system event tap to protect your keyboard during cleaning, macOS requires **Accessibility Permissions** the first time you run it.

1. Launch **keyboardClean**.
2. If prompted that accessibility permissions are needed, open **System Settings**.
3. Navigate to **Privacy & Security** > **Accessibility**.
4. Toggle **keyboardClean** to **On**.

---

## 💡 Usage

1. Open **keyboardClean**. A minimalist window will appear stating that the keyboard is locked.
2. Clean your keyboard freely.
3. **To Unlock and Exit:**
* Press **Command + Q**, **OR**
* Click the **Unlock** button inside the window using your mouse/trackpad.
