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
    
    override func viewWillAppear(_ animated: Bool)
    {
        if !setup
        {
            cameraPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            
            camera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetPhoto, cameraPosition: AVCaptureDevicePosition.back);
            camera.outputImageOrientation = UIInterfaceOrientation.portrait;
            camera.horizontallyMirrorFrontFacingCamera = true
            
            filter = GPUImageBrightnessFilter();
            filter.brightness = 0.0
            camera.addTarget(filter);
            filter.addTarget(cameraPreview)
            camera.startCapture()
            
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
                camera.inputCamera.flashMode = AVCaptureFlashMode.auto
                flashButton.setTitle("Auto", for: UIControlState())
            }
            camera.inputCamera.unlockForConfiguration()
        }
        else
        {
            flashButton.setTitle("Off", for: UIControlState())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    @IBAction func takePicture()
    {
        if shutterButton.tintColor != UIColor.red
        {
            shutterButton.tintColor = UIColor.red
            var error: NSError?
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: UserDefaults.standard.string(forKey: "soundName")!, withExtension: "wav")!)
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
            shutterButton.tintColor = UIColor.white
            audioPlayer.stop()
            
            if filterCount == 1
            {
                camera.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image, captureError) -> Void in
                    self.performSegue(withIdentifier: "ID_CAMERA_PREVIEW", sender: image)
                    self.camera.pauseCapture()
                })
            }
            else
            {
                camera.capturePhotoAsImageProcessedUp(toFilter: filter.targets()[filter.targets().count - 1] as? GPUImageOutput, withCompletionHandler: { (image, captureError) -> Void in
                    self.performSegue(withIdentifier: "ID_CAMERA_PREVIEW", sender: image)
                    self.camera.pauseCapture()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ID_CAMERA_PREVIEW"
        {
            let cameraPreviewController = segue.destination as! CameraPreviewController
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
                case AVCaptureFlashMode.on:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.auto
                    flashButton.setTitle("Auto", for: UIControlState())
                case AVCaptureFlashMode.auto:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.off
                    flashButton.setTitle("Off", for: UIControlState())
                case AVCaptureFlashMode.off:
                    camera.inputCamera.flashMode = AVCaptureFlashMode.on
                    flashButton.setTitle("On", for: UIControlState())
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
        if (camera.cameraPosition() == AVCaptureDevicePosition.back && camera.isFrontFacingCameraPresent)
        {
            camera.captureSession.beginConfiguration()
            
            //Get the best preset we can for the front camera
            let frontCamera = self.getCamera(AVCaptureDevicePosition.front)
            
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
        else if (camera.cameraPosition() == AVCaptureDevicePosition.front && camera.isBackFacingCameraPresent)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeSound()
    {
        let soundSelection = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_CHANGE_SOUND") as! SoundSelectionViewController
        self.present(soundSelection, animated: true, completion: nil)
    }
    
    @IBAction func showFilters() {
        let filterDisplay = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ID_FILTER_DISPLAY") as! FilterDisplayViewController
        filterDisplay.delegate = self
        filterDisplay.camera = camera
        self.present(filterDisplay, animated: true, completion: nil)
    }
    
    func didFinishSelectingFilter(_ isClearFilter: Bool, selectedFilter: GPUImageOutput) -> Void
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
    
    
    func getCamera(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        for captureDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
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
