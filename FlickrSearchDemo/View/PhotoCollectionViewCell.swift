//
//  PhotoCollectionViewCell.swift
//  FlickrGallery
//
//  Created by Abbas Angouti on 6/13/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var downloadTask: URLSessionDataTask? = nil
    

    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
