//
//  Place.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/9/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit

class Place{
    private var address: String
    private var place_id: String
    private var name: String
    private var icon: UIImage
    private var iconLink: String
    private var latitude: Double
    private var longitude: Double
    
    init(address: String, placeid: String, name: String, icon:UIImage, iconLink: String, lat: Double, lng: Double) {
        self.address = address
        self.place_id = placeid
        self.name = name
        self.icon = icon
        self.iconLink = iconLink
        self.latitude = lat
        self.longitude = lng
    }
    //Getter functions
    func getImage()->UIImage{
        return icon
    }
    func getAddress()->String{
        return address
    }
    func getID()->String{
        return place_id
    }
    func getName()->String{
        return name
    }
    func getIconLink() ->String{
        return iconLink 
    }
    func getLatitude()->Double{
        return latitude
    }
    func getLongitude()->Double{
        return longitude
    }
}
