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
        sounds = NSArray(contentsOfFile: Bundle.main.path(forResource: "sounds", ofType: "plist")!)
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ID_SOUND_CELL", for: indexPath) as! SoundCell

        let soundName: String = (sounds[indexPath.row] as! String)
        
        cell.soundLabel.text = soundName
        

        if  soundName == UserDefaults.standard.string(forKey: "soundName")
        {
            cell.soundLabel.textColor = UIColor.blue
        }
        else
        {
            cell.soundLabel.textColor = UIColor.black
        }
        // Configure the cell
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.set(sounds[indexPath.row], forKey: "soundName")
        UserDefaults.standard.synchronize()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }


}

class SoundCell: UICollectionViewCell {
    @IBOutlet var soundLabel: UILabel!
}
