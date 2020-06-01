//
//  MatchesViewController.swift
//  Tinder
//
//  Created by partha on 5/31/20.
//  Copyright © 2020 Partha Sarathy. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var images: [UIImage] = []
    var userIds: [String] = []
    var messages: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell",  for: indexPath) as? MatchTableViewCell {
            cell.messageLabel.text = "You haven't received a message yet."
            cell.profileImageView.image = images[indexPath.row]
            cell.recipientObjectId = userIds[indexPath.row]
            cell.messageLabel.text = messages[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query() {
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            if let acceptedPeeps = PFUser.current()?["accepted"] as? [String] {
                query.whereKey("objectId", containedIn: acceptedPeeps)
                
                query.findObjectsInBackground { (objects, error) in
                    if let users = objects {
                        for user in users {
                            if let theUser = user as? PFUser {
                                if let imageFile = theUser["photo"] as? PFFileObject {
                                    imageFile.getDataInBackground { (data, error) in
                                        if let imageData = data {
                                            if let image = UIImage(data: imageData) {
                                             
                                                if let objectId = theUser.objectId {
                                                    
                                                    let messagesQuery = PFQuery(className: "Message")
                                                    messagesQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId as Any)
                                                    messagesQuery.whereKey("sender", equalTo: theUser.objectId as Any)
                                                    messagesQuery.findObjectsInBackground { (objects, error) in
                                                        var messageText = "No message from this user."
                                                        if let objects = objects {
                                                            for message in objects {
                                                                if let content = message["content"] as? String {
                                                                    messageText = content
                                                                }
                                                            }
                                                        }
                                                        self.messages.append(messageText)
                                                        self.images.append(image)
                                                        self.userIds.append(objectId)
                                                        self.tableView.reloadData()
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
            
        }
        
    }
    
    
}
