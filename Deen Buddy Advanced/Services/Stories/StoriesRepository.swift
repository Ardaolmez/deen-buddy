//
//  StoriesRepository.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

protocol StoriesRepositoryType {
    func allCaliphs() -> [Caliph]
    func caliph(withName name: String) -> Caliph?
}

final class StoriesRepository: StoriesRepositoryType {
    static let shared = StoriesRepository()

    private struct CaliphConfig {
        let order: Int
        let name: String
        let title: String
        let resource: String?
    }

    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let caliphConfigs: [CaliphConfig]
    private lazy var cachedCaliphs: [Caliph] = loadCaliphs()

    init(bundle: Bundle = StoriesRepository.resolveBundle(), decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
        self.caliphConfigs = [
            CaliphConfig(order: 1, name: "Abu Bakr (RA)", title: "As-Siddiq · First Caliph", resource: "HazratAbuBakr"),
            CaliphConfig(order: 2, name: "Umar ibn al-Khattab (RA)", title: "Al-Faruq · Second Caliph", resource: "HazratUmer"),
            CaliphConfig(order: 3, name: "Uthman ibn Affan (RA)", title: "Dhun-Nurayn · Third Caliph", resource: "HazratUsman"),
            CaliphConfig(order: 4, name: "Ali ibn Abi Talib (RA)", title: "Lion of Allah · Fourth Caliph", resource: "HazratAli")
        ]
    }

    func allCaliphs() -> [Caliph] {
        cachedCaliphs
    }

    func caliph(withName name: String) -> Caliph? {
        cachedCaliphs.first { $0.name == name }
    }

    private func loadCaliphs() -> [Caliph] {
        caliphConfigs.map { config in
            let stories = loadStories(for: config)
            return Caliph(order: config.order, name: config.name, title: config.title, stories: stories)
        }
    }

    private func loadStories(for config: CaliphConfig) -> [StoryArticle] {
        guard let resource = config.resource,
              let url = resourceURL(for: resource) else {
#if DEBUG
            if let resourceName = config.resource {
                let available = availableJSONResourceNames().joined(separator: ", ")
                debugPrint("StoriesRepository: Missing resource \(resourceName).json. Available JSON files: [\(available)].")
            }
#endif
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let sanitizedData = sanitizeJSONData(data)
            return try decoder.decode([StoryArticle].self, from: sanitizedData)
        } catch {
#if DEBUG
            debugPrint("StoriesRepository: Failed to decode \(resource).json — \(error)")
#endif
            return []
        }
    }

    private func resourceURL(for resource: String) -> URL? {
        let candidates: [Bundle] = [bundle, Bundle(for: StoriesRepository.self)]
        let fileName = "\(resource).json"
        let subdirectories: [String?] = [
            "CaliphateStories",
            "Resources/CaliphateStories",
            nil
        ]

        for candidate in candidates {
            for subdirectory in subdirectories {
                if let url = candidate.url(forResource: resource, withExtension: "json", subdirectory: subdirectory) {
                    return url
                }
                if let url = candidate.url(forResource: "CaliphateStories/\(resource)", withExtension: "json", subdirectory: subdirectory) {
                    return url
                }
            }

            if let urls = candidate.urls(forResourcesWithExtension: "json", subdirectory: "CaliphateStories"),
               let match = urls.first(where: { $0.lastPathComponent == fileName }) {
                return match
            }

            if let urls = candidate.urls(forResourcesWithExtension: "json", subdirectory: nil),
               let match = urls.first(where: { $0.lastPathComponent == fileName }) {
                return match
            }
        }

        return nil
    }

    private func availableJSONResourceNames() -> [String] {
        var collected = Set<String>()
        let candidates: [Bundle] = [bundle, Bundle(for: StoriesRepository.self)]
        let subdirectories: [String?] = ["CaliphateStories", nil]

        for candidate in candidates {
            for subdirectory in subdirectories {
                if let urls = candidate.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) {
                    for url in urls {
                        collected.insert(url.lastPathComponent)
                    }
                }
            }
        }

        return Array(collected).sorted()
    }

    private static func resolveBundle() -> Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle.main
#endif
    }

    private func sanitizeJSONData(_ data: Data) -> Data {
        guard let raw = String(data: data, encoding: .utf8) else {
            return data
        }

        let withoutComments = raw
            .components(separatedBy: .newlines)
            .filter { line in
                line.trimmingCharacters(in: .whitespaces).hasPrefix("//") == false
            }
            .joined(separator: "\n")

        let pattern = #"\}(\s*)\{"#
        let adjusted: String
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: withoutComments.utf16.count)
            adjusted = regex.stringByReplacingMatches(in: withoutComments, options: [], range: range, withTemplate: "},$1{")
        } else {
            adjusted = withoutComments
        }

        return adjusted.data(using: .utf8) ?? data
    }
}
