//
//  FullscreenViewController.swift
//  FrostedFlicks
//
//  Created by John Kang on 5/17/16.
//  Copyright © 2016 John Kang. All rights reserved.
//

import UIKit

class FullscreenViewController: UIViewController {
    var flickrImageUrl = String()
    
    
    @IBOutlet weak var flickrImageFullscreen: UIImageView!

    override func viewWillAppear(animated: Bool) {
        if let url  = NSURL(string: flickrImageUrl),
            data = NSData(contentsOfURL: url) {
            self.flickrImageFullscreen.image = UIImage(data: data)
        }

    }
    
}
