//
//  FlickrImageTableViewCell.swift
//  FrostedFlicks
//
//  Created by John Kang on 5/16/16.
//  Copyright © 2016 John Kang. All rights reserved.
//

import UIKit

class FlickrImageTableViewCell: UITableViewCell {
    @IBOutlet weak var FlickrTitle: UILabel!
    @IBOutlet weak var FlickrImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
