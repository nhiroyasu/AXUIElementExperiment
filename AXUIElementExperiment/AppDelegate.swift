import Cocoa
import Combine

let selectedTextPublisher = PassthroughSubject<AXUIElement, Never>()

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var timer: Timer?
    var source: CFRunLoopSource?

    var observer: AXObserver?



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let dict: [String: Any] = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]
        AXIsProcessTrustedWithOptions(dict as CFDictionary)

        guard let xcodePID = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.dt.Xcode" })?.processIdentifier else {
            return
        }
        let appElement = AXUIElementCreateApplication(xcodePID)

        AXObserverCreate(
            xcodePID,
            { observer, element, notification, refcon in
                var roleRef: CFTypeRef?
                var result = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
                if result == .success {
                    print("Focused Element Role: \(roleRef as! String)")
                }

                var selectedTextAttribute: CFTypeRef?
                result = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedTextAttribute)
                if result == .success {
                    print("Focused Element Selected Text: \(selectedTextAttribute as! String)")
                }

                var selectedTextRangeAttribute: CFTypeRef?
                result = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedTextRangeAttribute)
                if result == .success {
                    print("Focused Element Selected Text Range: \(selectedTextRangeAttribute)")
                }

                if selectedTextAttribute as? String != "" {
                    selectedTextPublisher.send(element)
                }
            },
            &observer
        )
        let notificationResult = AXObserverAddNotification(
            observer!,
            appElement,
            kAXSelectedTextChangedNotification as CFString,
            nil
        )
        if notificationResult != .success {
            print("Failed to add notification: \(notificationResult)")
        } else {
            print("Notification added successfully")
        }

        source = AXObserverGetRunLoopSource(observer!)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
