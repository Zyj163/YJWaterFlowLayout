//
//  WaterFlowCell.swift
//  WaterFlowCollectionView
//
//  Created by ddn on 16/9/20.
//  Copyright © 2016年 张永俊. All rights reserved.
//

import UIKit

class WaterFlowCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.layer.borderColor = UIColor.gray.cgColor
        textLabel.layer.borderWidth = 2
    }

}
