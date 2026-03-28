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
    
    @Query var savedArticles: [FavoriteArticle]
    @State private var vm = FavoriteNewsViewModel()
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedArticles, id: \.id) { article in
                    Section {
                        HStack {
                            Text("☐ \(article.title)")
                            Spacer()
                            Button {
                                //action
                                withAnimation(.spring) {
                                    article.isFavorite.toggle()
                                }
                            } label: {
                                if article.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.red)
                                } else {
                                    Image(systemName: "heart")
                                        .resizable()
                                        .frame(width: 27, height: 27)
                                        .foregroundStyle(.gray.opacity(0.5))
                                }
                            }

                        }
                        
                        HStack(spacing: 5) {
                            Text(URL(string: article.url ?? "")?.host() ?? "도메인 없음")
                            Text(" • ")
                            Text(timeDistance(article: article))
                        }
                        
                    }//:SECTION
                } //:LOOP
                Text(errorMessage)
                    .font(.largeTitle)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.red)
            } //:LIST
            .navigationTitle("뉴스 헤드라인")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                fetchArticleToView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("새로고침", systemImage: "home") {
                        fetchArticleToView()
                    }//: Button
                } //:TOOLBARItem
            } //:TOOLBAR
        } //:NAVIGATION
        .onAppear {
            vm.modelContext = self.modelContext
            fetchArticleToView()
        }
    }//:body
    
    // MARK: - Function
    func timeDistance(article: FavoriteArticle) -> String {
        let savedTime: Date = article.savedAt
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: savedTime, to: .now)
        var day: String {
            guard let d = components.day else { return "" }
            guard d != 0 else { return "" }
            return "\(d)일 전"
        }
        var hour: String {
            guard let h = components.hour else { return "" }
            guard h != 0 else {return ""}
            return "\(h)시간 전"
        }
        var minute: String {
            guard let m = components.minute else {return ""}
            guard m != 0 else  {return ""}
            return "\(m)분 전"
        }
        
        if !day.isEmpty {
            return day
        } else if !hour.isEmpty {
            return hour
        } else {
            return minute
        }
    }
    
    func fetchArticleToView() {
        Task {
            do {
                try await vm.fetchArticles()
            } catch let err as NetworkError {
                switch err {
                case .invalidURL: errorMessage = err.rawValue
                case .invalidResponse: errorMessage = err.rawValue
                case .invalidData: errorMessage = err.rawValue
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    MainView()
}
