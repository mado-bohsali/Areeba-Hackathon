//
//  ViewController.swift
//  Areeba Hackathon
//
//  Created by Mohamad El Bohsaly on 3/14/20.

//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Avoid crashes by setting the placeholders to empty text
        emailField.text = ""
        passwordField.text = ""
    }
    
    //Segue screen to Login screen
    func loadLoginScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedInViewController = storyBoard.instantiateViewController(identifier: "LoggedInViewController") as! LoggedInViewController
        self.present(loggedInViewController, animated: true, completion: nil)
    }

    /* Signs up the user by connecting him with Back4App server and creates new session if successful
    - Parameter recipient: UIView triggered.
    - Throws: NSError.
    - Returns: void.
    */
    @IBAction func signUpTrigger(_ sender: Any) {
        let user = PFUser()
        user.username = emailField.text
        user.password =  String(passwordField.text!.map { _ in return "•" })
        activityIndicator.startAnimating()
        
        user.signUpInBackground{
            (success, error) in
            self.activityIndicator.stopAnimating()
            if success {
                self.loadLoginScreen()
            } else{
                self.displayServerErrors(message: "Signing up wasn't successful")
            }
        }
    }
    
    /* Signs in the user by authenticating him with Back4App server (checks sessions)
    - Parameter recipient: UIView triggered.
    - Throws: NSError.
    - Returns: void.
    */
    @IBAction func signInTrigger(_ sender: Any) {
        activityIndicator.startAnimating()
        
        do {
            try PFUser.logIn(withUsername: self.emailField.text!, password: String(passwordField.text!.map { _ in return "•" }))
            loadLoginScreen()
            
        } catch {
            activityIndicator.stopAnimating()
            self.displayServerErrors(message: "Signing in wasn't successful")
        }
    }
    
    /* Generic error display function
    - Parameter recipient: message.
    - Throws: None.
    - Returns: void.
    */
    func displayServerErrors(message: String){
        let alert = UIAlertController(title: "Server-side Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in
            
        }
        
        alert.addAction(defaultAction)
        if let view = alert.popoverPresentationController{
            view.sourceView = self.view
            view.sourceRect = self.view.bounds
        }
        
        self.present(alert, animated: true) {
            
        }
    }
    
}

