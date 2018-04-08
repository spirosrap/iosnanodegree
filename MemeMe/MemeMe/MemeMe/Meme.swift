//
//  Meme.swift
//  imagepicker
//  The class that will hold the Meme with it's attributes: Top Text,BottomText,Image,and generated image
//  Created by Spiros Raptis on 11/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//

import Foundation
import UIKit
class Meme{
    var topText:String!
    var bottomText:String!
    var image: UIImage! //Original Image
    var memedImage: UIImage! //The generated image with Top and bottom text.

    init(let topText:String,let bottomText:String, let image:UIImage, let memedImage:UIImage){
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
    
}