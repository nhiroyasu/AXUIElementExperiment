import Cocoa

class AXElementNode: Identifiable, ObservableObject {
    let element: AXUIElement
    let role: String
    let title: String
    let description: String
    var children: [AXElementNode]? = []

    var displaySubtitle: String {
        if !title.isEmpty {
            return "“\(title)”"
        } else if !description.isEmpty {
            return "“\(description)”"
        } else {
            return ""
        }
    }

    var isTappable: Bool {
        var actionsRef: CFArray?
        if AXUIElementCopyActionNames(element, &actionsRef) == .success,
           let actions = actionsRef as? [String] {
            return actions.contains(kAXPressAction as String)
        }
        return false
    }

    init(
        element: AXUIElement,
        role: String,
        title: String,
        description: String
    ) {
        self.element = element
        self.role = role
        self.title = title
        self.description = description
    }

    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    static func buildTree(from element: AXUIElement, depth: Int = 0, maxDepth: Int = 5) -> AXElementNode {
        var role: CFTypeRef?
        var title: CFTypeRef?
        var description: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title)
        AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &description)

        let node = AXElementNode(
            element: element,
            role: role as? String ?? "Unknown",
            title: title as? String ?? "",
            description: description as? String ?? ""
        )

        guard depth < maxDepth else { return node }

        var childrenRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef) == .success,
           let children = childrenRef as? [AXUIElement] {
            node.children = children.map { buildTree(from: $0, depth: depth + 1, maxDepth: maxDepth) }
        }

        return node
    }

    func performTap() {
        let result = AXUIElementPerformAction(element, kAXPressAction as CFString)
        if result != .success {
            print("Tap failed: \(result.rawValue)")
        }
    }
}
