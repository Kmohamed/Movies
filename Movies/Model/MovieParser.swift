
//
//  MovieParser.swift
//  Movies
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import UIKit

public class MovieParser: NSObject {

    func parseMovies(data:Data) -> [Movie] {
        do {
            var movies:[Movie] = []
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String:String]] {
                for object in jsonArray {
                    let movie = Movie()
                    movie.name = object["name"]
                    movie.rating = object["ratting"]
                    movies.append(movie)
                }
                return movies
            } else {
                return []
            }
        } catch let error as NSError {
            print(error)
        }
        return []
    }
    
}
