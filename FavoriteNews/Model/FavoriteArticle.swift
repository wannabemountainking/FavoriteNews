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
    var isFavorite: Bool
    
    init(id: Int, title: String, url: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.url = url
        self.savedAt = Date()
        self.isFavorite = isFavorite
    }
}

@MainActor
extension FavoriteArticle {
    
    static var previewContainer: ModelContainer {
        let container: ModelContainer
        
        do {
            container = try ModelContainer(for: FavoriteArticle.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            fatalError("Error on InMemoryOnlyData Setting: \(error)")
            
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
        
        try? container.mainContext.save()
        return container
    }
}
