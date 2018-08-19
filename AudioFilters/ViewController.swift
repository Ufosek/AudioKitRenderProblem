//
//  ViewController.swift
//  Copyright © 2018 Panowie Programisci. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var player: AVAudioPlayer!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SongPlayer.setAsPlayRecord()
    }
    
    @IBAction func renderAndPlayClicked(_ sender: Any) {
        if let fileUrl = Bundle.main.path(forResource: "Born-to-Roll-clip", ofType: "m4a") {
            SongPlayer.instance.setup(songURL: fileUrl)
        }

        SongPlayer.instance.export {
            do {
                self.player = try AVAudioPlayer(contentsOf: SongPlayer.instance.exportURL)
                self.player.prepareToPlay()
                self.player.play()
            } catch {
                fatalError("PLAYER URL ERROR = \(error)")
            }
        }
    }
    
}

