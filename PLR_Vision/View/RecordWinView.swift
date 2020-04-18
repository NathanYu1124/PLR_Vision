//
//  RecordWinView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/14.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

protocol RecordWinViewProtocal {
    
    func cellDidClicked(_ recordWinView: RecordWinView, plateModel: PlateInfoModel)
}

class RecordWinView: NSView {
    
    // MARK: - property
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var delegate: RecordWinViewProtocal?
    
    var plateModels = [PlateInfoModel]()
    
    // MARK: - func
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = CGColor(red: 250 / 255, green: 178 / 255, blue: 95 / 255, alpha: 0.6)
        
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 5
        
        tableView.selectionHighlightStyle = .regular
        
        // 注册cell点击事件
        tableView.action = #selector(tableViewCellDidClicked)
    }
    
    // 更新tableview, 返回值: 截止到当前帧识别到的所有车牌数
    func updateUI(models: [PlateInfoModel]) {
        
        self.plateModels = models
        
       // 刷新tableview
       tableView.reloadData()
    }
}

// MARK: - tableView

extension RecordWinView: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return plateModels.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
}

extension RecordWinView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return RecordTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let model = plateModels[row]
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RecordTableCellID"), owner: nil) as! RecordTableCell
//        cell.prepareForReuse()
        cell.licenseLabel.stringValue = model.plateLicense
        cell.colorLabel.stringValue = model.plateColor
        
        return cell
    }
}

extension RecordWinView {
    
    // cell点击事件
    @objc func tableViewCellDidClicked() {
        
        if plateModels.count != 0 {            
            let model = plateModels[tableView.selectedRow]
            self.delegate?.cellDidClicked(self, plateModel: model)
        }

    }
}

// MARK: - extension String
extension String {
    
    // 数字下标访问
    subscript (i: Int) -> Character? {
        if i >= 0 && i < self.count {   // 下标合法范围
            return self[self.index(self.startIndex, offsetBy: i)]
        }
        
        return nil
    }
    
}
