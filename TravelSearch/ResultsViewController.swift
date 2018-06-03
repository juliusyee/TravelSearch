//
//  ResultsViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/11/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import AlamofireSwiftyJSON

class ResultsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    //MARK: Outlets
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var noResultsView: UIView!
    
    //MARK: Private Instance Variables
    private var places = [Place]()
    var json : Any?
    var numRows: Int = 0
    var url : URL?
    var next_page_token : String?
    var next_next_page_token : String?
    var current_page = 1
    var detailsURL: String?
    var currentPlaceID: String?
    var latitude: String?
    var longitude: String?
    var placeLatitude: Double?
    var placeLongitude: Double?
    var iconLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        noResultsView.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target:nil,action:nil)
        callGooglePlace()
    }

    //MARK: UITableViewSource
    //Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Return number of rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numRows == 0{
            noResultsView.isHidden = false
            tableview.isHidden = true
        }else{
            noResultsView.isHidden = true
            tableview.isHidden = false
        }
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Place Cell", for: indexPath) as! TableViewCell
        let currentPlace = places[indexPath.row]
        if UserDefaults.standard.object(forKey: places[indexPath.row].getID()) != nil{
            cell.favoriteButton.setBackgroundImage(UIImage(named:"favorite-filled"), for: UIControlState.normal)
        }
        cell.place = currentPlace
        return cell
    }
    
    func callGooglePlace(){
        self.previousButton.isEnabled = false
        //Request Nearby Place Search JSON from PHP script
        Alamofire.request(url!).responseSwiftyJSON{
            response in
            let json = response.result.value //JSON object
            let isSuccess = response.result.isSuccess
            if(isSuccess && (json != nil)){
                //Let's process the JSON
                if let pagetoken = json!["next_page_token"].string{
                    self.next_page_token = pagetoken
                    self.nextButton.isEnabled = true
                }
                let results = json!["results"].array
                self.places.removeAll()
                self.numRows = 0
                for  element in results! {
                    self.numRows += 1
                    let icon = element["icon"].string
                    let id = element["place_id"].string
                    let name = element["name"].string
                    let addy = element["vicinity"].string
                    
                    let latty = element["geometry"]["location"].dictionaryObject
                    let placeLat = latty!["lat"] as? Double
                    let placeLng = latty!["lng"] as? Double
                    
                    let iconURL = URL(string:icon!)
                    if let data = try? Data(contentsOf: iconURL!){
                        let image: UIImage = UIImage(data: data)!
                        self.places.append(Place(address: addy!, placeid: id!, name: name!, icon: image, iconLink: icon!, lat: placeLat!, lng: placeLng!))
                    }
                }
            }
            [self.tableview.reloadData()]
            SwiftSpinner.hide()
        }
    }
    
    func getNextPage(requestURL: String, page: Int){
        Alamofire.request(requestURL).responseSwiftyJSON{
            response in
            let json = response.result.value //JSON object
            let isSuccess = response.result.isSuccess
            if(isSuccess && (json != nil)){
                //Let's process the JSON
                if let pagetoken = json!["next_page_token"].string{
                    if page == 2{
                        self.next_page_token = pagetoken
                    }
                    else{
                        self.next_next_page_token = pagetoken
                    }

                    self.nextButton.isEnabled = true
                }
                else{
                    self.nextButton.isEnabled  = false
                }
                let results = json!["results"].array
                self.places.removeAll()
                self.numRows = 0
                for  element in results! {
                    self.numRows += 1
                    let icon = element["icon"].string
                    let id = element["id"].string
                    let name = element["name"].string
                    let addy = element["vicinity"].string
                    
                    let latty = element["geometry"]["location"].dictionaryObject
                    let placeLat = latty!["lat"] as? Double
                    let placeLng = latty!["lng"] as? Double
                    
                    let iconURL = URL(string:icon!)
                    if let data = try? Data(contentsOf: iconURL!){
                        let image: UIImage = UIImage(data: data)!
                        self.places.append(Place(address: addy!, placeid: id!, name: name!, icon: image, iconLink: icon!, lat: placeLat!, lng:placeLng!))
                    }
                }
            }
            else
            {
                print("fail")
            }
            [self.tableview.reloadData()]
            SwiftSpinner.hide()
            self.previousButton.isEnabled = true
        }
    }
    
    //When a tableview cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        currentPlaceID = places[indexPath.row].getID()
        detailsURL = "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?placeID=\(currentPlaceID!)"
        iconLink = places[indexPath.row].getIconLink()
        placeLatitude = places[indexPath.row].getLatitude()
        placeLongitude = places[indexPath.row].getLongitude()
        self.performSegue(withIdentifier: "Details Segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Details Segue"{
            if let destination = segue.destination as? TabViewController{
                destination.url = detailsURL
                destination.placeID = currentPlaceID
                destination.latitude = placeLatitude
                destination.longitude = placeLongitude
                destination.iconLink = iconLink
            }
        }
    }
    
    //MARK: Action
    @IBAction func clickNextButton(_ sender: UIButton) {
        if current_page == 1{
            SwiftSpinner.show("Loading next page...")
            getNextPage(requestURL: "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?token=\(next_page_token!)",page: current_page)
            current_page = 2
        }
        else if current_page == 2{
            SwiftSpinner.show("Loading next page...")
            getNextPage(requestURL: "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?token=\(next_next_page_token!)",page: current_page)
            current_page = 3
        }
    }
    
    @IBAction func clickPrevButton(_ sender: UIButton) {
        if current_page == 2{
            SwiftSpinner.show("Loading previous page...")
            callGooglePlace()
            current_page = 1
        }
        else if current_page == 3{
            SwiftSpinner.show("Loading previous page...")
            getNextPage(requestURL: "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?token=\(next_page_token!)", page: current_page)
            current_page = 2
        }
    }
}
