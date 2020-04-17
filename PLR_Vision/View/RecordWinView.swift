//
//  RecordWinView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/14.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

protocol RecordWinViewProtocal {
    
    func cellDidClicked(_ recordWinView: RecordWinView, plateModel: PlateInfoModel?)
}

class RecordWinView: NSView {
    
    // MARK: - property
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var delegate: RecordWinViewProtocal?
    
    
    
    // MARK: -
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.6)
        
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 5
        
      
//        tableView.backgroundColor = NSColor(red: 232 / 255, green: 221 / 255, blue: 243 / 255, alpha: 1.0)
        tableView.selectionHighlightStyle = .regular
        
        // 注册cell点击事件
        tableView.action = #selector(tableViewCellDidClicked)
    }
    
    func updateUI() {
        
    }
    
}

// MARK: - tableView

extension RecordWinView: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
}

extension RecordWinView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return RecordTableRowView()
    }

}

extension RecordWinView {
    
    // cell点击事件
    @objc func tableViewCellDidClicked() {
        self.delegate?.cellDidClicked(self, plateModel: nil)
    }
}
