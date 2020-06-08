//
//  StepExtentionView.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift

class StepStackView: UIStackView {
    //template
    var step: ProjectStep?{
        didSet{
            if let name = step?.name{
                stepNameLabel.text = name
                //this logic makes stepnamelabel size correct
                let rect = NSString(string: name).boundingRect(with: CGSize(width: 226, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], context: nil)
                
                if rect.height > 24{
                    stepNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:  0).isActive = true
                    stepNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  12).isActive = true
                    stepNameLabel.heightAnchor.constraint(equalToConstant: 51).isActive = true
                    stepNameLabel.widthAnchor.constraint(equalToConstant: 226).isActive = true
                }else{
                    stepNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:  0).isActive = true
                    stepNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  12).isActive = true
                    stepNameLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true
                    stepNameLabel.widthAnchor.constraint(equalToConstant: 226).isActive = true
                }
            }
            
            if let cost = step?.cost{
                // configure total cost dollar sign to be smaller
                valueLabel.text = "\(cost)$"
                let smallFont = UIFont.systemFont(ofSize: 15)
                let attrString = NSMutableAttributedString(string: "\(cost)$")
                attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueLabel.text!.count - 1 , 1))
                valueLabel.attributedText = attrString
            }
            if let category = step?.category{
                categoryLabel.text = category
            }
            if let complete = step?.complete{
                doneButton.isSelected = complete
            }
        }
    }
    
    let leftColorBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 1, green: 0.572, blue: 0.160, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let stepNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing at All"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let valueLabel: UILabel = {
        let label = UILabel()
        label.text = "300$"
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Cost"
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Other"
        //label.backgroundColor = UIColor.yellow
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.5, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor(displayP3Red: 40/255, green: 114/255, blue: 70/255, alpha: 1), for: .selected)
        button.setBackgroundImage(UIImage(named: "doneNormal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "doneSelected"), for: .selected)
        button.contentHorizontalAlignment = .right
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "editButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .right
        return button
    }()
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    func setupStackView(){
        //adds all listed items to the view
        [leftColorBar, stepNameLabel, categoryLabel, valueLabel, descriptionLabel, doneButton, editButton].forEach {
            addSubview($0)
        }
        
        leftColorBar.topAnchor.constraint(equalTo: self.topAnchor, constant:  0).isActive = true
        leftColorBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  0).isActive = true
        leftColorBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
        leftColorBar.widthAnchor.constraint(equalToConstant: 4).isActive = true
        
        categoryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:  10).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant:  12).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 31).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //  realy ADJUSTable...
        valueLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:  0).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:  0).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 27).isActive = true
        //...together
        descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant:  2).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: valueLabel.rightAnchor).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: valueLabel.widthAnchor, multiplier: 1).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        editButton.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        doneButton.centerYAnchor.constraint(equalTo: editButton.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: editButton.leftAnchor, constant: -24).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    
}
