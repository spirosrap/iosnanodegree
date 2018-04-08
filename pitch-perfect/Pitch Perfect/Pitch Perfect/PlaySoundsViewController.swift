//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Spiros Raptis on 24/01/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    var receivedAudio:RecordedAudio! // The variable that will save the audio and will be set by RecordSoundViewController
    var player = AVAudioPlayer()
    var audioEngine:AVAudioEngine!  // Used to generate audio
    var audioFile:AVAudioFile! // the file format used by audioPLayerNode
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
        do {
            player = try AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
            player.enableRate = true
        } catch _ {
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    //This action is executed when the user presses the fast(rabbit) button
    @IBAction func playFast(sender: AnyObject) {
        player.stop()
        audioEngine.stop()
        player.currentTime = 0
        player.rate = 2 //Play twice as fast
        player.play()
    }
    //This action is executed when the user presses the slow(snail) button
    @IBAction func playSlow(sender: AnyObject) {
        audioEngine.stop()
        player.stop()
        player.currentTime = 0
        player.rate = 0.5 //Play twice as slow
        player.play()
    }
    //This action is executed when the user presses stop Button. To stop playing the recording video.
    @IBAction func stopPlay(sender: AnyObject) {
        stopPlayerAndEngine()
    }
    //This action is executed when the user presses the high pitch(chipmunk) button
    @IBAction func playChipmunkAudio(sender: AnyObject) {
        stopPlayerAndEngine()
        playAudioWithVariablePitch(1000)
    }
    //This action is executed when the user presses the low pitch(darth vader) button
    @IBAction func playDarthvaderAudio(sender: AnyObject) {
        stopPlayerAndEngine()
        playAudioWithVariablePitch(-1000)
    }
    //This action is executed when the user presses the reverb button
    @IBAction func playReverbAudio(sender: AnyObject) {
        stopPlayerAndEngine()
        playAudioWithReverb()
    }
    //This action is executed when the user presses the echo button
    @IBAction func playEchoAudio(sender: AnyObject) {
        stopPlayerAndEngine()
        playAudioWithEcho()
        
    }
    
    //Stops the player and audioengine.
    func stopPlayerAndEngine(){
        player.stop()
        audioEngine.stop()
    }
    
    // MARK: - Effect functions
    
    //This function is used by the playChipmunkAudio and playDarthVaderAudio functions and does all the work required to
    //play the audio with the pitch effect give the pitch variable as an input.
    func playAudioWithVariablePitch(pitch: Float){
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        playWithEffect(changePitchEffect)
    }
    
    //This function is used by the playReverbAudio functions and does all the work required to
    //play the audio with the reverb effect and AVAudio Preset .LargeHall.
    func playAudioWithReverb(){
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.LargeHall)
        playWithEffect(reverbEffect)
    }
    
    //This function is used by the playEchoAudio functions and does all the work required to
    //play the audio with the echo effect and AVAudio Preset .MultiEcho1.
    func playAudioWithEcho(){
        let echoEffect = AVAudioUnitDistortion()
        echoEffect.loadFactoryPreset(.MultiEcho1)
        playWithEffect(echoEffect)
    }
    
    //Helper code used by playAudioWithEcho,playAudioWithReverb,playAudioWithVariablePitch
    func playWithEffect( effect:AVAudioUnit){
        player.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(effect) //Attaches the audio node we created to the audio engine
        
        //Connects the nodes to the audioEngine
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)//Schedule playing of an entire audio file
        do {
            try audioEngine.start()
        } catch _ {
        }//Starts the audio engine
        
        audioPlayerNode.play()
    }
    
}