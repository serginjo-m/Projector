//
//  StepProgressMenu.swift
//  Projector
//
//  Created by Serginjo Melnik on 14.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class StepProgressMenu: UIView {
    
    //perform configurations & updates in parent view controller
    weak var delegate: EditViewControllerDelegate?
    var projectStep: ProjectStep?{
        didSet{
//            if let step = projectStep{
//                print("Progress menu step object is: \(step.name)")
//            }
        }
    }
    //menu white container
    let buttonsContanerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var todoOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("To do", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.2, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleTodo(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var inProgressOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("In Progress", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.2, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleInProgress(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var doneOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.2, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleDone(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var blockedOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Blocked", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.2, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleBlocked(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var optionButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoOptionButton, inProgressOptionButton, doneOptionButton, blockedOptionButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTodo(_ sender: UIButton){
        changeStepProgressStatus(status: "todo")
    }
    @objc func handleInProgress(_ sender: UIButton){
        changeStepProgressStatus(status: "inProgress")
    }
    @objc func handleDone(_ sender: UIButton){
        changeStepProgressStatus(status: "done")
    }
    @objc func handleBlocked(_ sender: UIButton){
        changeStepProgressStatus(status: "blocked")
    }
    
    private func changeStepProgressStatus(status: String){
        guard let step = projectStep, let delegate = self.delegate else {
            print("project step isn't defined!")
            return
        }
        
       self.isHidden = true
        //because changing has been made
        ProjectListRepository.instance.updateStepProgressStatus(step: step, status: status)
        UserActivitySingleton.shared.createUserActivity(description: "\(step) status was changed to \(status)")
        //call DetailViewController for update database and reload views
        delegate.reloadViews()
    }
    
    func setupLayout(){
        isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true        
        addSubview(optionButtonsStack)
        
        optionButtonsStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        optionButtonsStack.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        optionButtonsStack.topAnchor.constraint(equalTo:  topAnchor, constant: 0).isActive = true
        optionButtonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
    }
}
