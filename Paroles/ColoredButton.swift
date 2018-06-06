//
//  ColoredButton.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 06/06/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

class ColoredButton: UIButton {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        tintColor = UIColor.white
        
        let colours = [UIColor(red: 255/255.0, green: 129/255.0, blue: 38/255.0, alpha: 1.0), UIColor(red: 255/255.0, green: 17/255.0, blue: 126/255.0, alpha: 1.0)]
        let locations: [NSNumber] = [0.0, 1.0]
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    

}
