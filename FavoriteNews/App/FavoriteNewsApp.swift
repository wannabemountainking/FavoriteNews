//
//  FavoriteNewsApp.swift
//  FavoriteNews
//
//  Created by yoonie on 3/27/26.
//

import SwiftUI
import SwiftData

@main
struct FavoriteNewsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: FavoriteArticle.self)
        }
    }
}
