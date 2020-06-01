//
//  ViewController.swift
//  Tinder
//
//  Created by Partha Sarathy on 5/30/20.
//  Copyright © 2020 Partha Sarathy. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var displayUserId = ""
    
    @IBOutlet var matchImageView: UIImageView!
    
    @IBAction func logoutTapped(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        
        matchImageView.addGestureRecognizer(gesture)
        
        updateImage()
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let point = geoPoint {
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
        }
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer){
        
        let labelPoint = gestureRecognizer.translation(in: view)
        
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 500)
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        matchImageView.transform = scaledAndRotated
        
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            
            if matchImageView.center.x < view.bounds.width / 2 - 100 {
                print("Not Intersted")
                acceptedOrRejected = "rejected"
            }
            
            if matchImageView.center.x > view.bounds.width / 2 + 100 {
                print("Interested")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserId != "" {
                PFUser.current()?.addUniqueObject(displayUserId, forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            
            matchImageView.transform = scaledAndRotated
            
            matchImageView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 )
            
            
        }
    }
    
    func updateImage(){
        if let query = PFUser.query() {
            
            query.whereKey("isFemale", equalTo: PFUser.current()?["isInterestedInWomen"])
            
            query.whereKey("isInterestedInWomen", equalTo: PFUser.current()?["isFemale"])
            
            var ignoredUsers: [String] = []
            
            if let accpetedUsers = PFUser.current()?["accepted"] as? [String]{
                ignoredUsers += accpetedUsers
            }
            
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }
            
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            
            if let geoPoint = PFUser.current()?["location"]  as? PFGeoPoint {
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1, longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1, longitude: geoPoint.longitude + 1))
            }
            
            query.limit = 1
            
            query.findObjectsInBackground { (objects, error) in
                
                if let users = objects {
                    
                    print(users.count)
                    
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFileObject {
                                imageFile.getDataInBackground { (data, error) in
                                    if let imageData = data {
                                        self.matchImageView.image = UIImage(data: imageData)
                                        if let objectID = object.objectId {
                                            self.displayUserId = objectID
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
}

