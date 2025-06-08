import Cocoa
import SwiftUI

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let process = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.dt.Xcode" }) else {
            print("Xcode is not running.")
            return
        }
        let view = MainView(
            image: process.icon,
            title: process.localizedName ?? "",
            selectedTextPublisher: selectedTextPublisher.eraseToAnyPublisher()
        )
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        self.view.addSubview(hostingController.view)

        self.view.window?.toolbarStyle = .automatic
    }
}
