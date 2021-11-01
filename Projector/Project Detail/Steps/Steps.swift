//
//  Steps.swift
//  Projector
//
//  Created by Serginjo Melnik on 28.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Steps: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let blueColor = UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1)
    let orangeColor = UIColor.init(red: 248/255, green: 182/255, blue: 24/255, alpha: 1)
    let greenColor = UIColor.init(red: 17/255, green: 201/255, blue: 109/255, alpha: 1)
    let redColor = UIColor.init(red: 236/255, green: 65/255, blue: 91/255, alpha: 1)
    
    let colorArr = [
        UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),//blue color
        UIColor.init(red: 248/255, green: 182/255, blue: 24/255, alpha: 1),//orange color
        UIColor.init(red: 17/255, green: 201/255, blue: 109/255, alpha: 1),//green color
        UIColor.init(red: 236/255, green: 65/255, blue: 91/255, alpha: 1)//red color
    ]
    
    lazy var stepsNavigationStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoButton, inProgressButton, doneButton, blockedButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    lazy var todoButton: UIButton = {
        let button = UIButton()
//        button.layer.backgroundColor = UIColor.green.cgColor
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
//        button.layer.backgroundColor = UIColor.red.cgColor
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
//        button.layer.backgroundColor = UIColor.yellow.cgColor
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
//        button.layer.backgroundColor = UIColor.blue.cgColor
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
    
    var pointerViewLeftConstraint: NSLayoutConstraint?
    
    @objc func handleTodo(_ sender: UIButton){
        handlePointerAnimation(sender: sender)
    }
    @objc func handleInProgress(_ sender: UIButton){
        handlePointerAnimation(sender: sender)
    }
    @objc func handleDone(_ sender: UIButton){
        handlePointerAnimation(sender: sender)
    }
    @objc func handleBlocked(_ sender: UIButton){
        handlePointerAnimation(sender: sender)
    }
    
    
    var currentPosition = 0 {
        didSet{
            pointerView.backgroundColor = colorArr[currentPosition]
            buttonsArr.forEach{$0.isSelected = false}
            buttonsArr[currentPosition].isSelected = true
        }
    }
    
    lazy var buttonsArr = [todoButton, inProgressButton, doneButton, blockedButton]
    
    fileprivate func handlePointerAnimation(sender: UIButton){
        
        let indexPath = IndexPath(item: sender.tag, section: 0)
        stepsCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)

        currentPosition = sender.tag
    }
    
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pointerViewLeftConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        let currentPageIndex = Int(x / frame.width)
        
        currentPosition = currentPageIndex
    }
    
    
    
//    MARK: Steps Collection View
//    identifier for collection view
    var cellId = "cellID"

    //here creates a horizontal collectionView
    let stepsCollectionView: UICollectionView = {

        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.backgroundColor = UIColor.clear

        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    lazy var collectionStackView: UIStackView = {

        let stack = UIStackView()

        stack.addSubview(stepsCollectionView)

        //specify delegate & datasourse for generating our individual horizontal cells
        stepsCollectionView.dataSource = self
        stepsCollectionView.delegate = self

        stepsCollectionView.showsHorizontalScrollIndicator = false
        stepsCollectionView.showsVerticalScrollIndicator = false

        stepsCollectionView.isPagingEnabled = true

        //Class is need to be registered in order of using inside
        stepsCollectionView.register(StepsPageCell.self, forCellWithReuseIdentifier: cellId)

        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
        return stack
    }()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepsPageCell
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: frame.height - 48)
    }
    
    

    init(){
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout(){
        
        addSubview(pointerView)
        addSubview(stepsNavigationStackView)
        addSubview(collectionStackView)
        
        NSLayoutConstraint.activate([
            stepsNavigationStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stepsNavigationStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stepsNavigationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stepsNavigationStackView.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        pointerViewLeftConstraint = pointerView.leftAnchor.constraint(equalTo: stepsCollectionView.leftAnchor, constant: 0)
        pointerView.topAnchor.constraint(equalTo: stepsNavigationStackView.bottomAnchor, constant: 7).isActive = true
        pointerView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        pointerView.widthAnchor.constraint(equalTo: stepsNavigationStackView.widthAnchor, multiplier: 1/4).isActive = true
        
        pointerViewLeftConstraint?.isActive = true
        
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionStackView.topAnchor.constraint(equalTo: stepsNavigationStackView.bottomAnchor, constant: 30).isActive = true
        collectionStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
}
