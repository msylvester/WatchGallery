//
//  AllGalleriesTableViewCell.swift
//  WatchGallery
//
//  Created by Michael on 4/28/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import CloudKit
import DataKit
import MapKit
import CoreLocation

class AllGalleriesTableViewCell: UITableViewCell {

  //MARK: Properties
  @IBOutlet weak var allGalleryImage: UIImageView!
  @IBOutlet weak var allGalleriesLabel: UILabel!
  weak var record: CKRecord?
 
  
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
