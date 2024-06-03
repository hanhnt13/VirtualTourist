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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var photo: Photo!
    
    override func prepareForReuse() {
        imageView.image = nil
        indicator.isHidden = false
    }
    
    func setup(by photo: Photo) {
        self.photo = photo
        imageView.contentMode = .scaleAspectFit
        if let data = photo.imageData {
            imageView.image = UIImage(data: data)
            indicator.isHidden = true
        } else if photo.source != nil {
            dowloadImage()
        } else if let id = photo.id {
            Services.shared.getSource(photoID: id) { [weak self] response, error in
                guard let response = response else {
                    return
                }
                if let lastPhoto = response.sizes.size.first {
                    photo.source = URL(string: lastPhoto.source)
                    CoreDataManager.shared.saveContext()
                    self?.dowloadImage()
                }
            }
        }
    }
    
    func dowloadImage() {
        guard let source = photo.source else {
            return
        }
        Services.shared.downloadImage(url: source) { [weak self] (data, error) in
            if let data = data {
                self?.photo.imageData = data
                CoreDataManager.shared.saveContext()
                let downloadedImage = UIImage(data: data)
                if let downloadedImage = downloadedImage {
                    self?.imageView.image = downloadedImage
                    self?.indicator.isHidden = true
                }
            }
        }
    }
}

