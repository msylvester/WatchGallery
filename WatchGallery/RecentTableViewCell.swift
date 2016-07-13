//
//  RecentTableViewCell.swift
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

class RecentTableViewCell: UITableViewCell {
  
  //MARK: Properties
  @IBOutlet weak var galleryLabel: UILabel!
  @IBOutlet weak var galleryImage: UIImageView!
  @IBOutlet weak var artistLabel: UILabel!

  weak var record: CKRecord?
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

}
