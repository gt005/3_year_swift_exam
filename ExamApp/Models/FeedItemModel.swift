//
//  FeedItem.swift
//  ExamApp
//
//  Created by Карим on 18.06.2024.
//

import Foundation

struct FeedItem: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let image: String
    let description: String
    let likesCount: Int

    enum CodingKeys: String, CodingKey {
        case name, image, description, likesCount = "likes_count"
    }
}
