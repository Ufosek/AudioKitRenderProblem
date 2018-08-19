//
//  SongPlayer.swift
//  Copyright © 2018 Panowie Programisci. All rights reserved.
//

import Foundation
import AudioKit


let EXPORT_FILE_NAME = "exported_audio.m4a"

class SongPlayer {
    
    
    //
    
    static let instance = SongPlayer()
    
    //
    
    fileprivate var player: AKAudioPlayer!
    fileprivate var mainMixer: AKMixer!
    fileprivate var reverb: AKReverb!
    
    //
    
    fileprivate var outputFile: AVAudioFile!

    //
    
    
    let exportURL: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(EXPORT_FILE_NAME)
    }()
    
    let exportURL_: String = { // for File attrs
         let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
         return "\(documentsFolder[0])/\(EXPORT_FILE_NAME)"
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
        
        player.volume = 1.0
        reverb = AKReverb(player, dryWetMix: 0.9)
        mainMixer = AKMixer(reverb)
        AudioKit.output = mainMixer
        
        do {
            try AudioKit.start()
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
    
    //
    
    
    //
    
    func setReverb(val: Double) {
        reverb.dryWetMix = val
    }
    
    func play() {
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
    }
    
    func stopEngine() {
        do {
            try AudioKit.stop()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func export(finished: (()->())?) {
        DispatchQueue.global().async {
            do {
                self.outputFile = try AVAudioFile(forWriting: self.exportURL, settings: self.player.audioFile.fileFormat.settings)
                try AudioKit.renderToFile(self.outputFile, duration: self.player.duration, prerender: {
                    self.player.play()
                })
                
                self.showFileSize()
                
                // This is doubled - Why?? After first render file is corrupted
                self.outputFile = try AVAudioFile(forWriting: self.exportURL, settings: self.player.audioFile.fileFormat.settings)
                try AudioKit.renderToFile(self.outputFile, duration: self.player.duration, prerender: {
                    self.player.play()
                })
                
                self.showFileSize()
                
                DispatchQueue.main.async {
                    finished?()
                }
            } catch {
                fatalError("Unexpected error: \(error).")
            }
        }
    }
    
    func showFileSize () {
        var fileSize : UInt64
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: exportURL_)
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
    
    static func setAsPlayRecord() {
        try! AKSettings.setSession(category: .playAndRecord, options: 0)
    }
    
    
}

