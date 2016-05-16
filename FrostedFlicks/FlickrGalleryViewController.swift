//
//  FlickrGalleryViewController.swift
//  FrostedFlicks
//
//  Created by John Kang on 5/15/16.
//  Copyright © 2016 John Kang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "Cell"

class FlickrGalleryViewController: UICollectionViewController {

    let FLICKR_API_KEY:String = "c2f381afce2dde17fa670662c27766a1"
    let FLICKR_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?format=json"
    let JSON_CALLBACK:Int = 1
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(.GET, FLICKR_URL, parameters: ["nojsoncallback": JSON_CALLBACK])
            .validate()
            .responseString { response in
                switch response.result {
                    case .Success(let data):
                        let newData = data.stringByReplacingOccurrencesOfString("\\'", withString: "'")
                        let json = JSON(newData)
                        print(json)
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                }
                

        }

    }
}
