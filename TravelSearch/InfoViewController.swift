//
//  InfoViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/17/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import Cosmos

class InfoViewController: UIViewController{
    //MARK: Labels
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var phoneLabel: UITextView!
    @IBOutlet weak var priceLabel: UITextView!
    @IBOutlet weak var ratingLabel: UITextView!
    @IBOutlet weak var websiteLabel: UITextView!
    @IBOutlet weak var googleLabel: UITextView!
    //MARK: Content
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var phoneNumber: UITextView!
    @IBOutlet weak var price: UITextView!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var google: UITextView!
    @IBOutlet weak var rating: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
