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

class FlickrGalleryViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Properties
    let FLICKR_API_KEY:String = "c2f381afce2dde17fa670662c27766a1"
    let FLICKR_PUBLIC_FEED_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?format=json"
    let FLICKR_SEARCH_URL:String = "https://api.flickr.com/services/feeds/photos_public.gne?tags=searchTerm&;tagmode=any&format=json&nojsoncallback=1"
    let JSON_CALLBACK:Int = 1
    let FULLSCREEN_SEGUE_IDENTIFIER:String = "ShowFullscreenSegue"
    let CELL_IDENTIFIER:String = "FlickrImageTableViewCell"
    
    var imagesList:Array<FlickrImage> = [FlickrImage]()
    var searchController = UISearchController(searchResultsController: nil)

    // MARK: Flickr gallery init
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        addSearchControl()
        getFlickrPublicFeed()
    }
    
    func addRefreshControl() {
        // Setup pull to refresh
        if self.refreshControl == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(FlickrGalleryViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.refreshControl = refreshControl
            tableView.addSubview(refreshControl)
        }
    }
    
    func addSearchControl() {
        searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: Flickr API calls
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            let url = FLICKR_SEARCH_URL.stringByReplacingOccurrencesOfString("searchTerm", withString: searchTerm)
            getFlickrFeed(url)
        }
    }
    
    func getFlickrPublicFeed() {
        getFlickrFeed(FLICKR_PUBLIC_FEED_URL)
    }
    
    func getFlickrFeed(url:String) {
        Alamofire.request(.GET, url, parameters: ["nojsoncallback": JSON_CALLBACK])
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
                    self.refreshControl?.endRefreshing()
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
                
        }

    }
    
    func refresh(sender:AnyObject) {
        // Refresh with new images from feed
        getFlickrFeed(FLICKR_PUBLIC_FEED_URL)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = CELL_IDENTIFIER
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FlickrImageTableViewCell
        
        // Set image and label of each cell of tableview
        let flickrImage = self.imagesList[indexPath.row]
        populateFlickrCell(flickrImage, cell: cell)
        return cell
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == FULLSCREEN_SEGUE_IDENTIFIER) {
            if let destination = segue.destinationViewController as? FullscreenViewController,
            index = tableView.indexPathForSelectedRow?.row {
                destination.flickrImageUrl = imagesList[index].media

            }
        }
    }
    
    // MARK: Helpers
    func populateFlickrCell(flickrImage: FlickrImage, cell: FlickrImageTableViewCell) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                let url = NSURL(string: flickrImage.media)
                let imageData = NSData(contentsOfURL: url!)
                if(imageData != nil){
                    cell.FlickrImageView.image = UIImage(data: imageData!)
                    cell.FlickrTitle.text = flickrImage.title
                }
            });
        });
        
    }

}