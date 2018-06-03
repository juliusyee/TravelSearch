//
//  TableViewCell.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/9/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import EasyToast

class TableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var placeName: UITextView!
    @IBOutlet weak var placeAddress: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var place: Place?{
        didSet{
            self.updateUI()
            placeName.isUserInteractionEnabled = false
            placeAddress.isUserInteractionEnabled = false
        }
    }
    
    func updateUI(){
        iconImage?.image = place?.getImage()
        placeAddress?.text = place?.getAddress()
        placeName?.text = place?.getName()
        
    }
    
    @IBAction func clickOnFavoriteButton(_ sender: UIButton) {
        if favoriteButton.currentBackgroundImage == UIImage(named: "favorite-empty"){
            favoriteButton.setBackgroundImage(UIImage(named:"favorite-filled"), for: UIControlState.normal)
            var placeDictionary = [String:String]()
            placeDictionary["name"] = place?.getName()
            placeDictionary["id"] = place?.getID()
            placeDictionary["address"] = place?.getAddress()
            placeDictionary["link"] = place?.getIconLink()
            placeDictionary["latitude"] = String(place!.getLatitude())
            placeDictionary["longitude"] = String(place!.getLongitude())
            UserDefaults.standard.set(placeDictionary, forKey: (place?.getID())!)
            print(placeDictionary)
            let toastMessage = "\(placeName.text!) was added to favorites"
            self.superview?.showToast(toastMessage, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
        else{
            favoriteButton.setBackgroundImage(UIImage(named:"favorite-empty"), for: UIControlState.normal)
            UserDefaults.standard.removeObject(forKey: (place?.getID())!)
            let toastMessage = "\(placeName.text!) was removed from favorites"
            self.superview?.showToast(toastMessage, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
    }
}
