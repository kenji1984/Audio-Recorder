//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ken on 4/27/15.
//  Copyright (c) 2015 Ken. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var pauseImage: UIImage!
    var recImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseImage = UIImage(named: "pause")
        recImage = UIImage(named: "rec")
    }
    
    override func viewWillAppear(animated: Bool) {
        //This function gets called everytime a view is refreshed.
        stopButton.hidden = true
        microphone.enabled = true
        pauseButton.hidden = true
        recordLabel.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBAction func recordButton(sender: UIButton) {
        recordLabel.text = "Recording..."
        stopButton.hidden = false
        microphone.enabled = false
        pauseButton.hidden = false
        
        //get the directory where iphone save their files
        let directory: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        //get the date and format type
        let date: NSDate = NSDate()
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        
        //format the date
        let dateString = formatter.stringFromDate(date) + ".wav"
        
        //append date to directory to make a full directory name
        let fileName = directory.stringByAppendingPathComponent(dateString)
        
        //convert to NSURL
        let fileURL = NSURL.fileURLWithPath(fileName)
        
        //create a shared audio session
        var audioSession = AVAudioSession.sharedInstance()
        
        //set category to play and record
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: fileURL, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        //if recorder finish successfully
        if(flag){
            //save the recorded audio
            var recordedAudio = RecordedAudio(url: recorder.url, name: recorder.url.lastPathComponent!)
            //recordedAudio.filePathUrl = recorder.url
            //recordedAudio.title = recorder.url.lastPathComponent!
            
            //move to the second scene of the app with the saved audio by performing a segue
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            
        } else {
            println("Recording did not finished successfully")
            microphone.enabled = true
            stopButton.hidden = true
            recordLabel.text = "Tap to Record"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //check which segue is about to start
        if(segue.identifier == "stopRecording") {
            //initialize destination view controller here and pass in the sender object
            let playSoundsViewController: PlaySoundsViewController = segue.destinationViewController
                as! PlaySoundsViewController
            
            //pass sender object (which is the object that initiated the segue aka. recordedAudio)
            let data = sender as! RecordedAudio
            
            //save the data to playSoundsViewController object property (need to add the property first)
            playSoundsViewController.receivedAudio = data
        }
    }

    @IBAction func stopButton(sender: UIButton) {
        //hide buttons and change text
        recordLabel.text = "Tap to Record"
        stopButton.hidden = true
        pauseButton.hidden = true
        
        //stop recording
        audioRecorder.stop()
    }
    
    @IBAction func pauseButton(sender: UIButton) {
        //pause the recording
        if pauseButton.currentImage == pauseImage {
            audioRecorder.pause()
            recordLabel.text = "Paused"
            pauseButton.setImage(recImage, forState: nil)
            pauseButton.setBackgroundImage(recImage, forState: nil)
        }
        else {
            audioRecorder.record()
            recordLabel.text = "Recording..."
            pauseButton.setImage(pauseImage, forState: nil)
            pauseButton.setBackgroundImage(pauseImage, forState: nil)
        }
    }
}

