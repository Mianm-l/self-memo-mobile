import SwiftUI
import SwiftData

struct MemoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Memo.updatedAt, order: .reverse)
    private var memos: [Memo]

    @State private var searchText = ""
    @State private var path: [Memo] = []

    private var filteredMemos: [Memo] {
        guard !searchText.isEmpty else { return memos }
        return memos.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if memos.isEmpty {
                    ContentUnavailableView(
                        "还没有备忘",
                        systemImage: "note.text",
                        description: Text("点右上角 ✎ 写下第一条")
                    )
                } else if filteredMemos.isEmpty {
                    ContentUnavailableView.search
                } else {
                    memoList
                }
            }
            .navigationTitle("随手备忘")
            .searchable(text: $searchText, prompt: "搜索内容")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let memo = Memo()
                        modelContext.insert(memo)
                        path.append(memo)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationDestination(for: Memo.self) { memo in
                MemoEditView(memo: memo)
            }
        }
    }

    private var memoList: some View {
        List {
            ForEach(filteredMemos) { memo in
                NavigationLink(value: memo) {
                    MemoRow(memo: memo)
                }
            }
            .onDelete { offsets in
                offsets.map { filteredMemos[$0] }.forEach(modelContext.delete)
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct MemoRow: View {
    let memo: Memo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(memo.preview)
                .font(.body)
                .lineLimit(1)
            Text(memo.updatedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
