//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit
import CoreData

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        if let image = UIImage(systemName: "photo.fill") {
            imageView.image = image
        } else {
            imageView.image = nil
        }
    }
    
    func setup(by photo: Photo) {
        imageView.contentMode = .scaleAspectFit
        if let data = photo.imageData {
            imageView.image = UIImage(data: data)
        } else if let source = photo.source {
            Services.shared.downloadImage(url: source) { [weak self] (data, error) in
                if let data = data {
                    photo.imageData = data
                    CoreDataManager.shared.saveContext()
                    let downloadedImage = UIImage(data: data)
                    if let downloadedImage = downloadedImage {
                        self?.imageView.image = downloadedImage
                    }
                }
            }
        }
    }
}

