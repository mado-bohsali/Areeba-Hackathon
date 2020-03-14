//
//  LoggedInViewController.swift
//  Areeba Hackathon
//
//  Created by Mohamad El Bohsaly on 3/14/20.
//  Copyright © 2020 Mohamad El Bohsaly. All rights reserved.
//

import UIKit
import Parse

class LoggedInViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    let urlSession = URLSession.shared
    let tokenCardCreation:String? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicator.isHidden = true
    }
    
    /* Logs the user out of his current session and deletes it
    - Parameter recipient: UIView triggered.
    - Throws: Error.
    - Returns: void.
    */
    @IBAction func LogOutTrigger(_ sender: Any) {
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.loadLoginScreen()
                self.activityIndicator.stopAnimating()
            } else {
                self.displayServerErrors(message: error!.localizedDescription)
            }
        }
    }
    
    /* Triggers API call to Areeba's add card functionality prior to displaying alert
    - Parameter recipient: UIView triggered.
    - Throws: None.
    - Returns: void.
    */
    
    @IBAction func addCardTrigger(_ sender: Any) {
        createVirtualCard(token: tokenCardCreation ?? "")
        
        let alert = UIAlertController(title: "Card Information", message: "Card has been successfully added!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        
    }
    
    /* Adds card by invoking an API call to Areeba's server
    - Parameter recipient: UIView triggered.
    - Throws: None.
    - Returns: void.
    */
    func createVirtualCard(token: String){
        let url = URL(string: "https://api.areeba.com/cms1/cards/virtual")!
        var request = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: url, completionHandler: {
            data,response,error in
            
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["Content-Type":"application/json",
                                           "Accept":"application/vnd.areeba.cms+json; version=1.0",
                                           "Authorization":"Bearer \(token)"]
            
            let bodyParameters = ["firstName": "Super",
                                  "lastName": "Man",
                                  "clientId" : "115870",
                                  "bankId":"157856685855",
                                  "contractProductType":"MCPRPVIRTUSD",
                                  "cardProductType":"MCPRPVIRT"]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch let error{
                print(error.localizedDescription)
            }
            
        })
        
        task.resume()
    }
    
    /* Segue to QR screen upon clicking Scan button
    - Parameter recipient: UIView triggered.
    - Throws: None.
    - Returns: void.
    */
    @IBAction func scanQRTrigger(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let scannerViewController = storyBoard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        
        scannerViewController.token = tokenCardCreation
        self.present(scannerViewController, animated: true, completion: nil)
    }
    
    /* Segue back to main view screen Log Out
    - Parameter recipient: UIView triggered.
    - Throws: None.
    - Returns: void.
    */
    func loadLoginScreen(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    /* Generic function to display errors
    - Parameter recipient: Error message triggered from other functions.
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
