//
//  FavoriteNewsViewModel.swift
//  FavoriteNews
//
//  Created by yoonie on 3/27/26.
//

import Foundation
import SwiftData


enum NetworkError: String, Error {
    case invalidURL = "URL 에러 발생"
    case invalidResponse = "서버 응답 에러 발생"
    case invalidData = "데이터 파싱 에러 발생"
}


@MainActor
@Observable
final class FavoriteNewsViewModel {
    
    var modelContext: ModelContext? = nil
    
    let idsUrl = "https://hacker-news.firebaseio.com/v0/topstories.json"
    var articles: [FavoriteArticle] = []
    
    // 1. idsurl에서 [0..<10]을 슬라이스해서 가져와서 url을 만든다.(여기까지는 네트워크 만)
    func fetchURLs() async throws -> [URL] {
        var urls: [URL] = []
        
        guard let idUrl = URL(string: idsUrl) else {throw NetworkError.invalidURL}
        let (data, res) = try await URLSession.shared.data(from: idUrl)
        guard let  res = res as? HTTPURLResponse,
              res.statusCode >= 200 && res.statusCode < 300 else { throw NetworkError.invalidResponse }
        let idList = try JSONDecoder().decode([Int].self, from: data)
        let ids = Array(idList[0..<20])
        for id in ids {
            guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
                throw NetworkError.invalidURL
            }
            urls.append(url)
        }
        return urls
    }
    
    // 2. withTaskGroup에서 각각 id에 해당하는 기사 정보를 가져온다(여기까지 네트워크의 일)
    func fetchArticles() async throws {
        let articleURLs = try await fetchURLs()
        
        // non-isolated 작업(network 작업)
        let articles = try await withThrowingTaskGroup(of: Article.self) { group in
            for articleURL in articleURLs {
                group.addTask { @Sendable [articleURL] in
                    try await self.fetchArticle(from: articleURL)
                }
            }
            
            var results: [Article] = []
            for try await article in group {
                results.append(article)
            }
            return results
        }
        
        // MainActor 작업(Swift Data)
        guard let modelContext = self.modelContext else {return}
        
        let savedArticles = try modelContext.fetch(FetchDescriptor<FavoriteArticle>())
        
        savedArticles
            .filter { $0.isFavorite == false }
            .filter { saved in
                !articles.contains(where: { $0.id == saved.id })
            }
            .forEach {
                modelContext.delete($0)
            }
        
        articles
            .filter { fetched in
                !savedArticles.contains(where: { $0.id == fetched.id })
            }
            .forEach {
                let articleWillBeAdded = FavoriteArticle(id: $0.id, title: $0.title, url: $0.url)
                modelContext.insert(articleWillBeAdded)
            }
    }
    
    nonisolated func fetchArticle(from url: URL) async throws -> Article {
       let (data, res) = try await URLSession.shared.data(from: url)
       guard let res = res as? HTTPURLResponse,
             res.statusCode >= 200 && res.statusCode < 300 else {
           throw NetworkError.invalidResponse }
        
        do {
            let decodedData = try JSONDecoder().decode(Article.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.invalidData
        }
    }
}

