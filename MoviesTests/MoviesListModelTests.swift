//
//  MoviesListModelTests.swift
//  MoviesTests
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import XCTest
@testable import Movies

class MoviesListModelDelegateMock: NSObject, MoviesListModelDelegate {
    public var movies:[Movie] = []
    func didFetchMovies(success: Bool, movies: [Movie]) {
        self.movies = movies;
    }
}

class MoviesListModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchingMoviesFromNetworkLayer() {
        let networkLayer = NetworkLayerMock(mockedData: [["name":"name1", "ratting": "12"], ["name":"name2", "ratting": "123"]])
        let movieslistModel = MoviesListModel(networkLayer: networkLayer)
        let moviesListModelDelegateMock = MoviesListModelDelegateMock()
        movieslistModel.delegate = moviesListModelDelegateMock
        movieslistModel.fetchMovies()
        
        XCTAssertTrue(moviesListModelDelegateMock.movies.count == 2, "Failed to return the expected count of movies")

        let firstMovie = moviesListModelDelegateMock.movies[0]
        let secondMovie = moviesListModelDelegateMock.movies[1]
        
        // Asserting on movies values
        XCTAssertTrue(firstMovie.name == "name1", "failed to parse first movie name")
        XCTAssertTrue(secondMovie.name == "name2", "failed to parse second movie name")
        
        XCTAssertTrue(firstMovie.rating == "12", "failed to parse first movie ratting")
        XCTAssertTrue(secondMovie.rating == "123", "failed to parse second movie ratting")
    }

}
