import SwiftUI
import Carbon

struct KeyboardEventCaptureView: View {
    @State private var capturedText = ""
    @StateObject private var viewModel = KeyboardEventCaptureViewModel()
    private var eventTap: CFMachPort?

    var body: some View {
        TextEditor(text: $viewModel.text)
            .padding()
            .font(.title2)
            .frame(minWidth: 400, minHeight: 400)
    }
}

class KeyboardEventCaptureViewModel: ObservableObject {
    @Published var text = ""

    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
            guard let characters = event.charactersIgnoringModifiers else { return }
            self.append(characters)
        }
    }

    func append(_ char: String) {
        DispatchQueue.main.async {
            self.text.append(char)
        }
    }
}
