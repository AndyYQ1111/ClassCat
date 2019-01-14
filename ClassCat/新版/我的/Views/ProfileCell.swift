//
//  ProfileCell.swift
//  ClassCat
//
//  Created by YueAndy on 2018/12/17.
//  Copyright © 2018年 pingan. All rights reserved.
//

import UIKit

class ProfileCell: BaseTableViewCell {

    @IBOutlet weak var lab_title: UILabel!
    @IBOutlet weak var img_title: UIImageView!
    @IBOutlet weak var lab_vue: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
