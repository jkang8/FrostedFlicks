//
//  FlickrApi.swift
//  FrostedFlicks
//
//  Created by John Kang on 5/20/16.
//  Copyright © 2016 John Kang. All rights reserved.
//

import Alamofire
import SwiftyJSON

class FlickrApi {
    // MARK: Constants
    let FLICKR_API_KEY:String = "c2f381afce2dde17fa670662c27766a1"
    let FLICKR_PUBLIC_FEED_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?format=json"
    let FLICKR_SEARCH_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?tags=searchTerm&;tagmode=any&format=json"
    let JSON_CALLBACK:Int = 1
    
    // MARK: Flickr API calls
    func getFlickrPublicFeed(completionHandler: (responseObject: String?, error: NSError?) -> ()) {
        //it passes your closure to getFeed
        let url = self.FLICKR_PUBLIC_FEED_URL
        getFeed(url, completionHandler: completionHandler)
    }
    
    func getFlickrSearchFeed(searchTerms: String, completionHandler: (responseObject: String?, error: NSError?) -> ()) {
        //it passes your closure to getFeed
        let url = FLICKR_SEARCH_URL.stringByReplacingOccurrencesOfString("searchTerm", withString: searchTerms)
        getFeed(url, completionHandler: completionHandler)
    }
    
    // MARK: Private methods
    private func getFeed(url: String, completionHandler: (responseObject: String?, error: NSError?) -> ()) {
        // this passes your closure to getFlickrFeed
        getFlickrFeed(url, completionHandler: completionHandler)
    }
    
    private func getFlickrFeed(url:String, completionHandler: (responseObject: String?,
        error: NSError?) -> ()) {
        if let validUrl = NSURL(string: url) {
            Alamofire.request(.GET, validUrl, parameters: ["nojsoncallback": JSON_CALLBACK])
                .responseString { response in
                    // Replace escaped single quotes with single quotes because Flickr escapes them
                    // and causes JSON linter to break
                    let jsonData = response.result.value!.stringByReplacingOccurrencesOfString("\\'", withString: "'")
                    completionHandler(responseObject: jsonData as String!, error: response.result.error)
            }
        }
    }
}
