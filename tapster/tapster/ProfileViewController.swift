//
//  ProfileViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 13/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SideBarDelegate {
    
    var sideBar:SideBar = SideBar()
    
    var countryCode: String = ""
    var countryName: String = ""

    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var imageUserPhoto: UIImageView!
    @IBOutlet weak var labelNickname: UILabel!
    @IBOutlet weak var inputCountry: UITextField!
    @IBOutlet weak var labelDOB: UILabel!
    @IBOutlet weak var inputNameFirst: UITextField!
    @IBOutlet weak var inputNameLast: UITextField!
    @IBOutlet weak var labelGender: UILabel!
    @IBOutlet weak var labelError: UILabel!

    @IBAction func actionMenu(sender: AnyObject) {
        
        sideBar.showSideBar(true)
    }

    @IBAction func actionPickPhoto(sender: AnyObject) {
        
        var userImage = UIImagePickerController()
        userImage.delegate = self
        userImage.allowsEditing = true

        // Generate photo album or camera alert menu
        
        var alert = UIAlertController(title: "Profile Photo", message: "Where do you want to get your photo?", preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo album", style: UIAlertActionStyle.Default, handler: {action in
            
            userImage.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(userImage, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {action in
            
            userImage.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(userImage, animated: true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageUserPhoto.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self

        self.view.backgroundColor = UIColor(red:45/255, green:55/255, blue:64/255, alpha:1.0)
        
        // Populate fields. But first check if NSUser defaults have been set. That means this is segue back from the country table
        
        let user = PFUser.currentUser()
        
        let nameFirstNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("nameFirst")
        let nameLastNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("nameLast")
        let imageUserPhotoNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("image")
        
        if nameFirstNS == nil && nameLastNS == nil {
            
            if user["nameFirst"] == nil {
                
                let name: String = user["name"] as String
                var nameArray = name.componentsSeparatedByString(" ")
                
                inputNameFirst.text = nameArray[0]
                
                if nameArray.count > 1 {
                    
                    inputNameLast.text = nameArray[1]
                }
                labelNickname.text = user["name"] as? String
            }
            else {
                
                labelNickname.text = user["nameFirst"] as? String
                inputNameFirst.text = user["nameFirst"] as String
                inputNameLast.text = user["nameLast"] as String
            }
            
            if let country = user["country"] as? String {
                
                inputCountry.text = country
            }
        }
        else {
            
            if let nf = nameFirstNS as? String {
                
                inputNameFirst.text = nf
                labelNickname.text = nf
            }
            
            if let nl = nameLastNS as? String {
                
                inputNameLast.text = nl
            }
            
            inputCountry.text = countryName
        }
        
        // Handle user photo
        
        if let imageData: NSData = imageUserPhotoNS as? NSData {
            
            imageUserPhoto.image = UIImage (data: imageData)
        }
        else {
            
            if let imageData = user["profileImage"] as? NSData {
                
                imageUserPhoto.image = UIImage (data: imageData)
            }
            else {
                
                imageUserPhoto.image = UIImage(named: "profile-silhuette.png")
            }
        }

        // Crop image photo to circle
        
        imageUserPhoto.contentMode = UIViewContentMode.ScaleAspectFit
        imageUserPhoto.layer.cornerRadius = imageUserPhoto.frame.size.width/2
        imageUserPhoto.layer.borderWidth = 5
        imageUserPhoto.layer.borderColor = UIColor(red: 138/255, green: 150/255, blue: 158/255, alpha: 1.0).CGColor
        imageUserPhoto.layer.masksToBounds = true

        // Date field
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        labelDOB.text = dateFormatter.stringFromDate(user["DOB"] as NSDate)
        
        // Gender field
        
        labelGender.text = user["gender"].uppercaseString
        
        // Country field
        
        inputCountry.delegate = self
        
        // Reset error label
        
        labelError.text = ""
        
        // Clear all NSUserDefaults
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("nameFirst")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("nameLast")
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("image")
    }
    
    func textFieldDidBeginEditing(inputCountry: UITextField) {
        
        NSUserDefaults.standardUserDefaults().setObject(inputNameFirst.text, forKey: "nameFirst")
        NSUserDefaults.standardUserDefaults().setObject(inputNameLast.text, forKey: "nameLast")
        NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(imageUserPhoto.image), forKey: "image")
        
        performSegueWithIdentifier("jumpToCountryTable", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionUpdate(sender: AnyObject) {
        
        // TO DO: activity swirl and saved alert box on completion.
        
        var error = ""
        
        // Validate form
        
        if inputNameFirst.text == "" || inputNameFirst.text == nil || inputNameFirst.text.utf16Count > 25 {
            
            error = "Invalid first name"
        }
        
        if inputNameLast.text.utf16Count > 30 {
            
            error = "Invalid last name"
        }
        
        if inputCountry.text == "" || inputCountry.text == nil {
            
            error = "Please select a country"
        }
        
        if error == "" {
           
            var query = PFQuery(className:"_User")
            let userId = PFUser.currentUser().objectId

            query.getObjectInBackgroundWithId(userId) {(user: PFObject!, error: NSError!) -> Void in
                
                if error == nil {

                    // Success. Now update user details
                    
                    user["nameFirst"] = self.inputNameFirst.text
                    user["nameLast"] = self.inputNameLast.text
                    user["country"] = self.countryCode.uppercaseString
                    
                    if self.imageUserPhoto != nil {
                        
                        let imageData = UIImagePNGRepresentation(self.imageUserPhoto.image)
                        let imageFile = PFFile(name:"image.png", data:imageData)
                        user["profileImage"] = imageFile
                    }
                    
                    self.startActivityIndicator()
                    
                    user.saveInBackgroundWithBlock {(success: Bool, saveError: NSError!) -> Void in
                    
                        if success {
                            
                            // Refresh user data
                            
                            user.fetchInBackgroundWithBlock({(userData: PFObject!, fetchError: NSError!) -> Void in
                                
                                if fetchError != nil {
                                    
                                    NSLog("Cannot refresh user's data. Error:@", fetchError)
                                }
                                
                                println(userData)
                            })
                        }
                        
                        self.stopActivityIndicator()
                    }
                }
                else {
                    
                    NSLog("Cannot update user profile information: %@", error)
                }
            }
        }
        else {
            
            labelError.text = error
        }
    }
    
    func startActivityIndicator() {
        
        // Setup activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 75, 75))
        activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        //Lock display from user interaction
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {
        
        activityIndicator.stopAnimating()
        
        //Unlock display for resumption of user interaction
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        // Show alert box message
        let alert = UIAlertView(title: "Updated", message: "", delegate: self, cancelButtonTitle: "OK")
        alert.alertViewStyle = .Default
        alert.show()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Get rid of keyboard when finished entering text
        textField.resignFirstResponder()
        
        return true
    }
    
    // Get rid of keyboard if user touches anywhere on the screen
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
    }

    // Managed slide-out side bar menu
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        
        switch index {
            
        case 0:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 1:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PerformanceView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 2:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 3:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        default:
            println("default")
        }
    }
}
