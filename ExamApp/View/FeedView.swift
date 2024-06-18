//
//  Feed.swift
//  ExamApp
//
//  Created by Карим on 18.06.2024.
//

import Foundation
import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @State private var searchQuery = ""

    var body: some View {
        NavigationView {
            List(viewModel.filteredFeedItems) { item in
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.name).bold()
                    Text(item.description).lineLimit(3)
                    AsyncImage(url: URL(string: item.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 100, height: 100)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    Text("Likes: \(item.likesCount)")
                }
            }
            .padding(.vertical, 8)
            .refreshable {
                await viewModel.refreshDataIfNeeded()
            }
            .navigationTitle(NSLocalizedString("News Feed", comment: "Navigation title"))
            .searchable(text: $searchQuery, prompt: NSLocalizedString("Search Description", comment: "Search bar placeholder"))
            .onChange(of: searchQuery) { newValue in
                viewModel.searchFeed(with: newValue)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView(NSLocalizedString("Loading...", comment: "Loading indicator text"))
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.refreshDataIfNeeded()
            }
        }
    }
}
