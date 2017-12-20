//
//  FilterDisplayViewController.swift
//  Custom Camera
//
//  Created by Ahmed Belal on 07/06/2015.
//  Copyright (c) 2015 Seena Studios. All rights reserved.
//

import UIKit
import GPUImage

protocol FilterDisplayViewControllerDelegate
{
    func didFinishSelectingFilter(_ isClearFilter: Bool, selectedFilter: GPUImageOutput) -> Void
}

class FilterDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var camera: GPUImageStillCamera!
    var filters: [GPUImageOutput]!
    var delegate: FilterDisplayViewControllerDelegate?
    @IBOutlet var filterDisplayCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filters = []
        
        //A clear filter that does not make any difference
        let clear = GPUImageBrightnessFilter()
        clear.brightness = 0.0
        filters.append(clear)
        
        let haze = GPUImageHazeFilter()
        haze.slope = 0.3
        haze.distance = 0.3
        filters.append(haze)
        
        let sepia = GPUImageSepiaFilter()
        filters.append(sepia)
        
        let invert = GPUImageColorInvertFilter()
        filters.append(invert)
        
        let grayscale = GPUImageGrayscaleFilter()
        filters.append(grayscale)
        
        let amatorka = GPUImageAmatorkaFilter()
        filters.append(amatorka)
        
        let etikate = GPUImageMissEtikateFilter()
        filters.append(etikate)
        
        let softElegance = GPUImageSoftEleganceFilter()
        filters.append(softElegance)
        
        let gaussian = GPUImageGaussianBlurFilter()
        filters.append(gaussian)
        
        let zoom = GPUImageZoomBlurFilter()
        filters.append(zoom)
        
        let blur = GPUImageiOSBlurFilter()
        blur.saturation = 1.0
        blur.blurRadiusInPixels = 4
        filters.append(blur)
        
        let pixelate = GPUImagePixellateFilter()
        pixelate.fractionalWidthOfAPixel = 0.02
        filters.append(pixelate)
        
        let polka = GPUImagePolkaDotFilter()
        polka.dotScaling = 0.50
        polka.fractionalWidthOfAPixel = 0.01
        filters.append(polka)
        
        let halftone = GPUImageHalftoneFilter()
        filters.append(halftone)
        
        let sketch = GPUImageSketchFilter()
        filters.append(sketch)
        
        let toon = GPUImageToonFilter()
        filters.append(toon)
        
        let smoothToon = GPUImageSmoothToonFilter()
        filters.append(smoothToon)
        
        
     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.view.bounds.size.width / 2 - 20, height: self.view.bounds.size.width / 2 - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
         let filterDisplayCell: FilterDisplayCollectionCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "ID_FILTER_CELL", for: indexPath) as? FilterDisplayCollectionCell
        
        let filter = filters[indexPath.row]
        camera.addTarget(filter as! GPUImageInput)
        filterDisplayCell.filter = filter
        filter.removeAllTargets()
        filterDisplayCell.display.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        filter.addTarget(filterDisplayCell.display)
        
        return filterDisplayCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var isClearFilter: Bool = true
        if indexPath.row != 0
        {
            isClearFilter = false
        }
        
        camera.removeAllTargets()
        delegate?.didFinishSelectingFilter(isClearFilter, selectedFilter: filters[indexPath.row])
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let filterDisplayCell = cell as? FilterDisplayCollectionCell
        filterDisplayCell?.filter?.removeAllTargets()
    }
}

class FilterDisplayCollectionCell: UICollectionViewCell {
    @IBOutlet var display: GPUImageView!
    var filter: GPUImageOutput?
}
