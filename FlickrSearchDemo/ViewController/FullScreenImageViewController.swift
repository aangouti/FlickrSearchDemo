//
//  FullScreenImageViewController.swift
//  FlickrSearchDemo
//
//  Created by Abbas Angouti on 6/13/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitleLabel: UILabel!
    var imageTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageTitleLabel.text = imageTitle
    }
}
