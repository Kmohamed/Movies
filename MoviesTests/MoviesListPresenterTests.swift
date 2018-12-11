//
//  MoviesListPresenterTests.swift
//  MoviesTests
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import XCTest
@testable import Movies

class MoviesListModelMock: MoviesListModel {
    
    private var mockedMovies: [Movie] = []
    
    convenience init(mockedMovies:[Movie]) {
        self.init(networkLayer: Network())
        self.mockedMovies = mockedMovies
    }
    
    override func fetchMovies() {
        if let delegate = self.delegate {
            delegate.didFetchMovies(success: false, movies: self.mockedMovies)
            return
        }
    }
}

class MoviesListPresenterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadingMovies() {
        let movie1 = Movie()
        movie1.name = "name1"
        movie1.rating = "99"
        
        let movie2 = Movie()
        movie2.name = "name2"
        movie1.rating = "100"
        
        let moviesListModelMock = MoviesListModelMock(mockedMovies: [movie1, movie2])
        let moviesListPresenter = MoviesListPresenter(moviesListModel: moviesListModelMock)
        moviesListPresenter.fetchMovies()
        
        XCTAssertTrue(moviesListPresenter.movieName(index: 0) == "name1", "failed to fetch first movie name")
        XCTAssertTrue(moviesListPresenter.movieName(index: 1) == "name2", "failed to fetch second movie name")
    }

}
