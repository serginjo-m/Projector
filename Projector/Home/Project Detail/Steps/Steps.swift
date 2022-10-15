//
//  Steps.swift
//  Projector
//
//  Created by Serginjo Melnik on 28.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: DetailViewController Steps Section
//It includes collectionView navigation, stackView that holds four collectionViews
class Steps: UIView{
    
    //MARK: database
    
    weak var delegate: EditViewControllerDelegate?
    
    var projectWayFilter: Bool
   
    var project: ProjectList {
        didSet{
            updateAllStepCollectionViews()
        }
    }
    
    func updateAllStepCollectionViews(){
        
        projectSteps = project.projectStep
        groupedStepsByCategory = Dictionary(grouping: projectSteps) { (step) -> String in
            return step.category
        }
        let lists = [todoList, inProgressList, doneList, blockedList]
        let progressCategories = ["todo", "inProgress", "done", "blocked"]
        for (index, list) in lists.enumerated(){
            
            list.projectSteps.removeAll()
            //full list
            if let unwrappedList = groupedStepsByCategory[progressCategories[index]]{
                
                //property set by parent VC from button.isSelected state
                if self.projectWayFilter == true {
                    //filter steps to show steps that are displayed to true
                    list.projectSteps  = unwrappedList.filter { step in
                        step.displayed == true
                    }
                } else {//or show everything if filter disabled
                    list.projectSteps = unwrappedList
                }
                
            }else{//or set to empty if no steps returned from database
                list.projectSteps = []
            }
            
            list.reloadData()
        }
    }
    
    var projectSteps: List<ProjectStep>{
        get{
            return project.projectStep
        }
        set{
            //update?
        }
    }
    //[String : [ProjectStep]]
    lazy var groupedStepsByCategory = Dictionary(grouping: projectSteps) { (step) -> String in
        return step.category
    }
    

