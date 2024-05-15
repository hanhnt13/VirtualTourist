//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}

