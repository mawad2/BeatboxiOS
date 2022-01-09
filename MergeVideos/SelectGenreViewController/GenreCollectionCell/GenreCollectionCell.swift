//
//  GenreCollectionCell.swift
//  MergeVideos
//
//  Created by Shahriyar Ahmed on 04/08/2018.
//  Copyright © 2018 Khoa Vo. All rights reserved.
//

import UIKit

class GenreCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var landScapeImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnGenre: UIButton!
    let myIndicator:UIActivityIndicatorView = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.medium)

    override func awakeFromNib() {
        myIndicator.hidesWhenStopped = true;
        myIndicator.center = self.contentView.center
        self.contentView.addSubview(myIndicator)
        self.contentView.bringSubview(toFront: myIndicator)
        myIndicator.startAnimating()
    }



}
