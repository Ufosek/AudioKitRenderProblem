//
//  SongPlayer.swift
//  Copyright © 2018 Panowie Programisci. All rights reserved.
//

import Foundation
import AudioKit

class SongPlayer {

    
    //
    
    static let instance = SongPlayer()
    
    //
    
    fileprivate var player: AKAudioPlayer!
    fileprivate var mainMixer: AKMixer!

    //
    
    fileprivate var outputFile: AVAudioFile!
    
    
    
    
    
    
    let exportURL: URL = {
        //   let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("exported.m4a")
        
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        let url = URL(string: "\(documentsFolder[0])/exported2.m4a")!
        
        return url
    }()

    
    //


    
    init() {
        AKSettings.defaultToSpeaker = true
        AKSettings.audioInputEnabled = true
        AKSettings.bufferLength = .short
        AKSettings.enableLogging = true
        
        
    }
    
    func setup(songURL: String) {
        do {
            if let url = URL(string: songURL) {
                if let file = try? AKAudioFile(forReading: url) {
                    player = try AKAudioPlayer(file: file)
                } else {
                    fatalError("PLAYER ERROR")
                }
            }
        } catch {
            fatalError("PLAYER URL ERROR")
        }

        mainMixer = AKMixer(player)
        AudioKit.output = mainMixer
    }
    
    //
    
    var audioPlayer: AVAudioPlayer!
    
    func playTest() {
        let url = exportURL.absoluteString
        
        print("EXPORT = \(url)")
        
        guard FileManager.default.fileExists(atPath: url) else {
            fatalError("NO FILE!")
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            fatalError("PLAYER URL ERROR")
        }
    }

    func exportSavedData() -> Data {
        let url = exportURL.absoluteString
        
        print("EXPORT = \(url)")
        
        guard FileManager.default.fileExists(atPath: url) else {
            fatalError("NO FILE!")
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: url))
            return data
        } catch {
            fatalError("DATA URL ERROR")
        }
    }
    
    //
    
    func start() {
        do {
            try AudioKit.start()
        } catch {
            fatalError("Unexpected error: \(error).")
        }

        self.player.volume = 1.0

        self.player.play(from: 2, to: self.player.duration)
    }

    
    func stop() {
        do {
            try AudioKit.stop()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func export(songUrl: String) {
        self.setup(songURL: songUrl)

        do {
            try AudioKit.start()
            self.outputFile = try AVAudioFile(forWriting: exportURL, settings: player.audioFile.fileFormat.settings, commonFormat: .pcmFormatFloat32, interleaved: true) //(forWriting: exportURL, settings: player.audioFile.fileFormat.settings)
            try AudioKit.renderToFile(self.outputFile, duration: self.player.duration, prerender: {
                self.player.play()
            })
            
            print("AUDIO SAVE URL = \(self.outputFile.url.absoluteString)")
            
            self.player.stop()
            try AudioKit.stop()
        } catch {
            fatalError("Unexpected error: \(error).")
        }

        
        self.showFileSize()
    }

    
    func showFileSize () {
        let filePath = self.exportURL.absoluteString
        var fileSize : UInt64
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            
            print("EXPORT FILE SIZE = \(fileSize)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    //
    
    
    static func setAsPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                //try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }
    
    //
    
    static func setAsPlayRecord() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            //print("AVAudioSession Category Playback OK")
            do {
                // this causes strange noises :/
                //try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)
                try AVAudioSession.sharedInstance().setActive(true)
                
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }

    
}
