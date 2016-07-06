//
//  CameraOverlayViewController.swift
//  Custom Camera
//
//  Created by Ahmed Belal on 03/06/2015.
//  Copyright (c) 2015 Seena Studios. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class CameraViewController: UIViewController, FilterDisplayViewControllerDelegate{
    @IBOutlet var shutterButton: UIButton!
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var cameraPreview: GPUImageView!
    var filter: GPUImageBrightnessFilter!
    var camera: GPUImageStillCamera!
    var filterCount = 1
    var setup: Bool = false
    var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if !setup
        {
            cameraPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            
            camera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetPhoto, cameraPosition: AVCaptureDevicePosition.Back);
            camera.outputImageOrientation = UIInterfaceOrientation.Portrait;
            camera.horizontallyMirrorFrontFacingCamera = true
            
            filter = GPUImageBrightnessFilter();
            filter.brightness = 0.0
            camera.addTarget(filter);
            filter.addTarget(cameraPreview)
            camera.startCameraCapture()
            
            setup = true
            
            self.setupFlash()
        }
        
        
        camera.resumeCameraCapture()
        
    }
    
    func setupFlash()
    {
        if camera.inputCamera.hasFlash && camera.inputCamera.hasTorch
        {
            var error: NSError?
            do {
                try camera.inputCamera.lockForConfiguration()
            } catch let error1 as NSError {
                error = error1
            }
            if error == nil
            {
                camera.inputCamera.flashMode = AVCaptureFlashMode.Auto
                flashButton.setTitle("Auto", forState: UIControlState.Normal)
            }
            camera.inputCamera.unlockForConfiguration()
        }
        else
        {
            flashButton.setTitle("Off", forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    @IBAction func takePicture()
    {
        if shutterButton.tintColor != UIColor.redColor()
        {
            shutterButton.tintColor = UIColor.redColor()
            var error: NSError?
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(NSUserDefaults.standardUserDefaults().stringForKey("soundName")!, withExtension: "wav")!)
            } catch let error1 as NSError {
                error = error1
                audioPlayer = nil
            }
            if error == nil
            {
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
            }
        }
        else
        {
            shutterButton.tintColor = UIColor.whiteColor()
            audioPlayer.stop()
            
            if filterCount == 1
            {
                camera.capturePhotoAsImageProcessedUpToFilter(filter, withCompletionHandler: { (image, captureError) -> Void in
                    self.performSegueWithIdentifier("ID_CAMERA_PREVIEW", sender: image)
                    self.camera.pauseCameraCapture()
                })
            }
            else
            {
                camera.capturePhotoAsImageProcessedUpToFilter(filter.targets()[filter.targets().count - 1] as? GPUImageOutput, withCompletionHandler: { (image, captureError) -> Void in
                    self.performSegueWithIdentifier("ID_CAMERA_PREVIEW", sender: image)
                    self.camera.pauseCameraCapture()
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ID_CAMERA_PREVIEW"
        {
            let cameraPreviewController = segue.destinationViewController as! CameraPreviewController
            cameraPreviewController.imgPhoto = sender as? UIImage
        }
    }
    
    @IBAction func switchFlashMode()
    {
        if camera.inputCamera.hasTorch && camera.inputCamera.hasFlash
        {
            var error: NSError?
            do {
                try camera.inputCamera.lockForConfiguration()
            } catch let error1 as NSError {
                error = error1
            }
            if error == nil
            {
                switch camera.inputCamera.flashMode
                {
                case AVCaptureFlashMode.On:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.Auto
                    flashButton.setTitle("Auto", forState: UIControlState.Normal)
                case AVCaptureFlashMode.Auto:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.Off
                    flashButton.setTitle("Off", forState: UIControlState.Normal)
                case AVCaptureFlashMode.Off:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.On
                    flashButton.setTitle("On", forState: UIControlState.Normal)
                }
            }
            camera.inputCamera.unlockForConfiguration()
        }
        else
        {
            UIAlertView(title: "No Flash Detected", message: "No flash detected for this device.", delegate: nil, cancelButtonTitle: "Dismiss").show()
        }
    }
    
    @IBAction func switchCameraDevice()
    {
        if (camera.cameraPosition() == AVCaptureDevicePosition.Back && camera.frontFacingCameraPresent)
        {
            camera.captureSession.beginConfiguration()
            
            //Get the best preset we can for the front camera
            let frontCamera = self.getCamera(AVCaptureDevicePosition.Front)
            
            if frontCamera?.supportsAVCaptureSessionPreset(AVCaptureSessionPresetPhoto) == true
            {
                camera.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            }
            else if frontCamera?.supportsAVCaptureSessionPreset(AVCaptureSessionPresetHigh) == true
            {
                camera.captureSession.sessionPreset = AVCaptureSessionPresetHigh
            }
            else if frontCamera?.supportsAVCaptureSessionPreset(AVCaptureSessionPresetMedium) == true
            {
                camera.captureSession.sessionPreset = AVCaptureSessionPresetMedium
            }
            else
            {
                camera.captureSession.sessionPreset = AVCaptureSessionPresetLow
            }
            
            camera.captureSession.commitConfiguration()
            camera.rotateCamera()
            self.setupFlash()
        }
        else if (camera.cameraPosition() == AVCaptureDevicePosition.Front && camera.backFacingCameraPresent)
        {
            camera.rotateCamera()
            camera.captureSession.beginConfiguration()
            
            //The rear camera supports photo preset anyway, so no need to confirm
            camera.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            camera.captureSession.commitConfiguration()
            self.setupFlash()
        }
    }
    
    @IBAction func cancel()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func changeSound()
    {
        let soundSelection = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ID_CHANGE_SOUND") as! SoundSelectionViewController
        self.presentViewController(soundSelection, animated: true, completion: nil)
    }
    
    @IBAction func showFilters() {
        let filterDisplay = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ID_FILTER_DISPLAY") as! FilterDisplayViewController
        filterDisplay.delegate = self
        filterDisplay.camera = camera
        self.presentViewController(filterDisplay, animated: true, completion: nil)
    }
    
    func didFinishSelectingFilter(isClearFilter: Bool, selectedFilter: GPUImageOutput) -> Void
    {
        if isClearFilter
        {
            if filterCount == 2
            {
                let otherFilter = filter.targets()[0] as? GPUImageOutput
                otherFilter?.removeAllTargets()
                
                filterCount = 1
            }
            
            camera.addTarget(filter as GPUImageInput)
            filter.removeAllTargets()
            filter.addTarget(cameraPreview)
        }
        else
        {
            if filterCount == 2
            {
                let otherFilter = filter.targets()[0] as? GPUImageOutput
                otherFilter?.removeAllTargets()
            }
            else
            {
                filterCount = 2
            }
            
            camera.addTarget(filter as GPUImageInput)
            filter.removeAllTargets()
            filter.addTarget(selectedFilter as! GPUImageInput)
            selectedFilter.removeAllTargets()
            selectedFilter.addTarget(cameraPreview)
            
        }
    }
    
    
    func getCamera(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        for captureDevice in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        {
            let device = captureDevice as! AVCaptureDevice
            if device.position == position
            {
                return device
            }
        }
        
        return nil
    }
}
