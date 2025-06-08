import SwiftUI
import Combine

struct MainView: View {
    let image: NSImage?
    let title: String

    let selectedTextPublisher: AnyPublisher<AXUIElement, Never>

    var body: some View {
        TabView {
            BindingView(image: image, title: title, selectedTextPublisher: selectedTextPublisher)
                .tabItem {
                    Label("Binding", systemImage: "doc.text")
                }

            AXHierarchyView()
                .tabItem {
                    Label("Hierarchy", systemImage: "list.bullet.rectangle")
                }

            KeyboardEventCaptureView()
                .tabItem {
                    Label("Keyboard", systemImage: "keyboard")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
