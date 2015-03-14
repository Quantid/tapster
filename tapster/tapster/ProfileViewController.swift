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
    var busyIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let appDel = UIApplication.sharedApplication().delegate as AppDelegate

    @IBOutlet weak var mainScroll: UIScrollView!
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
        alert.addAction(UIAlertAction(title: "Photo album", style: UIAlertActionStyle.Default, handler: {
            action in
            userImage.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(userImage, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {
            action in
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
        
        let user = PFUser.currentUser()
        
        var nameFirstNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("nameFirst")
        var nameLastNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("nameLast")
        var countryNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("country")
        var imageUserPhotoNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("image")

        // Check if appdelegate variables have been set. That means this is segue back from the country table
        
        if appDel.placeholderNameFirst != "" {
            nameFirstNS = appDel.placeholderNameFirst
            nameLastNS = appDel.placeholderNameLast
            imageUserPhotoNS = appDel.placeholderProfilePhoto
        }
        
        
        if nameFirstNS == nil && nameLastNS == nil {

            if user["nameFirst"] == nil {
                let name: String = user["name"] as String
                var nameArray = name.componentsSeparatedByString(" ")
                
                inputNameFirst.text = nameArray[0]
                labelNickname.text = nameArray[0]

                if nameArray.count > 1 {
                    inputNameLast.text = nameArray[1]
                }
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
            
            if countryName != "" {
                inputCountry.text = countryName
            }
            else if let cn = countryNS as? String {
                inputCountry.text = cn
            }
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
        imageUserPhoto.layer.borderColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1.0).CGColor
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
        
        appDel.placeholderNameFirst = ""
        appDel.placeholderNameLast = ""
        appDel.placeholderProfilePhoto = nil
    }
    
    override func viewDidLayoutSubviews() {
        mainScroll.contentSize = CGSizeMake(320, screenSize.height);
    }
    
    func textFieldDidBeginEditing(inputCountry: UITextField) {
        appDel.placeholderNameFirst = inputNameFirst.text
        appDel.placeholderNameLast = inputNameLast.text
        appDel.placeholderProfilePhoto = UIImagePNGRepresentation(imageUserPhoto.image)

        performSegueWithIdentifier("jumpToCountryTable", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionUpdate(sender: AnyObject) {
        
        // Validate form

        var error = ""
        
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
                    // Success
                    user["nameFirst"] = self.inputNameFirst.text
                    user["nameLast"] = self.inputNameLast.text
                    user["name"] = self.inputNameFirst.text
                    user["country"] = self.inputCountry.text
                    
                    if self.imageUserPhoto != nil {
                        let imageData = UIImagePNGRepresentation(self.imageUserPhoto.image)
                        let imageFile = PFFile(name:"image.png", data:imageData)
                        user["profileImage"] = imageFile
                        NSUserDefaults.standardUserDefaults().setObject(imageData, forKey: "image")
                    }
                    
                    self.busyIndicator = activityIndicator.launchIndicator(self.view)

                    user.saveInBackgroundWithBlock {(success: Bool, saveError: NSError!) -> Void in
                    
                        if success {
                            NSUserDefaults.standardUserDefaults().setObject(self.inputNameFirst.text, forKey: "nameFirst")
                            NSUserDefaults.standardUserDefaults().setObject(self.inputNameLast.text, forKey: "nameLast")
                            NSUserDefaults.standardUserDefaults().setObject(self.inputCountry.text, forKey: "country")
                            
                            // Refresh user data
                            user.fetchInBackgroundWithBlock({(userData: PFObject!, fetchError: NSError!) -> Void in
                                if fetchError != nil {
                                    NSLog("Cannot refresh user's data. Error:@", fetchError)
                                }
                            })
                        }
                        self.updateCompleted()
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

    func updateCompleted() {

        activityIndicator.stopIndicator(busyIndicator)

        let alert = UIAlertView(title: "Saved", message: "Your profile has been updated", delegate: self, cancelButtonTitle: "OK")
        alert.alertViewStyle = .Default
        alert.show()
        
        viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Get rid of keyboard when finished entering text
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Get rid of keyboard if user touches anywhere on the screen
        self.view.endEditing(true)
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        // Managed slide-out side bar menu
        switch index {
        case 0:
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        case 1:
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PerformanceView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        case 2:
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RankingView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        case 3:
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        case 4:
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        default:
            println("default")
        }
    }
}
