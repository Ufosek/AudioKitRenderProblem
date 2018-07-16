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
        let documentsURL = FileManager.default.temporaryDirectory
        return documentsURL.appendingPathComponent("exported.m4a")

    }()
    

    
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
            self.outputFile = try AVAudioFile(forWriting: exportURL, settings: player.audioFile.fileFormat.settings)
            try AudioKit.renderToFile(self.outputFile, duration: self.player.duration, prerender: {
                self.player.play()
            })
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
    
    
}
