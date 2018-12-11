//
//  MoviesListIntegrationTests.swift
//  MoviesTests
//
//  Created by khaled mohamed el morabea on 12/10/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import XCTest
@testable import Movies

class ViewControllerMock: NSObject, MoviesListPresenterDelegate {
    var didFetchMovies = false;

    func didFetchMovies(success:Bool) {
        didFetchMovies = success
    }
}


class MoviesListIntegrationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShowingMovieNameAndImageName() {
        let networkLayer = NetworkLayerMock(mockedData:  [["name":"Avengers: Infinity War", "ratting": "8.5"], ["name":"Bohemian Rhapsody", "ratting": "8.4"]])
        let moviesListModel = MoviesListModel(networkLayer: networkLayer)
        let moviesListPresenter = MoviesListPresenter(moviesListModel: moviesListModel)
        let viewControllerMock = ViewControllerMock()
        moviesListPresenter.delegate = viewControllerMock
        moviesListPresenter.fetchMovies()
        
        XCTAssertTrue(viewControllerMock.didFetchMovies, "Success in fetching movies")
        XCTAssertTrue(moviesListPresenter.movieName(index:0) == "Avengers: Infinity War", "First movie name is not as expected")
        XCTAssertTrue(moviesListPresenter.movieRatting(index:0) == "8.5", "First movie ratting is not as expected")
        XCTAssertTrue(moviesListPresenter.movieName(index:1) == "Bohemian Rhapsody", "Second movie name is not as expected")
        XCTAssertTrue(moviesListPresenter.movieRatting(index:1) == "8.4", "First movie ratting is not as expected")
    }

}
