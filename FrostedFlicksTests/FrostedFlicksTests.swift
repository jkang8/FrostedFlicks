//
//  FrostedFlicksTests.swift
//  FrostedFlicksTests
//
//  Created by John Kang on 5/15/16.
//  Copyright © 2016 John Kang. All rights reserved.
//

import XCTest
@testable import FrostedFlicks

class FrostedFlicksTests: XCTestCase {
    
    let ASYNC_TIMEOUT:NSTimeInterval = 10
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFlickrImageObjectCreation() {
        let title = "title"
        let media = "http://www.asdf.com/image.jpg"
        let flickrImage = FlickrImage(title: title, media: media)
        XCTAssert(flickrImage.title == title)
        XCTAssert(flickrImage.media == media)
    }
    
    func testFlickrPublicFeed() {
        let expectation = expectationWithDescription("Expect a response")
        var jsonString: String?
        
        // Expect response back
        FlickrApi().getFlickrPublicFeed{ (responseObject, error) in
            jsonString = responseObject!
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(self.ASYNC_TIMEOUT) { error in
            XCTAssert(jsonString != nil)
        }

    }
    
    func testValidFlickrSearchFeed() {
        let expectation = expectationWithDescription("Test with valid search term")
        var jsonString: String?
        let searchTerms = "cats"
        
        // Expect response back
        FlickrApi().getFlickrSearchFeed(searchTerms, completionHandler: {(responseObject, error) in
            jsonString = responseObject!
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(self.ASYNC_TIMEOUT) { error in
            XCTAssert(jsonString != nil)
        }
    }
    
}
