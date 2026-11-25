import Foundation
import SwiftData

@Model
final class Memo {
    var content: String
    var createdAt: Date
    var updatedAt: Date

    init(content: String = "") {
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func touch() {
        updatedAt = Date()
    }

    /// 列表预览:取第一条非空行
    var preview: String {
        let firstLine = content.split(separator: "\n").first.map(String.init) ?? ""
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "(空)" : trimmed
    }
}
