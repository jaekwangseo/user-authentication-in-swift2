//
//  ComposeViewController.swift
//  Selfie
//
//  Created by Subhransu Behera on 12/10/14.
//  Copyright (c) 2014 subhb.org. All rights reserved.
//

import UIKit

protocol SelfieComposeDelegate {
  func reloadCollectionViewWithSelfie(selfieImgObject: SelfieImage)
}

class ComposeViewController: UIViewController {
  @IBOutlet weak var thumbImgView: UIImageView!
  @IBOutlet weak var titleTextView: UITextView!
  @IBOutlet weak var activityIndicatorView: UIView!
  
  var thumbImg : UIImage!
  var composeDelegate:SelfieComposeDelegate! = nil
  let httpHelper = HTTPHelper()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.titleTextView.becomeFirstResponder()
        self.thumbImgView.image = thumbImg
        self.automaticallyAdjustsScrollViewInsets = false
        self.activityIndicatorView.layer.cornerRadius = 10
        
        setNavigationItems()
    }
  
  func setNavigationItems() {
    self.title = "Compose"
    
    let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBtnTapped"))
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem
    
    let postBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("postBtnTapped"))
    self.navigationItem.rightBarButtonItem = postBarButtonItem
  }
  
  func cancelBtnTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
    // hide activityIndicator view and display alert message
    self.activityIndicatorView.hidden = true
    let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
    errorAlert.show()
  }
  
    func postBtnTapped() {
        // resign the keyboard for text view
        self.titleTextView.resignFirstResponder()
        self.activityIndicatorView.hidden = false
        
        // Create Multipart Upload request
        if let imgData = UIImagePNGRepresentation(thumbImg) {
            let httpRequest = httpHelper.uploadRequest("upload_photo", data: imgData, title: self.titleTextView.text)
            
            httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
                // Display error
                if error != nil {
                    let errorMessage = self.httpHelper.getErrorMessage(error)
                    self.displayAlertMessage("Error", alertDescription: errorMessage as String)
                    
                    return
                }
                
               
                do {
                    let jsonDataDict = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
                    
                    let selfieImgObjNew = SelfieImage()
                    
                    selfieImgObjNew.imageTitle = jsonDataDict.valueForKey("title") as! String
                    selfieImgObjNew.imageId = jsonDataDict.valueForKey("random_id") as! String
                    selfieImgObjNew.imageThumbnailURL = jsonDataDict.valueForKey("image_url") as! String
                    
                    self.composeDelegate.reloadCollectionViewWithSelfie(selfieImgObjNew)
                    self.activityIndicatorView.hidden = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            })
        }
    }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
