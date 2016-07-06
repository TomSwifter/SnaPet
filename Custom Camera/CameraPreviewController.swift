//
//  CameraPreviewController.swift
//  Custom Camera
//
//  Created by Ahmed Belal on 15/06/2015.
//  Copyright (c) 2015 Seena Studios. All rights reserved.
//

import UIKit

class CameraPreviewController: UIViewController {
    var imgPhoto: UIImage!
    @IBOutlet var imgPhotoPreivew: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        imgPhotoPreivew.image = imgPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func save()
    {
        let textToShare = "Check out this awesome pic I just took with Nature Capture! The only app that lets you take amazing pictures of your loved animals!"
        
        if let myImage = imgPhotoPreivew.image
        {
            
            let objectsToShare = [textToShare, myImage,]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
    
            }
    
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
