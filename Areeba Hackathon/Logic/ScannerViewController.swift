//
//  ScannerViewController.swift
//  Areeba Hackathon
//
//  Created by Mohamad El Bohsaly on 3/14/20.
//

import UIKit
import AVFoundation
/*
 
 iOS has built-in support for scanning QR codes using AVFoundation
 * create a capture session, create a preview layer,
 * handle delegate callbacks, and more.
 * modify the found(code:) method to do something more interesting.

 Note: rotation when using the camera can be quite ugly, which is why most apps fix the orientation as you see below.
 
 */

//Capture metadata produced by a metadata object upon scanning

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer! //displays the video upon capturing
    let urlSession = URLSession.shared
    var token:String?
    
    /* -------- Capturing QR Code Logic --------*/
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCapture = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput:AVCaptureInput //input data to a capture session with ports for data streams
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCapture) //provides media from a capture device to a capture session
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        } else {
            captureFailed()
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main) //execute callbacks
            metaDataOutput.metadataObjectTypes = [.qr] //AVMetadataMachineReadableCodeObject instances generated from QR codes
            
        } else {
            captureFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame.size = CGSize(width: view.layer.bounds.width, height: view.layer.bounds.height/2)
        previewLayer.videoGravity = .resizeAspectFill //preserve the video’s aspect ratio and fill the layer’s bounds
        view.layer.addSublayer(previewLayer)

        //start the flow of data from the inputs to the outputs connected to the AVCaptureSession
        captureSession.startRunning()
                
    }
    
    /* Generic message to display capturing errors
    - Parameter recipient: None.
    - Throws: None.
    - Returns: void.
    */
    func captureFailed(){
        let alert = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    /* informs delegate about metadata obtained
    - Parameter recipient: Capture output, Metadata objects, and Capture session.
    - Throws: Nil.
    - Returns: void.
    */
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metaDataObject = metadataObjects.first {
            //Barcode information detected by a metadata capture output.
            guard metaDataObject is AVMetadataMachineReadableCodeObject else{
                return
            }
            
            guard let stringValue = metaDataObject.accessibilityValue else { return }
           
        
           token = stringValue
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("Accessibility value: \(stringValue)")
            
            //Invoke the API calls based on what we captured
            authentication()
            issuePayment(token: stringValue)
        }
        
        dismiss(animated: true) {
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    /* -------- HTTP Calls & Network --------*/
    /*
         Set up the HTTP request with URLSession
         Make the request with URLSessionDataTask
         Quickly print the returned response data
         Properly validate the response data
         Convert the response data to JSON
     */
    
    
    /* Authenticates user upon scanning his QR code
    - Parameter recipient: Nil.
    - Throws: Error.
    - Returns: void.
    */
    func authentication(){
        let url = URL(string: "https://api.areeba.com/oauth2/token")! //session singleton instance with no configuration
        var request = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: url, completionHandler: {
            data, response, error in
            
            //Handle response from server
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["Content-Type":"application/x-www-form-urlencoded",
                                           "Authorization":"Basic TjJndmVGTUxJTjhEa1I2VVNHZVZtdUV2d2NFYTpQaDRla3pJUmxGWmdJOFVqalFLQnhyc1Y1NW9h"]
            let bodyParameters = ["grant_type":"client_credentials"]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch let error{
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    

    /* Issue a purchase using the added card
    - Parameter recipient: Bearer token
    - Throws: Error.
    - Returns: void.
    */
    func issuePayment(token: String){
        let url = URL(string: "https://api.areeba.com/transfer/hackathon/pay")!
        var request = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: url, completionHandler: {
            data,response,error in
            
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["Content-Type":"application/json",
                                           "Accept":"application/vnd.areeba.cms+json; version=2.0",
                                           "Authorization":"Bearer \(token)"]
            
            let bodyParameters = ["merchantId":"TEST222204858001",
                                  "apiPassword":"60f2e352f77cb65ae57d05c2191a27e9",
                                  "amount":"AMOUNT",
                                  "currency":"USD",
                                  "cardNumber": "4508750015741019",
                                  "cardName": "areeba",
                                  "cardCVV": "100",
                                  "expiryMM": "05",
                                  "expiryYY": "21"]
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch let error{
                print(error.localizedDescription)
            }
            
        })
        
        task.resume()
    }
    
}
