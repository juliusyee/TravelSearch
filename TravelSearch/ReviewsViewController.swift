//
//  ReviewsViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/18/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit

class ReviewsViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var reviewControl: UISegmentedControl!
    @IBOutlet weak var sortTypeControl: UISegmentedControl!
    @IBOutlet weak var upDownControl: UISegmentedControl!
    @IBOutlet weak var reviewTable: UITableView!
    @IBOutlet weak var noReviewsView: UIView!
    
    var googleReviews = [Review]()
    var defaultGoogleReviews = [Review]()
    var yelpReviews = [Review]()
    var defaultYelpReviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTable.delegate = self
        reviewTable.dataSource = self
        noReviewsView.isHidden = true
        self.reviewTable.reloadData()
    }
    
    //Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Return number of rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        if reviewType == "Google Reviews"{
            if googleReviews.count == 0{
                noReviewsView.isHidden = false
                reviewTable.isHidden = true
            }
            else{
                noReviewsView.isHidden = true
                reviewTable.isHidden = false
            }
            return googleReviews.count
        }
        else{
            if yelpReviews.count == 0{
                noReviewsView.isHidden = false
                reviewTable.isHidden = true
            }
            else{
                noReviewsView.isHidden = true
                reviewTable.isHidden = false
            }
            return yelpReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Review Cell", for: indexPath) as! ReviewCell
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        if reviewType == "Google Reviews"{
            if sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex) == "Default"{
                //upDownControl.setEnabled(false, forSegmentAt: 0)
                //upDownControl.setEnabled(false, forSegmentAt: 1)
                cell.review = defaultGoogleReviews[indexPath.row]
            }
            else{
                //upDownControl.setEnabled(true, forSegmentAt: 0)
                //upDownControl.setEnabled(true, forSegmentAt: 1)
                cell.review = googleReviews[indexPath.row]
            }
        }
        else{
            if sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex) == "Default"{
                //upDownControl.setEnabled(false, forSegmentAt: 0)
                //upDownControl.setEnabled(false, forSegmentAt: 1)
                cell.review = defaultYelpReviews[indexPath.row]
            }
            else{
                //upDownControl.setEnabled(true, forSegmentAt: 0)
                //upDownControl.setEnabled(true, forSegmentAt: 1)
                cell.review = yelpReviews[indexPath.row]
            }
        }
        return cell
    }
    
    //when review is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        let sortType = sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex)
        if reviewType == "Google Reviews"{
            if sortType == "Default"{
                UIApplication.shared.open(URL(string: defaultGoogleReviews[indexPath.row].getProfileURL())!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.open(URL(string: googleReviews[indexPath.row].getProfileURL())!, options: [:], completionHandler: nil)
            }
        }
        else{
            if sortType == "Default"{
                UIApplication.shared.open(URL(string: defaultYelpReviews[indexPath.row].getProfileURL())!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.open(URL(string: yelpReviews[indexPath.row].getProfileURL())!, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    //if the type of review is changed
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        let sortType = sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex)
        let orderType = upDownControl.titleForSegment(at: upDownControl.selectedSegmentIndex)
        sortReviews(reviewType: reviewType!, sortType: sortType!, orderType: orderType!)
        self.reviewTable.reloadData()
    }
    
    @IBAction func sortByChanged(_ sender: UISegmentedControl) {
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        let sortType = sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex)
        let orderType = upDownControl.titleForSegment(at: upDownControl.selectedSegmentIndex)
        sortReviews(reviewType: reviewType!, sortType: sortType!, orderType: orderType!)
        self.reviewTable.reloadData()
    }
    
    @IBAction func orderChange(_ sender: UISegmentedControl) {
        let reviewType = reviewControl.titleForSegment(at: reviewControl.selectedSegmentIndex)
        let sortType = sortTypeControl.titleForSegment(at: sortTypeControl.selectedSegmentIndex)
        let orderType = upDownControl.titleForSegment(at: upDownControl.selectedSegmentIndex)
        sortReviews(reviewType: reviewType!, sortType: sortType!, orderType: orderType!)
        self.reviewTable.reloadData()
    }
    
    func sortReviews(reviewType:String,sortType:String,orderType:String){
        if reviewType == "Google Reviews"{
            if sortType == "Rating"{
                if orderType == "Ascending"{
                    googleReviews.sort{$0.getRating() > $1.getRating()}
                }
                else{
                    googleReviews.sort{$0.getRating() < $1.getRating()}
                }
            }
            else if sortType == "Date"{
                if orderType == "Ascending"{
                    googleReviews.sort{$0.getSeconds() > $1.getSeconds()}
                }
                else{
                    googleReviews.sort{$0.getSeconds() < $1.getSeconds()}
                }
            }
        }
        else{ //yelp reviews
            if sortType == "Rating"{
                if orderType == "Ascending"{
                    yelpReviews.sort{$0.getRating() > $1.getRating()}
                }
                else{
                    yelpReviews.sort{$0.getRating() < $1.getRating()}
                }
            }
            else if sortType == "Date"{
                if orderType == "Ascending"{
                    yelpReviews.sort{$0.getSeconds() > $1.getSeconds()}
                }
                else{
                    yelpReviews.sort{$0.getSeconds() < $1.getSeconds()}
                }
            }
        }
    }
}
