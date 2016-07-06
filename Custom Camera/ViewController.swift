//
//  ViewController.swift
//  Custom Camera
//
//  Created by Ahmed Belal on 02/06/2015.
//  Copyright (c) 2015 Seena Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCameraButton() {
        
        //First we make sure that camera is available on the device.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true
        {
            self.performSegueWithIdentifier("ID_CAMERA", sender: nil)
        }
        else
        {
            let alert = UIAlertView(title: "No Camera Detected", message: "No camera was found on this device.", delegate: nil, cancelButtonTitle: "Dismiss")
            alert.show()
        }
    }
    
}



