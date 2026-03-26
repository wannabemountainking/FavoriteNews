//
//  FavoriteArticle.swift
//  FavoriteNews
//
//  Created by yoonie on 3/27/26.
//

import Foundation
import SwiftData


@Model
final class FavoriteArticle {
    var id: Int
    var title: String
    var url: String?
    var savedAt: Date
    
    init(id: Int, title: String, url: String? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.savedAt = Date()
    }
}

@MainActor
extension FavoriteArticle {
    
    static var previewContainer: ModelContainer {
        let container: ModelContainer
        
        do {
            container = try ModelContainer(for: FavoriteArticle.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            print("Error on InMemoryOnlyData Setting: \(error)")
        }
        
        let mockArticles: [FavoriteArticle] = [
            FavoriteArticle(
                id: 47530330,
                title: "Moving from GitHub to Codeberg, for lazy people",
                url: "https://unterwaditzer.net/2025/codeberg.html"
                ),
            FavoriteArticle(
                id: 47529646,
                title: "European Parliament decided that Chat Control 1.0 must stop",
                url: "https://bsky.app/profile/tuta.com/post/3mhxkfowv322c"
                )
            ]
        for article in mockArticles {
            container.mainContext.insert(article)
        }
    }
}
