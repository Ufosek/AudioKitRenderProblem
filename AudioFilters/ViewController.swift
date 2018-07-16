//
//  ViewController.swift
//  Copyright © 2018 Panowie Programisci. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var reverbSwitch: UISwitch!
    
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //
    
    @IBAction func exportClicked(_ sender: Any) {
        if let fileUrl = Bundle.main.path(forResource: "Born-to-Roll-clip", ofType: "m4a") {
            SongPlayer.instance.export(songUrl: fileUrl)
        }
    }
    
    @IBAction func startExported(_ sender: Any) {
        SongPlayer.instance.setup(songURL: SongPlayer.instance.exportURL.absoluteString)
        SongPlayer.instance.start()
    }

    @IBAction func playSongClicked(_ sender: Any) {
        if let fileUrl = Bundle.main.path(forResource: "Born-to-Roll-clip", ofType: "m4a") {
            SongPlayer.instance.setup(songURL: fileUrl)
            SongPlayer.instance.start()
        }
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        SongPlayer.instance.stop()
    }
    
}

