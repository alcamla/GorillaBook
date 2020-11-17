//
//  GetEntries.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 17/11/20.
//

import Foundation

protocol GetFeedEntries {
    func execute(completion: @escaping (Result<[FeedEntry],Error>) -> Void)
}

final class GetFeedEntriesAdapter: GetFeedEntries {
    func execute(completion: @escaping (Result<[FeedEntry],Error>) -> Void) {
        
        guard let url =  URL(string: "https://gl-endpoint.herokuapp.com/feed") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let feedEntries = try? JSONDecoder().decode([FeedEntry].self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(feedEntries))
                }
            }
            else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            }
            
        }.resume()
    }
}


