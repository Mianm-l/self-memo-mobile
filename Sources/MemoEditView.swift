import SwiftUI
import SwiftData

struct MemoEditView: View {
    @Bindable var memo: Memo
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var contentFocused: Bool

    var body: some View {
        TextEditor(text: $memo.content)
            .focused($contentFocused)
            .padding(.horizontal, 12)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        modelContext.delete(memo)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .onAppear { contentFocused = true }
            .onChange(of: memo.content) { _, _ in memo.touch() }
    }
}
