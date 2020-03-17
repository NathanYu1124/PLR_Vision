//
//  CharsView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/3/2.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class CharsView: NSView {
    
    @IBOutlet weak var charCell_1: CharCell!
    @IBOutlet weak var charCell_2: CharCell!
    @IBOutlet weak var charCell_3: CharCell!
    @IBOutlet weak var charCell_4: CharCell!
    @IBOutlet weak var charCell_5: CharCell!
    @IBOutlet weak var charCell_6: CharCell!
    @IBOutlet weak var charCell_7: CharCell!
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    
    func updateUI(charsArray: [charInfo]) {
        charCell_1.updateUI(charInfo: charsArray[0])
        charCell_2.updateUI(charInfo: charsArray[1])
        charCell_3.updateUI(charInfo: charsArray[2])
        charCell_4.updateUI(charInfo: charsArray[3])
        charCell_5.updateUI(charInfo: charsArray[4])
        charCell_6.updateUI(charInfo: charsArray[5])
        charCell_7.updateUI(charInfo: charsArray[6])
    }
    
}
