//
//  ViewController.swift
//  Taskinator
//
//  Created by Viktor Todorov on 14.4.22.
//

import UIKit
import FacebookLogin
import RealmSwift

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]
        loginButton.center = view.center
        loginButton.delegate = self
        loginButton.tooltipColorStyle = FBTooltipView.ColorStyle.neutralGray
        view.addSubview(loginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isLoggedIn() {
            self.navigateToTasks()
        }
    }
    
    func getUserProfile(token: AccessToken?, userId: String?) {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
        graphRequest.start { _, result, error in
            if error == nil {
                let data: [String: AnyObject] = result as! [String: AnyObject]
                
                // Facebook Id
                if let facebookId = data["id"] as? String {
                    print("Facebook Id: \(facebookId)")
                } else {
                    print("Facebook Id: Not exists")
                }
                
                // Facebook First Name
                if let facebookFirstName = data["first_name"] as? String {
                    print("Facebook First Name: \(facebookFirstName)")
                } else {
                    print("Facebook First Name: Not exists")
                }
                
                // Facebook Middle Name
                if let facebookMiddleName = data["middle_name"] as? String {
                    print("Facebook Middle Name: \(facebookMiddleName)")
                } else {
                    print("Facebook Middle Name: Not exists")
                }
                
                // Facebook Last Name
                if let facebookLastName = data["last_name"] as? String {
                    print("Facebook Last Name: \(facebookLastName)")
                } else {
                    print("Facebook Last Name: Not exists")
                }
                
                // Facebook Name
                if let facebookName = data["name"] as? String {
                    print("Facebook Name: \(facebookName)")
                } else {
                    print("Facebook Name: Not exists")
                }
                
                // Facebook Profile Pic URL
                let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                
                // Facebook Email
                if let facebookEmail = data["email"] as? String {
                    print("Facebook Email: \(facebookEmail)")
                } else {
                    print("Facebook Email: Not exists")
                }
                
                print("Facebook Access Token: \(token?.tokenString ?? "")")
            } else {
                print("Error: Trying to get user's info")
            }
        }
    }

    func isLoggedIn() -> Bool {
        let accessToken = AccessToken.current
        let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
        return isLoggedIn
    }
    
    func navigateToTasks() {
        print("Navigation to Tasks....")

        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewID")
        sceneDelegate.window?.rootViewController = initialViewController
        sceneDelegate.window?.makeKeyAndVisible()
    }

}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result?.isCancelled ?? false {
            print("Cancelled")
        } else if error != nil {
            print("ERROR: Trying to get login results")
        } else {
            print("Logged in")
            self.navigateToTasks()
            // self.getUserProfile(token: result?.token, userId: result?.token?.userID)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Do something after the user pressed the logout button
        print("You logged out!")
    }
}
