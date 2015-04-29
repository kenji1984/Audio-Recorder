//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ken on 4/27/15.
//  Copyright (c) 2015 Ken. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        if var path = receivedAudio.filePathUrl as NSURL? {
            audioPlayer = AVAudioPlayer(contentsOfURL: path, error: nil)
            audioPlayer.enableRate = true
        } else {
            println("something wrong with the file")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fastPlay(sender: UIButton) {
        play(3.0)
    }
    
    @IBAction func slowPlay(sender: UIButton) {
        play(0.5)
    }

    @IBAction func stopPlay(sender: UIButton) {
        audioPlayer.stop()
    }
    
    func play(speed: Float) {
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.stop()
        audioPlayer.rate = speed
        audioPlayer.play()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playWithPitch(1500)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playWithPitch(-1000)
    }
    
    @IBAction func playWithPreset(sender: UIButton) {
        playWithReverb(AVAudioUnitReverbPreset.Cathedral, wetDryMix: 50.0)
    }
    
    func playWithPitch(pitch: Float) {
        //stops everything
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        //initialize audio player and pitch manipulator
        var audioPlayerNode = AVAudioPlayerNode()
        var pitchChanger = AVAudioUnitTimePitch()
        pitchChanger.pitch = pitch
        
        //add both audio player and pitch manipulator to engine
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(pitchChanger)
        
        //pass audio play through the pitch changer (change the pitch before output to speaker)
        audioEngine.connect(audioPlayerNode, to: pitchChanger, format: nil)
        
        //output to speaker
        audioEngine.connect(pitchChanger, to: audioEngine.outputNode, format: nil)
        
        //play the audio
        //audioPlayerNode requires AVAudioFile so need to convert NSURL file to AVAudioFile
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        //start the audio engine
        audioEngine.startAndReturnError(nil)
        //play
        audioPlayerNode.play()
    }
    
    func playWithReverb(preset: AVAudioUnitReverbPreset, wetDryMix: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()

        var reverbPreset = AVAudioUnitReverb()
        reverbPreset.loadFactoryPreset(preset)
        reverbPreset.wetDryMix = wetDryMix
        
        var audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine.attachNode(reverbPreset)
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: reverbPreset, format: nil)
        audioEngine.connect(reverbPreset, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }

}
