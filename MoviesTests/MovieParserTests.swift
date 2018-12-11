//
//  MovieParserTests.swift
//  MoviesTests
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import XCTest
@testable import Movies

class MovieParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParsingArrayOfMovies() {
        let arr = [["name":"name1", "ratting": "12"], ["name":"name2", "ratting": "123"]]
        let dat = try? JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
        
        let movieParser = MovieParser()
        var movies:[Movie] = []
        if let data = dat {
             movies = movieParser.parseMovies(data: data)
        }
        
        XCTAssertTrue(movies.count == 2, "Failed to return the expected count of movies")
        
        let firstMovie = movies[0]
        let secondMovie = movies[1]
        
        // Asserting on movies values
        XCTAssertTrue(firstMovie.name == "name1", "failed to parse first movie name")
        XCTAssertTrue(secondMovie.name == "name2", "failed to parse second movie name")
        
        XCTAssertTrue(firstMovie.rating == "12", "failed to parse first movie ratting")
        XCTAssertTrue(secondMovie.rating == "123", "failed to parse second movie ratting")
    }
    
    func testParsingEmptyArrayOfMovies() {
        let dat = try? JSONSerialization.data(withJSONObject: [], options: .prettyPrinted)
        
        let movieParser = MovieParser()
        var movies:[Movie] = []
        if let data = dat {
            movies = movieParser.parseMovies(data: data)
        }
        
        XCTAssertTrue(movies.count == 0, "Failed to return the expected count of movies")
    }
    

}