    let colorArr = [
        UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),//blue color
        UIColor.init(red: 248/255, green: 182/255, blue: 24/255, alpha: 1),//orange color
        UIColor.init(red: 17/255, green: 201/255, blue: 109/255, alpha: 1),//green color
        UIColor.init(red: 236/255, green: 65/255, blue: 91/255, alpha: 1)//red color
    ]
    
    //MARK: steps navigation
    lazy var stepsNavigationStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoButton, inProgressButton, doneButton, blockedButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    lazy var todoButton: UIButton = {
        let button = UIButton()
        button.setTitle("To-do", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[0], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleTodo(_:)), for: .touchUpInside)
        button.isSelected = true
        button.tag = 0
        return button
    }()
    lazy var inProgressButton: UIButton = {
        let button = UIButton()
        button.setTitle("In Progress", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[1], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleInProgress(_:)), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[2], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleDone(_:)), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    lazy var blockedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Blocked", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[3], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleBlocked(_:)), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    lazy var pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = colorArr[0]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        return view
    }()
    
    //MARK: Steps Collection Views
    
    let cellId = "cellId"
    
    lazy var todoList: StepsCategoryCollectionView = {
        let layout = PinterestLayout()
        let collectionView = StepsCategoryCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.customDelegate = delegate
        guard let projectSteps = groupedStepsByCategory["todo"] else {return collectionView}
        collectionView.projectSteps = projectSteps
        return collectionView
    }()
    
    lazy var inProgressList: StepsCategoryCollectionView = {
        let layout = PinterestLayout()
        let collectionView = StepsCategoryCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.customDelegate = delegate
        guard let projectSteps = groupedStepsByCategory["inProgress"] else {return collectionView}
        collectionView.projectSteps = projectSteps
        return collectionView
    }()
    
    lazy var doneList: StepsCategoryCollectionView = {
        let layout = PinterestLayout()
        let collectionView = StepsCategoryCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.customDelegate = delegate
        guard let projectSteps = groupedStepsByCategory["done"] else {return collectionView}
        collectionView.projectSteps = projectSteps
        return collectionView
    }()
    
    lazy var blockedList: StepsCategoryCollectionView = {
        let layout = PinterestLayout()
        let collectionView = StepsCategoryCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.customDelegate = delegate
        guard let projectSteps = groupedStepsByCategory["blocked"] else {return collectionView}
        collectionView.projectSteps = projectSteps
        return collectionView
    }()
    
    lazy var stepsCategoryCollectionViewStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoList, inProgressList, doneList, blockedList])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityScroll(UIAccessibilityScrollDirection.right)
        stack.distribution = .fillEqually
        return stack
    }()
    
    //variable constraints for animation
    var pointerViewLeftConstraint: NSLayoutConstraint?
    var stackLeadingAnchorConstraint: NSLayoutConstraint?
    
    
    //same func but dif button.tag, that helps define what button is tupped
    @objc func handleTodo(_ sender: UIButton){
        handleStepBlockAnimation(sender: sender)
        hideProgressMenu(progressMenu: todoList.progressMenu)
    }
    @objc func handleInProgress(_ sender: UIButton){
        handleStepBlockAnimation(sender: sender)
        hideProgressMenu(progressMenu: inProgressList.progressMenu)
    }
    @objc func handleDone(_ sender: UIButton){
        handleStepBlockAnimation(sender: sender)
        hideProgressMenu(progressMenu: doneList.progressMenu)
    }
    @objc func handleBlocked(_ sender: UIButton){
        handleStepBlockAnimation(sender: sender)
        hideProgressMenu(progressMenu: blockedList.progressMenu)
    }
    
    //hide step progress menu when user scroll to other collection view
    fileprivate func hideProgressMenu(progressMenu: StepProgressMenu){
        progressMenu.isHidden = true
    }
    
    lazy var buttonsArr = [todoButton, inProgressButton, doneButton, blockedButton]
    //holds current collection view & navigation position
    var currentPosition = 0 {
        didSet{
            //pointer color
            pointerView.backgroundColor = colorArr[currentPosition]
            //reset all buttons selected state to .normal
            buttonsArr.forEach{$0.isSelected = false}
            //search step by sected item index
            buttonsArr[currentPosition].isSelected = true
        }
    }
    
    
    //
    fileprivate func handleStepBlockAnimation(sender: UIButton){
        
        //define offset distance
        let contentOffsetX = frame.width * CGFloat(sender.tag)
        //change constraint offset distance
        stackLeadingAnchorConstraint?.constant = -contentOffsetX
        pointerViewLeftConstraint?.constant = contentOffsetX / 4
        //animate changes
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
        //update current position
        currentPosition = sender.tag
    }
    
    
    //MARK: Initialization
    init(project: ProjectList, delegate: EditViewControllerDelegate, projectWayFilter: Bool){
        
        self.projectWayFilter = projectWayFilter
        self.project = project
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setupLayout(){
        
        clipsToBounds = true
        
        addSubview(pointerView)
        addSubview(stepsNavigationStackView)
        addSubview(stepsCategoryCollectionViewStack)
        
        NSLayoutConstraint.activate([
            stepsNavigationStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stepsNavigationStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stepsNavigationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stepsNavigationStackView.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        pointerViewLeftConstraint = pointerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        pointerView.topAnchor.constraint(equalTo: stepsNavigationStackView.bottomAnchor, constant: 7).isActive = true
        pointerView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        pointerView.widthAnchor.constraint(equalTo: stepsNavigationStackView.widthAnchor, multiplier: 1/4).isActive = true
        
        pointerViewLeftConstraint?.isActive = true
        
        

        stepsCategoryCollectionViewStack.topAnchor.constraint(equalTo: stepsNavigationStackView.bottomAnchor, constant: 30).isActive = true
        stackLeadingAnchorConstraint = stepsCategoryCollectionViewStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        stepsCategoryCollectionViewStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 4).isActive = true
        stepsCategoryCollectionViewStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        stackLeadingAnchorConstraint?.isActive = true
    }
}
