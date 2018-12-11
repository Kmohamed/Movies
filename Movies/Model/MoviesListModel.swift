//
//  MoviesListModel.swift
//  Movies
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import UIKit

protocol MoviesListModelDelegate : AnyObject {
    func didFetchMovies(success:Bool, movies:[Movie])
}

open class MoviesListModel {
    weak var delegate: MoviesListModelDelegate?
    private let networkLayer: Network

    init(networkLayer:Network) {
        self.networkLayer = networkLayer
    }
    
   open func fetchMovies() {
        self.networkLayer.executeGETRequest(api: "/Movies", completionBlock: { (data) in
            if let moviesData = data {
                let movieParser = MovieParser()
                let movies = movieParser.parseMovies(data: moviesData)
                if let delegate = self.delegate {
                    delegate.didFetchMovies(success: true, movies: movies)
                    return
                }
            }
            
            if let delegate = self.delegate {
                delegate.didFetchMovies(success: false, movies: [])
                return
            }
        })
    }
}
