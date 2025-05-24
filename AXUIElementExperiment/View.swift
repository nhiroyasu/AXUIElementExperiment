import SwiftUI
import Combine

struct MainView: View {
    let image: NSImage?
    let title: String
    @State private var selectedText: String = ""

    @State private var currentElement: AXUIElement?

    let selectedTextPublisher: AnyPublisher<AXUIElement, Never>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
            } icon: {
                Image(nsImage: image ?? NSImage())
            }

            TextEditor(text: $selectedText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.body)

            Button {
                guard let element = currentElement else { return }
                let commentOutText = "/*\n" + selectedText + "\n*/"

                let commentOutAttribute: CFTypeRef = commentOutText as CFTypeRef
                if AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, commentOutAttribute) == .success {
                    print("Successfully commented out text.")
                } else {
                    print("Failed to comment out text.")
                }
            } label: {
                Text("Comment out")
            }

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(selectedTextPublisher) { element in
            currentElement = element

            var selectedTextAttribute: CFTypeRef?
            if AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedTextAttribute) == .success,
               let newText = selectedTextAttribute as? String {
                selectedText = newText
            }
        }
    }
}
