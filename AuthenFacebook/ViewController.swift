//
//  ViewController.swift
//  AuthenFacebook
//
//  Created by Apple Macintosh on 7/16/18.
//  Copyright © 2018 Apple Macintosh. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var emailFacebook: UILabel!
    @IBOutlet weak var nameFacebook: UILabel!
    @IBOutlet weak var lnameFacebook: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    // facebook button
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        let signInButton = GIDSignInButton(frame: CGRect(x: 92, y: 350, width: 190, height: 1))
        view.addSubview(signInButton)
        
        // facebook
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.delegate = self
        
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            fetchProfile()
        }
        
    }
    
    // Google Signin Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            let givenName = user.profile.givenName
            print(givenName)
            let familyName = user.profile.familyName
            print(familyName)
            let email = user.profile.email
            print(email)
            let image = user.profile.imageURL(withDimension: 400)
            print(image)
            self.emailFacebook.isHidden = false
            self.nameFacebook.isHidden = false
            self.lnameFacebook.isHidden = false
            self.emailFacebook.text = email
            self.nameFacebook.text = givenName
            self.lnameFacebook.text = familyName
            self.imgProfile.isHidden = false
            self.logOutButton.isHidden = false
            let dataImage = try? Data(contentsOf: image!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            self.imgProfile.image = UIImage(data: dataImage!)
            // ...
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    @IBAction func logOutPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        print("completed logout")
        self.emailFacebook.isHidden = true
        self.nameFacebook.isHidden = true
        self.lnameFacebook.isHidden = true
        self.imgProfile.isHidden = true
        self.logOutButton.isHidden = true
    }
    
    
    // facebook
    func fetchProfile() {
        print("fetch profile")
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            if error != nil {
                print(error)
                return
            }
            if let result = result as? [String:AnyObject],
                let email: String = result["email"] as! String?,
                let first_name: String = result["first_name"] as! String?,
                let last_name: String = result["last_name"] as! String?
            {
                print(email)
                print(first_name)
                print(last_name)
                self.emailFacebook.isHidden = false
                self.nameFacebook.isHidden = false
                self.lnameFacebook.isHidden = false
                self.emailFacebook.text = email
                self.nameFacebook.text = first_name
                self.lnameFacebook.text = last_name
                
                let picture = result["picture"] as? [String:AnyObject]
                let data = picture?["data"] as? [String:AnyObject]
                let imageUrl = data?["url"] as! NSString
                print(imageUrl)
                self.imgProfile.isHidden = false
                let url = URL(string: "\(imageUrl)")
                let dataImage = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                self.imgProfile.image = UIImage(data: dataImage!)
            }
        }
    }
    
    // facebook delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("completed login")
        fetchProfile()
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        self.emailFacebook.isHidden = true
        self.nameFacebook.isHidden = true
        self.lnameFacebook.isHidden = true
        self.imgProfile.isHidden = true
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

