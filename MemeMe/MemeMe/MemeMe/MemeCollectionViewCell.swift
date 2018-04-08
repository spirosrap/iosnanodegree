//
//  MemeCollectionViewCell.swift
//  MemeMe
//  The cell for collection view.It keeps the meme image.
//  Created by spiros on 14/3/15.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView! //This is the icon for deletion. It displays when the edit button of the view is toggled.
}
