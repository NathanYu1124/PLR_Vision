//
//  PlateDetailView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/15.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class PlateDetailView: NSView {
    
    @IBOutlet weak var plateView: NSImageView!
    @IBOutlet weak var plateLabel: NSTextField!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var provinceLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.4)
        self.layer?.cornerRadius = 15
    }
    
    func updateUI(plateModel: PlateInfoModel) {
        plateView.image = plateModel.plateImage
        plateLabel.stringValue = plateModel.plateLicense
        colorLabel.stringValue = plateModel.plateColor
        let province = String(plateModel.plateLicense.first!)
        provinceLabel.stringValue = ProvinceDict[province]!
    }
}
