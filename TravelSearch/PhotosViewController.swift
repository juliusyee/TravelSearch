//
//  PhotosViewController.swift
//  TravelSearch
//
//  Created by Julius Yee on 4/18/18.
//  Copyright © 2018 Julius Yee. All rights reserved.
//

import UIKit
import GooglePlaces

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
    var placeid : String?
    var images = [UIImage]()
    @IBOutlet weak var noPhotosView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        noPhotosView.isHidden = true
        /*
        //Load the images from Google Places
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeid!) { (photos, error) -> Void in
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
                            self.images.append(photo!)
                            self.collectionView.reloadData()
                        }
                    })
                }
            }
        }
 */
        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if images.count == 0{
            noPhotosView.isHidden = false
            collectionView.isHidden = true
        }
        else{
            noPhotosView.isHidden = true
            collectionView.isHidden = false
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image cell", for: indexPath) as! CollectionViewCell
        cell.image.image = images[indexPath.row]
        return cell
    }
}
