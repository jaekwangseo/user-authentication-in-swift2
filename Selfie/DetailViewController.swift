//
//  DetailViewController.swift
//  Selfie
//
//  Created by Subhransu Behera on 12/10/14.
//  Copyright (c) 2014 subhb.org. All rights reserved.
//

import UIKit

protocol SelfieEditDelegate {
  func deleteSelfieObjectFromList(selfieImgObject: SelfieImage)
}

class DetailViewController: UIViewController {
    @IBOutlet weak var detailTitleLbl: UILabel!
    @IBOutlet weak var detailThumbImgView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIView!

    var editDelegate:SelfieEditDelegate! = nil
    var selfieCustomObj : SelfieImage! = nil
    let httpHelper = HTTPHelper()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicatorView.layer.cornerRadius = 10
        self.detailTitleLbl.text = self.selfieCustomObj.imageTitle
        let imgURL = NSURL(string: self.selfieCustomObj.imageThumbnailURL)
        
        // Download an NSData representation of the image at the URL
        let request = NSURLRequest(URL: imgURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error == nil {
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.detailThumbImgView.image = image
                    })
                }
            } else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        })
        task.resume()

    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
  
    @IBAction func deleteBtnTapped(sender: AnyObject) {
        // show activity indicator
        self.activityIndicatorView.hidden = false
        
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("delete_photo", method: "DELETE", authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpRequest.HTTPBody = "{\"photo_id\":\"\(self.selfieCustomObj.imageId)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                
                return
            }
            
            self.editDelegate.deleteSelfieObjectFromList(self.selfieCustomObj)
            self.activityIndicatorView.hidden = true
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
}
