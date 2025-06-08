import SwiftUI

struct AXHierarchyView: View {
    @StateObject private var root: AXElementNode

    init() {
        let pid = NSWorkspace.shared.runningApplications
            .first(where: { $0.bundleIdentifier == "com.apple.dt.Xcode" })?
            .processIdentifier

        let rootElement = pid.map { AXUIElementCreateApplication($0) } ?? AXUIElementCreateSystemWide()
        _root = StateObject(wrappedValue: AXElementNode.buildTree(from: rootElement))
    }

    var body: some View {
        List {
            Text("XcodeのUI階層")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .center)
            OutlineGroup(root, children: \.children) { node in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(node.role).bold()
                        if node.isTappable {
                            Button(action: {
                                node.performTap()
                            }) {
                                Image(systemName: "hand.point.up.left")
                            }
                            .foregroundStyle(Color.primary)
                            .help("Perform Tap Action")
                        }
                    }
                    .font(.title2)

                    HStack {
                        if !node.displaySubtitle.isEmpty {
                            Text(node.displaySubtitle)
                                .foregroundStyle(.secondary)
                        }
                        if let count = node.children?.count, count > 0 {
                            Text("\(count) child\(count > 1 ? "ren" : "")")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.title2)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.sidebar)
    }
}
