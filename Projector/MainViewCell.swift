//
//  projectTableViewCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet weak var cellBg: UIView!
    
    //MARK: functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
