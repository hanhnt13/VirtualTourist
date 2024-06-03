//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    let service = Services.shared
    let coreDataManager = CoreDataManager.shared
    var page: Int = 0
    var availablePages: Int?
    var pin: Pin!
    var photos: [Photo] {
        pin.photos?.array as? [Photo] ?? []
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noPhotosWarning: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
    }
    
    func setupMapView() {
        mapView.delegate = self
        
        let annotation = MKPointAnnotation()
               
        let cordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
        annotation.coordinate = cordinate
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        guard let distance = CLLocationDistance(exactly: rectangleSide) else {
            return
        }
        let region = MKCoordinateRegion( center: cordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if photos.count == 0 {
            loadImage()
        } else {
            noPhotosWarning.isHidden = true
            loadingView.isHidden = true
        }
    }
    
    @IBAction func fetchNewCollection() {
        page += 1
        loadImage()
    }
    
    func setupButton(by loading: Bool) {
        newCollectionButton.isEnabled = !loading
    }
    
    func loadImage() {
        setupButton(by: true)
        for photo in photos {
            coreDataManager.removePhoto(photo)
        }
        coreDataManager.saveContext()
        collectionView.reloadData()
        noPhotosWarning.isHidden = true
        loadingView.isHidden = false
        service.searchPhoto(lat: pin.lat, lon: pin.long, page: page) { [weak self] response, error in
            self?.loadingView.isHidden = true
            guard let response = response else {
                self?.noPhotosWarning.isHidden = false
                self?.setupButton(by: false)
                return
            }
            
            self?.handleResponse(response)
        }
    }
    
    func handleResponse(_ response: SearchPhotoResponse) {
        availablePages = response.photos.pages
        guard response.photos.photo.count > 0 else {
            noPhotosWarning.isHidden = false
            setupButton(by: false)
            return
        }
        
        noPhotosWarning.isHidden = true
        let dispatchGroup = DispatchGroup()
        for image in response.photos.photo {
            let newPhoto = Photo(context: coreDataManager.viewContext)
            newPhoto.id = image.id
            pin.addToPhotos(newPhoto)
            coreDataManager.saveContext()
        }
        coreDataManager.saveContext()
        collectionView.reloadData()
        setupButton(by: false)
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        guard let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView else {
            let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            pinView.tintColor = .systemTeal
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinView
        }
        
        pinView.annotation = annotation
        return pinView
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 32) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let photo = photos[indexPath.row]
        cell.setup(by: photo)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        coreDataManager.removePhoto(photo)
        coreDataManager.saveContext()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
