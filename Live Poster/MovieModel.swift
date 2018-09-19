//
//  MovieModel.swift
//  omdb
//
//  Created by Quang Nguyen on 9/18/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit
let APIKey = "275726ed"
let BH6MovieId = "tt2245084"

class Movie: NSObject {
    var title: String?
    var releaseDate: Date?
    var ratingIMDB: Double?
    
    func textInfo() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let releaseDateStr = dateFormatter.string(from: releaseDate!)
        
        return "Title: \(title!)\n Release on: \(releaseDateStr)\n IMDB: \(ratingIMDB!)/10"
    }
}

class MovieModel {

    static func fetchDataForMovie(withId movieId: String, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        
        let url = URL(string: "http://www.omdbapi.com/?i=\(movieId)&apikey=\(APIKey)")

        let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
        
        task.resume()
    }
}
