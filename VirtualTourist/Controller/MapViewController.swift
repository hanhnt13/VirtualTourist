//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit
import MapKit
import CoreData

class TravelAnnotation: MKPointAnnotation {
    var pin: Pin!
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    let coreDataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        loadPins()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PhotoAlbumViewController, let annotation = sender as? TravelAnnotation {
            viewController.pin = annotation.pin
        }
    }
    
    func loadPins() {
        let annotations = coreDataManager.fetchCurrentPin()
        mapView.addAnnotations(annotations)
    }
    
    func setupMap() {
        mapView.delegate = self
        if UserDefaults.standard.bool(forKey: "hasLaunchBefore") {
            let centerCoordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "mapLatitude"), longitude: UserDefaults.standard.double(forKey: "mapLongitude"))
            let latitudeDelta = UserDefaults.standard.double(forKey: "mapLatitudeDelta")
            let longitudeDelta = UserDefaults.standard.double(forKey: "mapLongitudeDelta")
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion( center: centerCoordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "hasLaunchBefore")
        }
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didTapOnMap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapOnMap(gesture: UILongPressGestureRecognizer) {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            if gesture.state == UIGestureRecognizer.State.began {
                let location = gesture.location(in: weakSelf.mapView)
                let coordinate = weakSelf.mapView.convert(location, toCoordinateFrom: weakSelf.mapView)
                let pin = weakSelf.savePin(coordinate: coordinate)
                let annotation = TravelAnnotation()
                annotation.coordinate = coordinate
                annotation.pin = pin
                weakSelf.mapView.addAnnotation(annotation)
                weakSelf.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: coreDataManager.viewContext)
        pin.lat = coordinate.latitude
        pin.long = coordinate.longitude
        coreDataManager.saveContext()
        
        return pin
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "mapLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "mapLongitude")
        let zoom = mapView.region.span
        UserDefaults.standard.set(zoom.latitudeDelta, forKey: "mapLatitudeDelta")
        UserDefaults.standard.set(zoom.longitudeDelta, forKey: "mapLongitudeDelta")
    }
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "showPhoto", sender: view.annotation)
    }
}

