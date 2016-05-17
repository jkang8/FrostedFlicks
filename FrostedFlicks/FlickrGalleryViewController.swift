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

class FlickrGalleryViewController: UITableViewController {

    let FLICKR_API_KEY:String = "c2f381afce2dde17fa670662c27766a1"
    let FLICKR_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?format=json"
    let JSON_CALLBACK:Int = 1
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var imagesList = [FlickrImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(.GET, FLICKR_URL, parameters: ["nojsoncallback": JSON_CALLBACK])
            .validate()
            .responseString { response in
                switch response.result {
                    case .Success(let data):
                        // Replace escaped single quotes with single quotes because Flickr escapes them
                        // and causes JSON linter to break
                        let newData = data.stringByReplacingOccurrencesOfString("\\'", withString: "'")
                        let images = JSON.parse(newData)["items"]
                        self.imagesList = [FlickrImage]()
                        for (_,imageData):(String, JSON) in images {
                            let title = imageData["title"].string
                            let media = imageData["media"]["m"].string
                            let flickrImage = FlickrImage(
                                title: title!,
                                media: media!)
                            self.imagesList.append(flickrImage)
                        }
                        self.tableView.reloadData()
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                }

            }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FlickrImageTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FlickrImageTableViewCell
        
        let flickrImage = self.imagesList[indexPath.row]
        
        if let url  = NSURL(string: flickrImage.media),
            data = NSData(contentsOfURL: url) {
            cell.textLabel!.text = flickrImage.title
            cell.imageView!.image = cropToBounds(UIImage(data: data)!, width: 96, height: 96)
        }

        return cell
    }

}

// Crop image in center
func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
    let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
    
    let contextSize: CGSize = contextImage.size
    
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}
