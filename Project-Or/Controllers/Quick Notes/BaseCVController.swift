//
//  SampleCVController.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

//Base for collection View controller
class BaseCollectionViewController<T: BaseCollectionViewCell<U>, U >: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BaseCollectionViewDelegate, UIScrollViewDelegate{
    
    func performZoomInForStartingImageView(startingImageView: UIView) {
        print("basic zoom in...")
    }
    // (override in child vc) handle update from cell
    func updateDatabase() {
        print("database was updated!")
    }
    
    let cellId = "cellId"
    
    //data base
    var items = [U]()
    
    //navigation
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "Camera Notes"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    lazy var sectionOptionsContainer: NoteOptionsMenu = {
        let view = NoteOptionsMenu()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dismissContainerButton.addTarget(self, action: #selector(hideOptionsView(_:)), for: .touchUpInside)
        view.noteToProjectStepButton.addTarget(self, action: #selector(moveNoteToProject(_:)), for: .touchUpInside)
        view.noteToEventButton.addTarget(self, action: #selector(convertToEvent(_:)), for: .touchUpInside)
        view.removeNoteButton.addTarget(self, action: #selector(removeQuickNote(_:)), for: .touchUpInside)
        view.isHidden = true
        return view
    }()
    
   
    //here creates a horizontal collectionView
    let itemsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = PinterestLayout()
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    lazy var collectionStackView: UIStackView = {
        
        let stack = UIStackView()
        
        stack.addSubview(itemsCollectionView)
        
        //specify delegate & datasourse for generating our individual horizontal cells
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        
        itemsCollectionView.showsHorizontalScrollIndicator = false
        itemsCollectionView.showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        itemsCollectionView.register(T.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        return stack
    }()
    
    //variable constraints for animation
    var sectionOptionsRightConstraint: NSLayoutConstraint!
    var sectionOptionsTopConstraint: NSLayoutConstraint!
    //inputs animation approach
    var sectionOptionsCenterXConstraint: NSLayoutConstraint!
    var sectionOptionsWidthConstraint: NSLayoutConstraint!
    var sectionOptionsHeightConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(collectionStackView)
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(sectionOptionsContainer)
        
         setupConstraints()
        
        //---------------------------- why here?? --------------------------------
        if let layout = itemsCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self as? PinterestLayoutDelegate
        }
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func hideOptionsView(_ sender: UIButton) {
        if sectionOptionsContainer.baseTableView.isHidden == true {
            optionsMenuToggle(toggle: true)
            sectionOptionsContainer.isHidden = true
        }else{
            optionsMenuToggle(toggle: true)
        }
    }
    
    @objc func moveNoteToProject(_ sender: UIButton){
        optionsMenuToggle(toggle: false)
    }
    
    @objc func convertToEvent(_ sender: UIButton){
        print("simple convert call")
    }
    
    
    @objc func removeQuickNote(_ sender: UIButton){
        
       print("remove quick note!")
    }
    
    func optionsMenuToggle(toggle: Bool ){
        
        //order is important for constraints
        if toggle == true {
            sectionOptionsCenterXConstraint.isActive = !toggle
            sectionOptionsRightConstraint.isActive = toggle
        }else{
            sectionOptionsRightConstraint.isActive = toggle
            sectionOptionsCenterXConstraint.isActive = !toggle
        }
        
        let expandedOptionsHeight: CGFloat = CGFloat((sectionOptionsContainer.projects.count * 78) + 62)
        
        sectionOptionsWidthConstraint.constant = toggle == true ? (self.view.frame.width / 2) - 26 : self.view.frame.size.width - 26
        sectionOptionsHeightConstraint.constant = toggle == true ? 183 : expandedOptionsHeight
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
        sectionOptionsContainer.baseTableView.isHidden = toggle
        sectionOptionsContainer.projectsTableViewTitle.isHidden = toggle
        
        sectionOptionsContainer.noteToProjectStepButton.isHidden = !toggle
        sectionOptionsContainer.noteToEventButton.isHidden = !toggle
        sectionOptionsContainer.removeNoteButton.isHidden = !toggle
    }
    
    //menu position next to the selected cell button
    @objc func showOptions(_ sender: UIButton) {
        
            //------- Really important thing because it defines object for options menu -----------
            sectionOptionsContainer.currentNoteIndex = sender.tag
        
            optionsMenuToggle(toggle: true)
            let buttonFrame = sender.superview?.convert(sender.frame, to: nil)
            guard let topOffset = buttonFrame?.origin.y, let rightOffset = buttonFrame?.origin.x, let buttonWidth = buttonFrame?.width else {return}
            
            sectionOptionsTopConstraint?.constant = topOffset
            sectionOptionsRightConstraint?.constant = rightOffset + buttonWidth
            
            sectionOptionsContainer.isHidden = false
        
    }
    
    func convertNoteToStep(index: Int, project: ProjectList) {
        print("here every child do it's own configuration")
    }
    
    //MARK: Constraints
    func setupConstraints(){
        
        [collectionStackView, dismissButton, viewControllerTitle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        collectionStackView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 20).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        collectionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7).isActive = true
        collectionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7).isActive = true
        
        sectionOptionsRightConstraint = sectionOptionsContainer.rightAnchor.constraint(equalTo: view.leftAnchor)
        sectionOptionsTopConstraint = sectionOptionsContainer.topAnchor.constraint(equalTo: view.topAnchor)
        sectionOptionsWidthConstraint = sectionOptionsContainer.widthAnchor.constraint(equalToConstant: (self.view.frame.width / 2) - 26)
        sectionOptionsCenterXConstraint = sectionOptionsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)//not active for now
        sectionOptionsHeightConstraint = sectionOptionsContainer.heightAnchor.constraint(equalToConstant: 183)
        sectionOptionsHeightConstraint?.isActive = true
        sectionOptionsRightConstraint?.isActive = true
        sectionOptionsTopConstraint?.isActive = true
        sectionOptionsWidthConstraint?.isActive = true
        
        
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseCollectionViewCell<U>
        cell.delegate = self
        cell.item = items[indexPath.row]
        cell.menuButton.addTarget(self, action: #selector(showOptions(_:)), for: .touchUpInside)
        cell.menuButton.tag = indexPath.item
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
    }
    
}

class BaseCollectionViewCell<U>: UICollectionViewCell {
    
    var delegate: BaseCollectionViewDelegate?
    
    var item: U!
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 217/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "horizontal_dots"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(menuButton)
        
        menuButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7).isActive = true
        menuButton.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
    }
    
}

