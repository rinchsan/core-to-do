//
//  TaskTableViewCell.swift
//  CoreToDo for Qiita
//
//  Created by Masaya Hayashi on 2017/01/28.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TaskCell"
    
    // MARK: -
    
    @IBOutlet var taskLabel: UILabel!
    
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
