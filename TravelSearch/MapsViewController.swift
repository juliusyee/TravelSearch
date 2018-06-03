//
//  MapsViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/18/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire 
import AlamofireSwiftyJSON
import SwiftyJSON

class MapsViewController:UIViewController, UITextFieldDelegate{
    //MARK: Variables
    @IBOutlet weak var fromLocation: UITextField!
    @IBOutlet weak var travelMode: UISegmentedControl!
    @IBOutlet weak var map: GMSMapView!
    var fromLat: Double?
    var fromLon: Double?
    var latitude: Double?
    var longitude: Double?
    var placeID: String?
    private var lines = [GMSPolyline]()
    private var markers = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromLocation.delegate = self 
        //Create a map
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 10)
        self.map.camera = camera
        //Add a marker to the map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude:longitude! )
        marker.map = map
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === fromLocation){
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
            present(autocompleteController,animated:true,completion:nil)
        }
    }
    
    //obtain directions
    func obtainDirections(mode: String){
        let originText = fromLocation.text?.replacingOccurrences(of: " ", with: "+")
        let originText2 = originText?.replacingOccurrences(of: ",", with: "")
        var trueMode = ""
        if mode == "Driving" { trueMode = "driving"}
        else if mode == "Bicycling"{ trueMode = "bicycling"}
        else if mode == "Transit" { trueMode = "transit"}
        else {trueMode = "walking"}
        let baseURL = "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?mode=\(trueMode)&id=\(placeID!)&origin=\(originText2!)"
        
        //Get the geocode info for the From location
        let geocodeURL = "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?address=\(originText2!)"
        Alamofire.request(geocodeURL).responseSwiftyJSON{
            response in
            let json = response.result.value //JSON object
            let isSuccess = response.result.isSuccess
            if(isSuccess && (json != nil)){
                let latty = json!["results"][0]["geometry"]["location"].dictionaryObject
                self.fromLat = latty!["lat"] as? Double
                self.fromLon = latty!["lng"] as? Double
                let fromMarker = GMSMarker()
                fromMarker.position = CLLocationCoordinate2D(latitude: self.fromLat!, longitude:self.fromLon! )
                fromMarker.map = self.map
                self.markers.append(fromMarker)
            }
            else{
                print("fail")
            }
            
        }
        //Remove previous routes and markers
        for line in self.lines{
            line.map = nil
        }
        for marker in self.markers{
            marker.map = nil
        }
        
        //Get the directions and draw the route on the map
        Alamofire.request(baseURL).responseSwiftyJSON{
            response in
            let json = response.result.value //JSON object
            let isSuccess = response.result.isSuccess
            if(isSuccess && (json != nil)){
                let routes = json!["routes"].arrayValue
                for route in routes{
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.map = self.map
                    self.lines.append(polyline)
                    
                    let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: self.fromLat!, longitude: self.fromLon!), coordinate: CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!))
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                    self.map.moveCamera(update)
                }
            }
        }
    }
    
    @IBAction func changeTravelMode(_ sender: UISegmentedControl) {
        let clickedSegment = travelMode.selectedSegmentIndex
        obtainDirections(mode: travelMode.titleForSegment(at: clickedSegment)!)
    }
}

extension MapsViewController: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        fromLocation.text = place.formattedAddress
        obtainDirections(mode: travelMode.titleForSegment(at: travelMode.selectedSegmentIndex)!)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


