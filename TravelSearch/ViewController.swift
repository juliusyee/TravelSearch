//
//  ViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/6/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import McPicker
import GooglePlaces
import SwiftSpinner
import Alamofire
import EasyToast
import AlamofireSwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    @IBOutlet weak var favoritesTable: UITableView!
    let locationManager = CLLocationManager()
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var categoryPicker: McTextField!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var noFavoritesView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var userLatitude: Double?
    private var userLongitude: Double?
    private var currentPlaceLatitude: Double?
    private var currentPlaceLongitude: Double?
    var detailsURL: String?
    var currentPlaceID: String?
    var iconLink:String?
    
    private var favoritePlaces = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
        self.distanceTextField.delegate = self
        self.keywordTextField.delegate = self
        self.fromTextField.delegate = self
        self.favoritesTable.delegate = self
        self.favoritesTable.dataSource = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target:nil,action:nil)
        favoritesTable.isHidden = true
        noFavoritesView.isHidden = true
        retrieveUserDefaults()
        
        //Ask for authorization from user to get user's location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //Creates the scroll option text field using McPicker
        let data:[[String]] =  [["Default","Airport","Amusement Park","Aquarium","Art Gallery","Bakery","Bar","Beauty Salon","Bowling Alley", "Bus Station", "Cafe","Campground","Car Rental",  "Casino", "Lodging","Movie Theater","Museum","Night Club","Park","Parking","Restaurant","Shopping Mall","Stadium","Subway Station","Taxi Stand","Train Station","Transit Station","Travel Agency","Zoo"]]
        let mcInputView  = McPicker(data:data)
        mcInputView.backgroundColor  =  .gray
        mcInputView.backgroundColorAlpha = 0.25
        categoryPicker.inputViewMcPicker  =  mcInputView
        
        categoryPicker.doneHandler  =  {[weak categoryPicker] (selections) in
            categoryPicker?.text  = selections[0]!
        }
        categoryPicker.selectionChangedHandler  = {[weak categoryPicker](selections, componentThatChanged)  in
            categoryPicker?.text  = selections[componentThatChanged]
        }
        categoryPicker.cancelHandler  = {[weak categoryPicker] in
            categoryPicker?.text = "Default"
        }
        categoryPicker.textFieldWillBeginEditingHandler  = { [weak categoryPicker](selections)  in
            if categoryPicker?.text == ""{
                //Selections always default to the first value per component
                categoryPicker?.text = selections[0]
            }
        }
        
        self.favoritesTable.reloadData()
    }
    func retrieveUserDefaults(){
        favoritePlaces.removeAll()
        for (key,value) in UserDefaults.standard.dictionaryRepresentation(){
            let currentPlaceID = key
            if let currentPlaceDetails = value as? Dictionary<String,String>{
                if let currentPlaceName = currentPlaceDetails["name"]{
                    let currentPlaceAddress = currentPlaceDetails["address"]
                    let currentPlaceLink = currentPlaceDetails["link"]
                    let currentlat = currentPlaceDetails["latitude"]
                    let currentlng = currentPlaceDetails["longitude"]
                    let iconURL = URL(string:currentPlaceLink!)
                    if let data = try? Data(contentsOf: iconURL!){
                        let image: UIImage = UIImage(data: data)!
                        self.favoritePlaces.append(Place(address: currentPlaceAddress!, placeid: currentPlaceID, name: currentPlaceName, icon: image, iconLink: currentPlaceLink!, lat: Double(currentlat!)!, lng: Double(currentlng!)!))
                        print(currentPlaceName)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of favorites: \(favoritePlaces.count)")
        return favoritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorite Cell", for: indexPath) as! TableViewCell
        let currentPlace = favoritePlaces[indexPath.row]
        cell.place = currentPlace
        return cell 
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let toastMessage = "\(favoritePlaces[indexPath.row].getName()) was removed from favorites"
            self.view.showToast(toastMessage, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            UserDefaults.standard.removeObject(forKey: favoritePlaces[indexPath.row].getID())
            favoritePlaces.remove(at: indexPath.row)
            favoritesTable.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if favoritePlaces.count == 0{
                favoritesTable.isHidden = true
                noFavoritesView.isHidden = false
            }
        }
    }
    
    //When a tableview cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        currentPlaceID = favoritePlaces[indexPath.row].getID()
        iconLink = favoritePlaces[indexPath.row].getIconLink()
        currentPlaceLatitude = favoritePlaces[indexPath.row].getLatitude()
        currentPlaceLongitude = favoritePlaces[indexPath.row].getLongitude()
        detailsURL = "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?placeID=\(currentPlaceID!)"
        self.performSegue(withIdentifier: "Favorite Segue", sender: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else{return}
        userLatitude = locValue.latitude
        userLongitude = locValue.longitude
    }
    
    //MARK: UITextFieldDelegate
    //This function hides the keyboard when return key is hit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //This function sets the text field to whatever is typed
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField  ===  keywordTextField{
            keywordTextField.text = textField.text
        }
        else if textField === distanceTextField{
            distanceTextField.text = textField.text
        }
    }
    
    //Triggers the Google Autocomplete
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === fromTextField{
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController,animated:true,completion:nil)
        }
    }
    
    //Form validation --> cancel SearchSegue if form is not valid
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "SearchSegue"{
            //check that keyword/from location text fields are not just spaces/blank
            if (keywordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! || (fromTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
                self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                return false
            }
        }
        return true
    }
    
    //Pass data from source view controller (Search form) to destination view controller (Search results)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Pass the URL to the TableViewController
        if segue.identifier == "SearchSegue" {
            SwiftSpinner.show("Searching...")
            //Prepare the URL link
            let scheme = "http"
            let host = "phpenv.us-east-2.elasticbeanstalk.com"
            let path = "/index.php"
            let latitude: String = String(format:"%f",userLatitude!)
            let longitude: String = String(format:"%f",userLongitude!)
            let coordinates = latitude+","+longitude
            var locationText = fromTextField.text
            if (fromTextField.text == "Your location"){
                locationText = ""
            }
            var distanceText = distanceTextField.text
            if (distanceTextField.text == ""){
                distanceText = "10"
            }
            let queryItem1 = URLQueryItem(name: "keyword", value: keywordTextField.text)
            let queryItem2 = URLQueryItem(name: "category", value: categoryPicker.text)
            let queryItem3 = URLQueryItem(name: "distance", value: distanceText)
            let queryItem4 = URLQueryItem(name: "location", value: locationText)
            let queryItem5 = URLQueryItem(name: "here" , value: coordinates)
        
            var urlComponents = URLComponents()
            urlComponents.scheme = scheme
            urlComponents.host = host
            urlComponents.path = path
            urlComponents.queryItems = [queryItem1,queryItem2,queryItem3,queryItem4,queryItem5]
        
            if let destination = segue.destination as? ResultsViewController{
                destination.url = urlComponents.url!
                destination.latitude = latitude
                destination.longitude = longitude
            }
        }
        
        if segue.identifier == "Favorite Segue"{
            if let destination = segue.destination as? TabViewController{
                destination.url = detailsURL
                destination.placeID = currentPlaceID
                //destination.latitude = latitude
                //destination.longitude = longitude
                destination.iconLink = iconLink
            }
        }
    }
    
    //MARK: ACTION
    @IBAction func searchButton(_ sender: UIButton) {
        
    }
    @IBAction func clearButton(_ sender: UIButton) {
        keywordTextField.text = ""
        categoryPicker.text = "Default"
        distanceTextField.text = ""
        fromTextField.text = "Your location"
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let clickedSegment = segmentedControl.selectedSegmentIndex
        //if SEARCH is clicked
        if clickedSegment == 0{
            favoritesTable.isHidden = true
            noFavoritesView.isHidden = true
        }
        else{ // FAVORITES is clicked
            retrieveUserDefaults()
            if favoritePlaces.count == 0{
                noFavoritesView.isHidden = false
                favoritesTable.isHidden = true 
            }
            else{
                noFavoritesView.isHidden = true
                favoritesTable.isHidden = false
                self.favoritesTable.reloadData()
            }
        }
    }
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        fromTextField.text = place.formattedAddress
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

