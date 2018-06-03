//
//  Review.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/23/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit

class Review{
    private var name: String
    private var rating: Double
    private var thumbnail:UIImage
    private var reviewText: String
    private var profileURL: String
    private var time:Int
    private var yelpTime: String?
    
    init(name:String, rating:Double, thumbnail:UIImage, review:String, time: Int, url: String){
        self.name = name
        self.rating = rating
        self.thumbnail = thumbnail
        self.reviewText = review
        self.profileURL = url
        self.time = time
    }
    
    //Getter functions
    func getThumbnail() -> UIImage{
        return thumbnail
    }
    func getName() -> String{
        return name
    }
    func getRating() -> Double{
        return rating 
    }
    func getReview() -> String{
        return reviewText
    }
    func getDate() -> String{
        let timeDouble = Double(self.time)
        let reviewTime = Date(timeIntervalSince1970: timeDouble)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: reviewTime)
    }
    func getSeconds() -> Int{
        return self.time
    }
    func setYelpTime(time: String ){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yelpDate = dateFormatter.date(from: time)
        self.time = Int((yelpDate?.timeIntervalSince1970)!)
        self.yelpTime = time
    }
    func getProfileURL() -> String{
        return profileURL
    }
}
