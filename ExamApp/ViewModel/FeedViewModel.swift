//
//  Feed.swift
//  ExamApp
//
//  Created by Карим on 18.06.2024.
//

import Combine
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var filteredFeedItems: [FeedItem] = []
    @Published var lastUpdated: Date?

    private var cancellables = Set<AnyCancellable>()
    private let updateInterval: TimeInterval = Constants.waitForUpdateTime

    var baseUrl: String {
        let locale = Locale.preferredLanguages[0]
        
        return "\(Constants.serverUrl)/\(locale)"
    }

    func loadData() async {
        isLoading = true
        guard let url = URL(string: baseUrl) else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let feedItems = try JSONDecoder().decode([FeedItem].self, from: data)
            DispatchQueue.main.async {
                self.feedItems = feedItems
                self.filteredFeedItems = feedItems
                self.lastUpdated = Date()
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                print("Ошибка загрузки данных: \(error)")
                self.isLoading = false
            }
        }
    }

    func refreshDataIfNeeded() async {
        DispatchQueue.main.async {
            guard let lastUpdated = self.lastUpdated else {
                Task {
                    await self.loadData()
                }
                return
            }
            if Date().timeIntervalSince(lastUpdated) > self.updateInterval {
                Task {
                    await self.loadData()
                }
            }
        }
    }

    func searchFeed(with query: String) {
        DispatchQueue.main.async {
            if query.isEmpty {
                self.filteredFeedItems = self.feedItems
            } else {
                self.filteredFeedItems = self.feedItems.filter {
                    $0.description.localizedCaseInsensitiveContains(query)
                }
            }
        }
    }
}
