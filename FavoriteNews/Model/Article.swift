//
//  Article.swift
//  FavoriteNews
//
//  Created by YoonieMac on 3/27/26.
//

import Foundation

struct Article: Identifiable, Codable, Sendable {
    let id: Int
    let title: String
    let url: String?
}
