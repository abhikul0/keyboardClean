import Cocoa
import ApplicationServices

class CleanerController: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        startEventTap()
    }
    
    func setupWindow() {
        let rect = NSRect(x: 0, y: 0, width: 320, height: 180)
        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        window.title = "Keyboard Cleaner"
        window.center()
        window.delegate = self
        
        let view = NSView(frame: rect)
        
        let label = NSTextField(frame: NSRect(x: 20, y: 80, width: 280, height: 60))
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        label.stringValue = "Keyboard is LOCKED for cleaning.\n\nTo unlock, press:\nCommand + Q"
        
        let quitButton = NSButton(frame: NSRect(x: 110, y: 25, width: 100, height: 35))
        quitButton.title = "Unlock"
        quitButton.target = self
        quitButton.action = #selector(unlockAndQuit)
        
        view.addSubview(label)
        view.addSubview(quitButton)
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func startEventTap() {
            // CGEventType.systemDefined has a raw value of 14 in CoreGraphics
            let eventMask = (1 << CGEventType.keyDown.rawValue) | 
                            (1 << CGEventType.keyUp.rawValue) | 
                            (1 << 14) // 14 represents system-defined events (media, volume, brightness)
            
            let callback: CGEventTapCallBack = { (proxy, type, event, refcon) in
                let nsEvent = NSEvent(cgEvent: event)
                let flags = nsEvent?.modifierFlags ?? []
                
                // Emergency Unlock combo: Command + Q (keyCode 12 is 'q')
                if type == .keyDown,
                   nsEvent?.keyCode == 12,
                   flags.contains(.command) {
                    DispatchQueue.main.async {
                        NSApp.terminate(nil)
                    }
                }
                
                // Return nil to completely block/swallow all intercepted keyboard and media events
                return nil
            }
            
            eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(eventMask),
                callback: callback,
                userInfo: nil
            )
            
            if let eventTap = eventTap {
                runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
                if let source = runLoopSource {
                    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
                    CGEvent.tapEnable(tap: eventTap, enable: true)
                }
            } else {
                print("Failed to create event tap. Make sure Accessibility permissions are granted.")
            }
        }

    
    @objc func unlockAndQuit() {
        NSApp.terminate(nil)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.terminate(nil)
        return true
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = CleanerController()
app.delegate = delegate
app.run()