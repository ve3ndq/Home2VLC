import Foundation

struct Channel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: String
}
