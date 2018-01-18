//
//  TouristAttractionCell.swift
//  explore-ios
//
//  Created by Andra on 14/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit

class TouristAttractionCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var attractionImageView: UIImageView!
    var touristAttraction : TouristAttraction?
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    private func addShadow(){
        self.view.bounds = self.bounds
        self.view.layer.shadowOffset = CGSize(width: 2, height: 1)
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowRadius = 3
        self.view.layer.shadowOpacity = 0.4
        self.view.layer.masksToBounds = false;
        self.view.clipsToBounds = false;
        
    }
    
}
