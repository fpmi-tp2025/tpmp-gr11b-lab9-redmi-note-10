//
//  BankMapViewController.swift
//  LimoBank
//
//  Created by Екатерина on 26.05.25.
//

import UIKit
import MapKit

class BankMapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        addBankLocations()
    }
    
    func setupMap() {
        mapView.delegate = self
        
        // Центрируем карту на Минск
        let coordinate = CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func addBankLocations() {
        let locations = [
            ("LimoBank - Центральное отделение", 53.9045, 27.5615),
            ("LimoBank - Восток", 53.9200, 27.5800),
            ("LimoBank - Запад", 53.8900, 27.5400)
        ]
        
        for (title, lat, lon) in locations {
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension BankMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "BankAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        return annotationView
    }
}
