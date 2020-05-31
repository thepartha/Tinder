//
//  UpdateViewController.swift
//  Tinder
//
//  Created by Partha Sarathy on 5/31/20.
//  Copyright © 2020 Partha Sarathy. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userGenderSwitch: UISwitch!
    @IBOutlet var interestedGenderSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // createWomen()
        errorLabel.isHidden = true
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            //userGenderSwitch.isOn = isFemale
            userGenderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFileObject {
        photo.getDataInBackground { (data, error) in
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    self.profileImageView.image = image
                }
            }
            }
        }
        
    }
    
    
    @IBAction func updateImageTapped(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func createWomen() {
        let imageUrls = ["https://images-na.ssl-images-amazon.com/images/I/9152ORj9hPL._AC_SL1500_.jpg","https://www.tomfornorthdakota.com/wp-content/uploads/2018/11/latest-hollywood-movies-posters-free-download-movie-posters-trailers-clips-banners-hd-movies-latest-hollywood-bollywood-movies.jpg", "https://4.bp.blogspot.com/-83OYg9W96JM/V-wCJ_MF33I/AAAAAAABXdc/SsjLJIMB5YY7PAfO6SuoyhR2GXzY7TfHQCLcB/s1600/inferno.jpg","https://m.media-amazon.com/images/M/MV5BMDJiNzUwYzEtNmQ2Yy00NWE4LWEwNzctM2M0MjE0OGUxZTA3XkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg","https://cdn.shopify.com/s/files/1/0969/9128/products/Alien_-_Tallenge_Classic_Sci-Fi_Hollywood_Movie_Poster_9c71a910-0ee1-40c8-990a-349576e433e3.jpg?v=1557383397", "https://lwlies.com/wp-content/uploads/2018/05/Jurassic-Park-film-poster-900x0-c-default.jpg"]
        var counter = 0
        for imageUrl in imageUrls {
            counter += 1
            if let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url) {
                    let imageFile = PFFileObject(name: "photo.png", data: data)
                    
                    let user = PFUser()
                    user["photo"] = imageFile
                    user.username = String(counter)
                    user.password = "12345"
                    user["isFemale"] = true
                    user["isInterestedInWomen"] = false
                    
                    user.signUpInBackground { (success, error) in
                        if success {
                            print("Users created")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestedGenderSwitch.isOn
        
        if let image = profileImageView.image {
            if let imageData =  image.pngData() {
                PFUser.current()?["photo"] = PFFileObject(name: "profile.png", data: imageData)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if error != nil {
                        var errorMessage = "Login failed"
                        if let safeError = error {
                            if let newerror = safeError as? NSError {
                                if let detailError = newerror.userInfo["error"] as? String {
                                    errorMessage = detailError
                                }
                            }
                            self.errorLabel.textColor = .red
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        }
                    } else {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Update Succesfull"
                        self.errorLabel.textColor = .green
                        
                        self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                    }
                })
            }
        }
    }
    
    

}
