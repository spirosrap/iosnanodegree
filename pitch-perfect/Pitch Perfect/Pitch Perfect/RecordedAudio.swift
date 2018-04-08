//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Spiros Raptis on 25/01/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
//Our class used to save the audio file attributes: Url of the path and the title.
class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl:NSURL,title:String){
        self.filePathUrl = filePathUrl
        self.title = title
        super.init()
    }
}
