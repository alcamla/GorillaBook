//
//  FeedEntry.swift
//  GorillaBook
//
//  Created by Alejandro Camacho on 16/11/20.
//

import Foundation


struct FeedEntry: Codable {
    var id: Int
    var firstName: String
    var lastName: String
    var body: String
    var timestamp: String
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName  = "first_name"
        case lastName =  "last_name"
        case body = "post_body"
        case timestamp = "unix_timestamp"
        case image
    }
}
