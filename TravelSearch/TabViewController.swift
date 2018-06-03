//
//  TabViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/18/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftSpinner
import TwitterKit
import EasyToast
import GooglePlaces

class TabViewController : UITabBarController{
    //MARK: Variables
    var placeID: String?
    var url: String?
    var latitude: Double?
    var longitude: Double?
    var placeName:String?
    var placeAddress:String?
    var placeWebsite: String?
    var iconLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Place Details")
        
        //Pass data to PhotoViewController
        let photovc = self.viewControllers![1] as! PhotosViewController
        photovc.placeid = placeID!
        //Load the images from Google Places
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID!) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                for element in (photos?.results)!{
                    GMSPlacesClient.shared().loadPlacePhoto(element, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            // TODO: handle the error.
                            print("Error: \(error.localizedDescription)")
                        } else {
                            photovc.images.append(photo!)
                        }
                    })
                }
            }
        }
        
        //Pass data to MapsViewController
        let mapvc = self.viewControllers![2] as! MapsViewController
        mapvc.latitude = latitude
        mapvc.longitude = longitude
        mapvc.placeID = placeID
        
        var yelpURL = ""
        //Call backend server for place details
        Alamofire.request(url!).responseSwiftyJSON{
            response in
            let json = response.result.value //JSON object
            let isSuccess = response.result.isSuccess
            if(isSuccess && (json != nil)){
                let result = json!["result"]
                //Pass Google Reviews to ReviewsViewController
                let reviewVC = self.viewControllers![3] as! ReviewsViewController
                let reviews = result["reviews"].array
                if reviews != nil{
                    for review in reviews!{
                        let currentRating = review["rating"].double
                        let currentName = review["author_name"].string
                        let currentURL = review["author_url"].string
                        let currentText = review["text"].string
                        let currentTime = review["time"].int
                        let profilePic = review["profile_photo_url"].string
                        let iconURL = URL(string:profilePic!)
                        if let data = try? Data(contentsOf: iconURL!){
                            let image: UIImage = UIImage(data: data)!
                            reviewVC.googleReviews.append(Review(name: currentName!, rating: currentRating!, thumbnail: image, review: currentText!, time: currentTime!, url: currentURL!))
                            reviewVC.defaultGoogleReviews.append(Review(name: currentName!, rating: currentRating!, thumbnail: image, review: currentText!, time: currentTime!, url: currentURL!))
                        }
                    }
                }
                //Pass Yelp Reviews to ReviewsViewController
                let addressComponents = result["address_components"].array
                var stateCode = ""
                var city = ""
                var countryCode = ""
                for component in addressComponents!
                {
                    if let obj = component.dictionaryObject{
                        if let obj2 = obj["types"] as? [String]{
                            for type in obj2{
                                if type == "locality"{
                                    city = (obj["short_name"] as? String)!
                                }
                                if type == "administrative_area_level_1"{
                                    stateCode = (obj["short_name"] as? String)!
                                }
                                if type == "country"{
                                    countryCode = (obj["short_name"] as? String)!
                                }
                            }
                        }
                    }
                }
                let name = result["name"].string?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                //name = name?.replacingOccurrences(of: " ", with: "+")
                //name = name?.replacingOccurrences(of: "-", with: "+")
                let address = result["formatted_address"].string?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                //address = address?.replacingOccurrences(of: ",", with: "")
                //address = address?.replacingOccurrences(of: " ", with: "+")
                //city = city.replacingOccurrences(of: " ", with: "+")
                city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                yelpURL = "http://hw92.us-east-2.elasticbeanstalk.com/index2.php?country=\(countryCode)&city=\(city)&state=\(stateCode)&name=\(name!)&addy=\(address!)"
                print(yelpURL)
                Alamofire.request(yelpURL).responseSwiftyJSON{
                    response in
                    let json = response.result.value //JSON object
                    let isSuccess = response.result.isSuccess
                    if(isSuccess && (json != nil)){
                        let reviews = json!["reviews"].array
                        for review in reviews!{
                            let yelpTime = review["time_created"].string
                            let yelpRating = review["rating"].double
                            let yelpText = review["text"].string
                            let yelpDict = review["user"].dictionaryObject
                            let yelpName = yelpDict!["name"] as? String
                            let yelpProfile = yelpDict!["image_url"] as? String
                            let yelpURL = review["url"].string
                            let iconURL2 = URL(string:yelpProfile!)
                            if let data2 = try? Data(contentsOf: iconURL2!){
                                let image: UIImage = UIImage(data: data2)!
                                let reviewToAdd = Review(name: yelpName!, rating: yelpRating!, thumbnail: image, review: yelpText!, time: 0, url: yelpURL!)
                                reviewToAdd.setYelpTime(time: yelpTime!)
                                reviewVC.defaultYelpReviews.append(reviewToAdd)
                                reviewVC.yelpReviews.append(reviewToAdd)
                            }
                        }
                    }
                    else{
                        print("YELP FAIL")
                    }
                }
                //Pass data to InfoViewController
                let infoVC = self.viewControllers![0] as! InfoViewController
                if let addy = result["formatted_address"].string {
                    infoVC.address.text = addy
                    self.placeAddress = addy
                }
                else{
                    infoVC.address.text = "No Address"
                }
                if let digits = result["international_phone_number"].string {
                    infoVC.phoneNumber.text = digits
                }
                else{
                    infoVC.phoneNumber.text = "No Phone Number"
                }
                if let site = result["website"].string {
                    infoVC.website.text = site
                    self.placeWebsite = site
                }
                else{
                    infoVC.website.text = "No Website"
                }
                if let goog = result["url"].string {
                    infoVC.google.text = goog
                }
                else{
                    infoVC.google.text = "No Google Page"
                }
                if let price_level = result["price_level"].int {
                    var dollas = ""
                    if price_level == 0 {dollas = "Free"}
                    else if price_level == 1 {dollas = "$"}
                    else if price_level == 2 {dollas = "$$"}
                    else if price_level == 3 {dollas = "$$$"}
                    else {dollas = "$$$$"}
                    infoVC.price.text = dollas
                }
                else{
                    infoVC.price.text = "No Price Level"
                }
                if let xx = result["rating"].double {
                    infoVC.rating.rating = xx
                }
                else{
                    infoVC.rating.rating = 0
                }
                
                //Navigation bar handling
                self.navigationItem.title = result["name"].string
                self.placeName = result["name"].string
                let twitterButton = UIBarButtonItem.init(image: UIImage(named: "forward-arrow"), style: .done, target: self, action: #selector(TabViewController.tweet))
                var favoriteButton = UIBarButtonItem.init(image: UIImage(named: "favorite-empty"), style: .done, target: self, action: #selector(TabViewController.tabFavorite))
                if UserDefaults.standard.object(forKey: self.placeID!) != nil{
                     favoriteButton = UIBarButtonItem.init(image: UIImage(named: "favorite-filled"), style: .done, target: self, action: #selector(TabViewController.tabFavorite))
                }
                self.navigationItem.rightBarButtonItems = [favoriteButton,twitterButton]
                SwiftSpinner.hide()
            }
            else
            {
                print("fail")
            }
        }
    }
    
    @objc func tabFavorite(){
        if self.navigationItem.rightBarButtonItems![0].image == UIImage(named: "favorite-empty"){
            self.navigationItem.rightBarButtonItems![0].image = UIImage(named: "favorite-filled")
            var placeDictionary = [String:String]()
            placeDictionary["name"] = placeName!
            placeDictionary["id"] = placeID!
            placeDictionary["address"] = placeAddress!
            placeDictionary["link"] = iconLink!
            placeDictionary["latitude"] = String(latitude!)
            placeDictionary["longitude"] = String(longitude!)
            UserDefaults.standard.set(placeDictionary, forKey: (placeID!))
            print(placeDictionary)
            let toastMessage = "\(placeName!) was added to favorites"
            self.view.showToast(toastMessage, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
        else{
            self.navigationItem.rightBarButtonItems![0].image = UIImage(named: "favorite-empty")
            UserDefaults.standard.removeObject(forKey: (placeID!))
            let toastMessage = "\(placeName!) was removed from favorites"
            self.view.showToast(toastMessage, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
    }
    
    @objc func tweet(){
        var tweetText = "Check out "
        if placeName != nil{
            tweetText += "\(placeName!) located at "
        }
        if placeAddress != nil{
            tweetText += "\(placeAddress!)"
        }
        if placeWebsite != nil{
            tweetText += "\nWebsite: \(placeWebsite!)"
        }
        tweetText = tweetText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        UIApplication.shared.open(URL(string: "https://twitter.com/intent/tweet?text=\(tweetText)")!, options: [:], completionHandler: nil)
    }
}
