//
//  SoundSelectionViewController.swift
//  Custom Camera
//
//  Created by Ahmed Belal on 14/06/2015.
//  Copyright (c) 2015 Seena Studios. All rights reserved.
//

import UIKit



class SoundSelectionViewController: UICollectionViewController {
    var sounds: NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        sounds = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("sounds", ofType: "plist")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sounds.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ID_SOUND_CELL", forIndexPath: indexPath) as! SoundCell

        let soundName: String = (sounds[indexPath.row] as! String)
        
        cell.soundLabel.text = soundName
        

        if  soundName == NSUserDefaults.standardUserDefaults().stringForKey("soundName")
        {
            cell.soundLabel.textColor = UIColor.blueColor()
        }
        else
        {
            cell.soundLabel.textColor = UIColor.blackColor()
        }
        // Configure the cell
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSUserDefaults.standardUserDefaults().setObject(sounds[indexPath.row], forKey: "soundName")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }


}

class SoundCell: UICollectionViewCell {
    @IBOutlet var soundLabel: UILabel!
}
