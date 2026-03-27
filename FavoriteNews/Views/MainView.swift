//
//  MainView.swift
//  FavoriteNews
//
//  Created by yoonie on 3/27/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var articles: [FavoriteArticle] = []
    @State private var vm = FavoriteNewsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                List {
                    ForEach(articles, id: \.id) { article in
                        Section {
                            Text(article.title)
                        }
                    }
                } //:LIST
            } //:SCROLL
        } //:NAVIGATION
        .onAppear {
            vm.modelContext = self.modelContext
            Task {
                do {
                    try await vm.fetchArticles()
                } catch err as NetworkError {
                    switch err {
                        
                    }
                }
            }
        }
    }//:body
}

#Preview {
    MainView()
}
