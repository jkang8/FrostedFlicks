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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFlickrImageObjectCreation() {
        let flickrImage = FlickrImage(title: "title", media: "http://www.asdf.com/image.jpg")
        XCTAssert(flickrImage.title == "title")
        XCTAssert(flickrImage.media == "http://www.asdf.com/image.jpg")
    }
}
