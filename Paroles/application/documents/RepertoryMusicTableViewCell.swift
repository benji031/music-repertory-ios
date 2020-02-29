//
//  RepertoryMusicTableViewCell.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 30/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

class RepertoryMusicTableViewCell: UITableViewCell {

    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var musicNameLabel: UILabel!
    
    var repertoryMusic: RepertoryMusic? {
        didSet {
            orderLabel.text = "\((repertoryMusic?.index ?? 0) + 1)"
            musicNameLabel.text = repertoryMusic?.music?.name
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
