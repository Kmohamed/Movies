//
//  MoviesUITests.swift
//  MoviesUITests
//
//  Created by khaled mohamed el morabea on 12/9/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import XCTest
import Swifter

class MoviesUITests: XCTestCase {
   
    let app = XCUIApplication()
    let dynamicStubs = HTTPDynamicStubs()

    override func setUp() {
        continueAfterFailure = false
        dynamicStubs.setUp()
        app.launchEnvironment = ["BASEURL" : "http://localhost:8080"]
        continueAfterFailure = false
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        dynamicStubs.tearDown()
    }
    
    func testShowingMovieNameAndImageName() {
        dynamicStubs.setupStub(url: "/Movies", filename: "listOfMovies", method: .GET)
        app.launch()

        let tablesQuery = app.tables
        
        // Assert on first movie
        XCTAssertTrue(tablesQuery.cells.staticTexts["Avengers: Infinity War"].exists, "Failure: did not show the first movie name.")
        XCTAssertTrue(tablesQuery.cells.staticTexts["8.5"].exists, "Failure: did not show the first movie ratting.")

        // Assert on second movie
        XCTAssertTrue(tablesQuery.cells.staticTexts["Bohemian Rhapsody"].exists, "Failure: did not show the second movie name.")
        XCTAssertTrue(tablesQuery.cells.staticTexts["8.4"].exists, "Failure: did not show the first movie ratting.")

        // Assert on third movie
        XCTAssertTrue(tablesQuery.cells.staticTexts["Aquaman"].exists, "Failure: did not show the third movie name.")
        XCTAssertTrue(tablesQuery.cells.staticTexts["8.3"].exists, "Failure: did not show the first movie ratting.")

        // Assert on fourth movie
        XCTAssertTrue(tablesQuery.cells.staticTexts["A Star Is Born"].exists, "Failure: did not show the fourth movie name.")
        XCTAssertTrue(tablesQuery.cells.staticTexts["8.2"].exists, "Failure: did not show the first movie ratting.")
    }
}
