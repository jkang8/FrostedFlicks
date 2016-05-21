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

class FlickrGalleryViewController: UITableViewController, UISearchBarDelegate {

    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    let FULLSCREEN_SEGUE_IDENTIFIER:String = "ShowFullscreenSegue"
    let CELL_IDENTIFIER:String = "FlickrImageTableViewCell"

    // MARK: Properties
    var imagesList:Array<FlickrImage> = [FlickrImage]()

    // MARK: Flickr gallery init
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        addSearchControl()
        FlickrApi().getFlickrPublicFeed{ (responseObject, error) in
            self.loadFlickrImages(responseObject!)
        }
        //getFlickrPublicFeed()
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
        self.searchBar.delegate = self
        tableView.tableHeaderView = self.searchBar
    }

    // MARK: Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchTerms = searchText.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.performSelector(#selector(FlickrGalleryViewController.getFlickrSearchFeed(_:)), withObject: searchTerms, afterDelay: 0.5)
        
    }
    

    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func refresh(sender:AnyObject) {
        // Refresh with new images from feed
        FlickrApi().getFlickrPublicFeed{ (responseObject, error) in
            self.loadFlickrImages(responseObject!)
        }
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
    
    func getFlickrSearchFeed(searchTerms: String) {
        FlickrApi().getFlickrSearchFeed(searchTerms, completionHandler: {(responseObject, error) in
            self.loadFlickrImages(responseObject!)
        })
    }
    
    func loadFlickrImages(jsonData: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                let images = JSON.parse(jsonData)["items"]
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
            });
        });
    }

}

