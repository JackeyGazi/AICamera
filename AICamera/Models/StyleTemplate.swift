import Foundation

struct StyleTemplate: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let thumbnailName: String
    let category: StyleCategory
    
    enum StyleCategory: String, CaseIterable {
        case ink = "水墨中国风"
        case ancient = "古风头像"
        case chibi = "Q版萌趣头像"
        case anime = "日系动漫头像"
        case doll3D = "3D玩偶头像"
        case cyberpunk = "赛博朋克写真"
    }
}
