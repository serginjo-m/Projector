//
//  ProjectWayCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProjectWayCell: UITableViewCell {
    
    var template: ProjectStep? {
        didSet{
            guard let template = template else {return}
            stepTitleLabel.text = template.name
            displayButton.isSelected = template.displayed == true ? false : true
            stepTitleLabel.textColor = template.displayed == true ? .black : .red
        }
    }
    
    lazy var stepTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var displayButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "greenEye"), for: .normal)
        button.setImage(UIImage(named: "redEye"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .top
        button.addTarget(self, action: #selector(handleStepDisplayStatus(_:)), for: .touchUpInside)
        let lightRedColor = UIColor.init(displayP3Red: 255/255, green: 227/255, blue: 227/255, alpha: 1)
        button.setBackgroundColor(lightRedColor, forState: .selected)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCell()
    }
    
    @objc func handleStepDisplayStatus(_ sender: UIButton){
        
        sender.isSelected = !sender.isSelected
        
        stepTitleLabel.textColor = sender.isSelected == true ? .red : .black
        
        guard let step = template else {return}
        
        ProjectListRepository.instance.updateStepDisplayedStatus(step: step, displayedStatus: !sender.isSelected)
        
        if sender.isSelected == true, let section = step.section {
            if let project = ProjectListRepository.instance.getProjectList(id: section.projectId){
                ProjectListRepository.instance.updateProjectFilterStatus(project: project, filterIsActive: true)
            }
        }
    }
    
    func setupCell(){
        addSubview(stepTitleLabel)
        addSubview(displayButton)
        
        displayButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        displayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        displayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        displayButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        stepTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        stepTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50).isActive = true
        stepTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36).isActive = true
        stepTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
