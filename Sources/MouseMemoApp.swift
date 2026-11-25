import SwiftUI
import SwiftData

@main
struct MouseMemoApp: App {
    var body: some Scene {
        WindowGroup {
            MemoListView()
        }
        .modelContainer(for: Memo.self)
    }
}
