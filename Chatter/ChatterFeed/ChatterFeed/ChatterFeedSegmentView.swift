//
//  ChatterFeedSegment.swift
//  Chatter
//
//  Created by Austen Ma on 3/1/18.
//  Copyright © 2018 Austen Ma. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioToolbox
import Firebase

class ChatterFeedSegmentView: UIView, AVAudioPlayerDelegate {
    var shouldSetupConstraints = true
    var recordingURL: URL!
    var player: AVAudioPlayer?
    var multiplier: Float?
    
    var waveView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let playGesture = UITapGestureRecognizer(target: self, action:  #selector(self.playAudio (_:)))
        self.addGestureRecognizer(playGesture)
        
        let waveView = UIView()
        waveView.frame.size.height = 65
        waveView.frame.size.width = 300
        waveView.backgroundColor = UIColor(red: 119/255, green: 211/255, blue: 239/255, alpha: 1.0)
        waveView.layer.cornerRadius = 20
        self.addSubview(waveView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    @objc func playAudio(_ sender:UITapGestureRecognizer) {
        print("playing \(self.recordingURL)")
        
        player?.prepareToPlay()
        player?.currentTime = 0
        //            player?.volume = 10.0
        player?.play()
    }
    
    func generateAudioFile(audioURL: URL, id: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let audioRef = storageRef.child("audio/\(id)")
        audioRef.write(toFile: audioURL) { url, error in
            if let error = error {
                print("****** \(error)")
            } else {
                self.recordingURL = url
                
                do {
                    self.player = try AVAudioPlayer(contentsOf: self.recordingURL)
                    self.multiplier = self.calculateMultiplierWithAudio(audioUrl: self.recordingURL)
                    
                    // Generate wave form
                    self.generateWaveForm(audioURL: self.recordingURL)
                } catch let error as NSError {
                    //self.player = nil
                    print(error.localizedDescription)
                } catch {
                    print("AVAudioPlayer init failed")
                }

            }
        }
    }
    
    func calculateMultiplierWithAudio(audioUrl: URL) -> Float {
        let asset = AVURLAsset(url: audioUrl)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        
        return Float(audioDurationSeconds * 9.5)
    }
    
    func generateWaveForm(audioURL: URL) {
        let file = try! AVAudioFile(forReading: audioURL)//Read File into AVAudioFile
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)//Format of the file
        
        let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))//Buffer
        try! file.read(into: buf!)//Read Floats
        
        let waveForm = DrawWaveform()
        waveForm.frame.size.width = 300
        waveForm.frame.size.height = 65
        waveForm.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        // Set multiplier
        waveForm.multiplier = self.multiplier
        
        //Store the array of floats in the struct
        waveForm.arrayFloatValues = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count:Int(buf!.frameLength)))
        
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.addSubview(waveForm)
        }, completion: nil)
    }
}