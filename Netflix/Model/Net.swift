import Foundation

struct Net: Identifiable, Decodable, Encodable, Hashable {
    let id: Int?
    let type : String
    let title: String
    let story: String
    let rating: Int
    let image_url: String
}
