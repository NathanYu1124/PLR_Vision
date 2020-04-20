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
    
    @IBOutlet var contentView: NSView!
    
    // MARK: - init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = NSNib(nibNamed: "CharsView", bundle: Bundle(for: type(of: self)))
        nib?.instantiate(withOwner: self, topLevelObjects: nil)
        addSubview(contentView)
        
    }
    
    // 背景颜色
    var backgroundColor = L_Yellow
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = backgroundColor
        self.layer?.cornerRadius = 20
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
