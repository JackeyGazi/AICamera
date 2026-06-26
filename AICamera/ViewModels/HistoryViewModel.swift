import Foundation
import UIKit
import Combine

final class HistoryViewModel: ObservableObject {
    @Published var historyItems: [GeneratedImage] = []
    @Published var isLoading: Bool = false

    private let fileManager = FileManager.default
    private let metadataFileName = "history_metadata.json"

    private var metadataURL: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(metadataFileName)
    }

    private var imagesDir: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("history_images", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    init() {
        loadFromDisk()
    }

    func addItem(_ item: GeneratedImage) {
        var namedItem = item
        let calendar = Calendar.current
        let todayCount = historyItems.filter { calendar.isDate($0.createdAt, inSameDayAs: item.createdAt) }.count
        let seq = todayCount + 1

        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        let dateStr = formatter.string(from: item.createdAt)

        namedItem.displayName = "\(item.styleName)_\(dateStr)\(String(format: "%03d", seq))"

        historyItems.insert(namedItem, at: 0)
        saveToDisk()
    }

    func deleteItems(ids: Set<String>) {
        // 删除图片文件
        for id in ids {
            let originalPath = imagesDir.appendingPathComponent("\(id)_original.jpg")
            let generatedPath = imagesDir.appendingPathComponent("\(id)_generated.jpg")
            try? fileManager.removeItem(at: originalPath)
            try? fileManager.removeItem(at: generatedPath)
        }
        // 从数组中移除
        historyItems.removeAll { ids.contains($0.id) }
        saveToDisk()
    }

    private func loadFromDisk() {
        isLoading = true
        defer { isLoading = false }

        guard let data = try? Data(contentsOf: metadataURL),
              let metadataList = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return
        }

        historyItems = metadataList.compactMap { dict -> GeneratedImage? in
            guard let id = dict["id"] as? String,
                  let styleName = dict["styleName"] as? String,
                  let timestamp = dict["createdAt"] as? TimeInterval,
                  let originalName = dict["originalImage"] as? String,
                  let generatedName = dict["generatedImage"] as? String else {
                return nil
            }

            let originalPath = imagesDir.appendingPathComponent(originalName)
            let generatedPath = imagesDir.appendingPathComponent(generatedName)

            guard let originalImage = UIImage(contentsOfFile: originalPath.path),
                  let generatedImage = UIImage(contentsOfFile: generatedPath.path) else {
                return nil
            }

            return GeneratedImage(
                id: id,
                originalImage: originalImage,
                generatedImage: generatedImage,
                styleName: styleName,
                createdAt: Date(timeIntervalSince1970: timestamp),
                displayName: dict["displayName"] as? String ?? ""
            )
        }
    }

    private func saveToDisk() {
        let metadataList: [[String: Any]] = historyItems.map { item in
            let originalName = "\(item.id)_original.jpg"
            let generatedName = "\(item.id)_generated.jpg"

            // 保存图片到文件系统
            if let originalData = item.originalImage.jpegData(compressionQuality: 0.8) {
                try? originalData.write(to: imagesDir.appendingPathComponent(originalName))
            }
            if let generatedData = item.generatedImage.jpegData(compressionQuality: 0.8) {
                try? generatedData.write(to: imagesDir.appendingPathComponent(generatedName))
            }

            return [
                "id": item.id,
                "styleName": item.styleName,
                "createdAt": item.createdAt.timeIntervalSince1970,
                "originalImage": originalName,
                "generatedImage": generatedName,
                "displayName": item.displayName
            ]
        }

        if let data = try? JSONSerialization.data(withJSONObject: metadataList, options: .prettyPrinted) {
            try? data.write(to: metadataURL)
        }
    }
}
