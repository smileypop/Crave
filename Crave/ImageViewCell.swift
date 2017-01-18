//
//  ImageViewCell.swift
//  Crave
//
//  Created by Matthew Laird on 1/11/17.
//  Copyright © 2017 Matthew Laird. All rights reserved.
//

import UIKit

// Class for showing photos in a collection view cell

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }

    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = darkRedColor?.cgColor
        isSelected = false
    }
}
