//
//  ReviewCell.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/23/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var name: UILabel!
    var review: Review?{
        didSet{
            self.updateUI()
            reviewText.isUserInteractionEnabled = false
            date.isUserInteractionEnabled = false
            name.isUserInteractionEnabled = false
        }
    }
    
    func updateUI(){
        logo.image = review?.getThumbnail()
        reviewText.text = review?.getReview()
        name.text = review?.getName()
        rating.rating = (review?.getRating())!
        date.text = review?.getDate()
    }
}
