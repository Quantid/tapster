//
//  RegisterViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 10/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

extension String {
    func isValidEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
}

extension String {
    func isValidPassword() -> Bool {
        
        // Need to be completed
        if self.utf16Count < 8 {
            
            return false
        } else {
            
            return true
        }
    }
}

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    var inputboxWidth: CGFloat = 250
    var inputboxHeight: CGFloat = 43
    var gender = "male"
    var device = "iphone5"
    var screen = "welcome"
    
    var inputItemSpacing:[CGFloat] = []
    var inputFields: [UITextField] = []
    var imageInputboxes: [UIImageView] = []
    var textfieldNames:[String] = []

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let errorMessage:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))

    @IBOutlet weak var imageMasthead: UIImageView!
    @IBOutlet weak var labelAnchorCenter: UILabel!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var buttonGender: UIButton!
    @IBOutlet weak var labelOr: UILabel!

    @IBAction func actionToggleGender(sender: AnyObject) {
        
       if gender == "male" {
            
            var image = UIImage(named: "slider-female.png")
            buttonGender.setImage(image, forState: .Normal)
            gender = "female"
            
        } else {
            
            var image = UIImage(named: "slider-male.png")
            buttonGender.setImage(image, forState: .Normal)
            gender = "male"
        }
        
    }
    
    @IBAction func actionLogin(sender: AnyObject) {
        
        if screen == "welcome" {
            
            screen = "login"
            buttonRegister.hidden = true
            prepareSigningScreens()
        } else {
            
            processForm()
        }
    }
    
    @IBAction func actionRegister(sender: AnyObject) {
        
        if screen == "welcome" {
            
            screen = "register"
            buttonLogin.hidden = true
            prepareSigningScreens()
        } else {
            
            processForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.hidden = true // hide while checking if user is logged in
        
        // Set up variables
        
        switch screenSize.width {
            
        case 320:
            
            if screenSize.height == 480 {
                
                device = "iphone4"
            } else {
                
                device = "iphone5"
            }
        case 375:
            device = "iphone6"
            
        case 414:
            device = "iphone6plus"
            
        default:
            device = "iphone5"
        }
        
        buttonGender.hidden = true
        
        // Setup error message label
        
        //errorMessage = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        errorMessage.textColor = UIColor(red: 227/255, green: 89/255, blue: 89/255, alpha: 1.0)
        errorMessage.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14)
        errorMessage.center = CGPoint(x: (screenSize.width/2) , y: screenSize.height - screenSize.height/4)
        errorMessage.text = ""
        errorMessage.textAlignment = NSTextAlignment.Center
        
        view.addSubview(errorMessage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        buttonWidth = buttonRegister.frame.width
        buttonHeight = buttonRegister.frame.height
        
        switch screen {
            
            case "welcome":
                buttonRegister.center = CGPoint(x: (screenSize.width/2) , y: (screenSize.height/2) - (buttonHeight/2) - screenSize.height/22)
                buttonLogin.center = CGPoint(x: (screenSize.width/2) , y: (screenSize.height/2) + (buttonHeight/2) + screenSize.height/22)

            case "login":
                buttonLogin.center = CGPoint(x: (screenSize.width/2) , y: screenSize.height - (buttonHeight/2) - screenSize.height/10)

            case "register":
                buttonGender.center = CGPoint(x: (screenSize.width/2) , y: imageInputboxes[3].center.y + buttonHeight + 10)
                buttonRegister.center = CGPoint(x: (screenSize.width/2) , y: screenSize.height - (buttonHeight/2) - screenSize.height/10)

        default:
            println("Somthing...")
        }
    }

    override func viewDidAppear(animated: Bool) {
        
        // Checks user is logged in. If yes, jump to main screen.
        
        if PFUser.currentUser() != nil {
            
            performSegueWithIdentifier("jumpToMain", sender: self)
        }
        else {
            
            self.view.hidden = false
        }
    }
    
    func prepareSigningScreens(){
        
        // Hide unrequired UI items
        
        imageMasthead.hidden = true
        labelOr.hidden = true
        
        // Define position variables
        
        switch screen {
        case "login":
            // Define textfield names and UI item layout
        
            textfieldNames = ["Email", "Password"]
            
            inputItemSpacing = [190, 250]
            
            if device == "iphone6" || device == "iphone6plus" {
                
                inputItemSpacing = [220, 290]
            }
            
        case "register":
            // Define textfield names and UI item layout
            
            textfieldNames = ["Name", "Email", "Password", "Date of birth"]
         
            inputItemSpacing = [70, 130, 190, 250]
            
            if device == "iphone6" || device == "iphone6plus" {
                
                inputItemSpacing = [70, 150, 220, 290]
            }
            
            buttonGender.hidden = false
            
        default:
            println("something...")
        }
        
        // Create and position inputbox image item
        
        var image = UIImage(named: "inputbox.png")
        
        for var i = 0; i < inputItemSpacing.count; i++ {
            
            imageInputboxes.append(UIImageView(image: image))
            
            imageInputboxes[i].contentMode = UIViewContentMode.ScaleAspectFit
            imageInputboxes[i].center = CGPoint(x: (screenSize.width/2), y: inputItemSpacing[i])
            view.addSubview(imageInputboxes[i])
        }
        
        // Create and position textfield items
        
        let textfieldFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 42)
        
        for var i = 0; i < inputItemSpacing.count; i++ {
            
            inputFields.append(UITextField(frame: textfieldFrame))
            
            inputFields[i].font = UIFont(name: "HelveticaNeue-regular", size: 14)
            inputFields[i].textColor = UIColor(red: 163/255, green: 176/255, blue: 184/255, alpha: 1.0)
            inputFields[i].placeholder = textfieldNames[i]
            inputFields[i].center = CGPoint(x: (screenSize.width/2), y: inputItemSpacing[i])
            
            if textfieldNames[i] == "Password" {
                
                inputFields[i].secureTextEntry = true
            }
            
            view.addSubview(inputFields[i])
            
            inputFields[i].delegate = self
        }
        
        if screen == "register" {

            // Set up date picker for DOB field
            
            var datePickerView  : UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.Date
            inputFields[3].inputView = datePickerView
            datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        inputFields[3].text = dateFormatter.stringFromDate(sender.date)
    }

    
    func processForm() {

        var error = ""
        var maximumTextLength: [NSInteger] = []
        
        var email = inputFields[find(textfieldNames, "Email")!].text
        var password = inputFields[find(textfieldNames, "Password")!].text
        
        var name = ""
        var DOB = ""
        
        switch screen {
            
            case "login":
                maximumTextLength = [50, 35]

        case "register":
                maximumTextLength = [35, 50, 35, 14]
                
                name = inputFields[find(textfieldNames, "Name")!].text
                DOB = inputFields[find(textfieldNames, "Date of birth")!].text

        default:
            println("something...")
        }
        
        // Validate user input
        
        // Validate text length
        
        for var i = 0; i < maximumTextLength.count; i++ {
            
            if inputFields[i].text.utf16Count > maximumTextLength[i] {
                
                error = textfieldNames[i] + " is too long"
            }
            println(inputFields[i].text.utf16Count)
        }
        
        // Validate Email address
        
        if !email.isValidEmail() {
            
            error = "Invalid email address"
        }
        
        // Validate Password
        
        if !password.isValidPassword() {
            
            error = "Invalid password"
        }
        
        if email.lowercaseString == password.lowercaseString {
            
            error = "Email and password cannot be the same"
        }
        
        // Validate DOB
        
        if DOB == "" || DOB.utf16Count != 11 {
            
            error = "Enter a valid date of birth"
        }
        
        // Convert DOB from string to date
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        if let validateDOB: NSDate = dateFormatter.dateFromString(DOB) {
            
        }
        else {
            
            error = "Enter a valid date of birth"
        }
        
        // Register with Parse
        
        if error == "" {
            
            switch screen {
                
            case "login":
                
                    startActivityIndicator()
                    
                    var user = PFUser()
                    
                    PFUser.logInWithUsernameInBackground(email, password:password) {(user: PFUser!, signInError: NSError!) -> Void in
                        if user != nil {
                            
                            // Do stuff after successful login.
                            
                            self.performSegueWithIdentifier("jumpToMain", sender: self)
                        }
                        else {
                            
                            // The login failed. Check error to see why.
                            
                            if let errorString = signInError.userInfo?["error"] as? NSString {
                                
                                error = errorString
                            }
                            else {
                                
                                error = "Please try again later"
                            }
                        }
                        
                        self.stopActivityIndicator()
                        
                        self.errorMessage.text = error
                    }
            case "register":
                
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    let dateDOB = dateFormatter.dateFromString(DOB)

                    startActivityIndicator()
                    
                    var user = PFUser()
                    
                    user.username = email.lowercaseString
                    user.password = password
                    user.email = email.lowercaseString
                    user["name"] = name
                    user["gender"] = gender
                    user["DOB"] = dateDOB
                    
                    user.signUpInBackgroundWithBlock {(succeeded: Bool!, signUpError: NSError!) -> Void in
                        
                        if signUpError == nil {
                            // Hooray! Let them use the app now.
                            
                            self.performSegueWithIdentifier("jumpToMain", sender: self)
                        }
                        else {
                            
                            println(signUpError)
                            //Sign up failed
                            if let errorString = signUpError.userInfo?["error"] as? NSString {
                                
                                error = errorString
                            }
                            else {
                                
                                error = "Please try again later"
                            }
                        }
                        
                        self.stopActivityIndicator()
                        
                        self.errorMessage.text = error
                    }
            default:
                
                error = "Error: Try closing and relaunching the app"
            }
            
        }
        
        errorMessage.text = error
    }
    
    func startActivityIndicator() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 75, 75))
        activityIndicator.center = CGPoint(x: self.view.center.x, y: (self.view.center.y + screenSize.height/5))
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
    }
    
    // Get rid of keyboard when finished entering text
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Get rid of keyboard if user touches anywhere on the screen
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
    }
}




















