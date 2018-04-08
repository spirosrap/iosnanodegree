//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Spiros Raptis on 23/01/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import AVFoundation
class RecordSoundsViewController: UIViewController,AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pausButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    //It executes after the users presses the record button
    @IBAction func recordAUdio(sender: UIButton) {
        //First time recording
        if (pausButton.enabled){
            recordButton.enabled = false
            pausButton.enabled = true
            recordingInProgress.text = "Recording in Progress"
            recordingInProgress.hidden = false //SHOWs the label "recording in progress"
            stopButton.hidden = false
            pausButton.hidden = false
            print("in record audio")
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String //The path of the directory
            //the filename will be a wav file and named after the date (formatted specifically with ddMMyyyy-HHmmss)
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
            
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            let session = AVAudioSession.sharedInstance()
            
            
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch _ {
            } //The category specifies that an audio will be recored
            
//            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            let s = [String:AnyObject]()
            audioRecorder = try? AVAudioRecorder(URL: filePath!, settings: s)
            
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true //Audio-level metering is enabled
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }else{//Second,third,etc time recording
            recordingInProgress.text = "Recording"
            pausButton.enabled = true
            audioRecorder.record()
        }
    }
    //When user presses the pause button the recording pauses.
    @IBAction func pauseRecording(sender: UIButton) {
        if(audioRecorder.recording){
            audioRecorder.pause()
            recordingInProgress.text = "Tap to Resume Recording"
            recordButton.enabled = true
            pausButton.enabled = false
        }else{
            recordingInProgress.text = "Recording"
            pausButton.enabled = true
            audioRecorder.record()
        }
    }
    
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder) {
        print(audioRecorder.recording, terminator: "")
    }
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            //Save Recording Audio
            recordedAudio = RecordedAudio(filePathUrl: recorder.url,title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    //Stops the recording
    @IBAction func stopRecording(sender: AnyObject) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance() //Returns the singleton audio session.
        do {
            try audioSession.setActive(false)
        } catch _ {
        } //Deactivates the audio session after the audio recording stopped
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        } //We need to set the category back to playback. I don't use RecordAndPlayBack because it reduces the volume level.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        recordingInProgress.text = "Tap icon to Record"
        recordingInProgress.hidden = false
        recordButton.enabled = true
        stopButton.hidden = true
        pausButton.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

