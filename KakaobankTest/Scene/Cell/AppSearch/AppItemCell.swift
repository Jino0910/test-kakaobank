//
//  AppItemCell.swift
//  KakaobankTest
//
//  Created by rowkaxl on 05/05/2019.
//  Copyright © 2019 rowkaxl. All rights reserved.
//

import UIKit

class AppItemCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var downLoadButton: UIButton!
    @IBOutlet weak var inAppEnableLabel: UILabel!
    
    @IBOutlet weak var screenShotImageView1: UIImageView!
    @IBOutlet weak var screenShotImageView2: UIImageView!
    @IBOutlet weak var screenShotImageView3: UIImageView!
    @IBOutlet weak var screenShotWidth: NSLayoutConstraint!
    
    private let screenShotHeight: CGFloat = 180.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView.image = nil
        self.titleLabel.text = " "
        self.subTitleLabel.text = " "
        self.screenShotImageView1.image = nil
        self.screenShotImageView2.image = nil
        self.screenShotImageView3.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(model: AppInfoModel) {
        
        self.titleLabel.text = model.trackName
        self.subTitleLabel.text = model.artistName
        
        self.iconImageView.asyncImageLoad(url: model.artworkUrl100, cachedName: model.artworkUrl100, handler: { (iv, image) in
            guard let image = image else { return }
            iv.image = image
        })
        
        guard model.screenshotUrls.count >= 3 else { return }
        
        guard let screenShot1 =  model.screenshotUrls[0].string else { return }
        guard let screenShot2 =  model.screenshotUrls[1].string else { return }
        guard let screenShot3 =  model.screenshotUrls[2].string else { return }
        
        self.screenShotImageView1.asyncImageLoad(url: screenShot1, cachedName: screenShot1, handler: { (iv, image) in
            guard let image = image else { return }
            iv.image = image
        })
        
        self.screenShotImageView2.asyncImageLoad(url: screenShot2, cachedName: screenShot2, handler: { (iv, image) in
            guard let image = image else { return }
            iv.image = image
            
            self.screenShotWidth.constant = self.screenShotHeight * image.size.width / image.size.height
        })
        
        self.screenShotImageView3.asyncImageLoad(url: screenShot3, cachedName:screenShot3, handler: { (iv, image) in
            guard let image = image else { return }
            iv.image = image
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
