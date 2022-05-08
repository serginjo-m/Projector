//
//  SwipingController.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.09.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

class SwipingController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //data for individual page configuration
    let pages = [
        SwipingPage(
            imageName: "plane_p1",
            headerString: "Easy steps to organize your project",
            bodyText: "Dive into your project very easily. Achieve your goals and be happy.",
            imageConstraints:
            SwipingImageConstraints(imageHeight: 0.9873,//311,//1,0833333
                                    imageCenterYAnchor: -121,
                                    imageCenterXAnchor: 0)),
        SwipingPage(
            imageName: "statistics_p2",
            headerString: "Create your project management tool",
            bodyText: "By using Projector, the project you are working on can be managed easily.",
            imageConstraints:
            SwipingImageConstraints(imageHeight: 0.91390,//276,//0,91390
                                    imageCenterYAnchor: -103,
                                    imageCenterXAnchor: 0)),
        SwipingPage(
            imageName: "calendar_p3",
            headerString: "Project Management\nMade Simple.",
            bodyText: "Organize your daily project easily and manage your time well and neatly",
            imageConstraints:
            SwipingImageConstraints(imageHeight:0.91496, //269,//0,91496
                                    imageCenterYAnchor: -100,
                                    imageCenterXAnchor: 0)),
        SwipingPage(
            imageName: "space_p4",
            headerString: "",
            bodyText: "",
            imageConstraints:
            SwipingImageConstraints(imageHeight: 0.4572, //139,//0,4572
                                    imageCenterYAnchor: -175,
                                    imageCenterXAnchor: 0))
    ]
    
    let cellId = "cellId"
    
    
    let skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.43, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PREV", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(white: 190/255, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(handlePrev), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.setTitle("GET STARTED", for: .selected)
        button.tintColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(white: 190/255, alpha: 1), for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    //indicates current page
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        pc.numberOfPages = pages.count
        pc.currentPageIndicatorTintColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        pc.pageIndicatorTintColor = UIColor.init(white: 213/255, alpha: 1)
        return pc
    }()
    
    //update parent VC
    var didTapDismissCompletionHandler: (() -> Void)
    
    //MARK: init
    
    
    init(didTapDismissCompletionHandler: @escaping (() -> Void), collectionViewLayout layout: UICollectionViewLayout) {
        //Call parent vc, so it tries to update itself
        self.didTapDismissCompletionHandler = didTapDismissCompletionHandler
        //collection view controller should accept layout in init
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        collectionView?.backgroundColor = .white
        collectionView?.register(SwipingCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.isPagingEnabled = true
        
        setupControls()
    }
    //skip button action
    @objc private func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    //next page action
    @objc private func handleNext(){
        //if last page, dismiss
        if pageControl.currentPage == pages.count - 1 {
            dismiss(animated: true, completion: nil)
        }
        //calculate index to swipe to
        let nextIndex = min(pageControl.currentPage + 1, pages.count - 1)
        //update page control
        pageControl.currentPage = nextIndex
        //create index path
        let indexPath = IndexPath(item: nextIndex, section: 0)
        //perform scrolling to next page
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        //check if button must be changed to selected or not
        modifyButtonState(currentPageIndex: nextIndex)
        
    }
    //prev button
    @objc private func handlePrev(){
        
        let prevIndex = max(pageControl.currentPage - 1, 0)
        pageControl.currentPage = prevIndex
        
        let indexPath = IndexPath(item: prevIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        previousButton.isEnabled = prevIndex > 0 ? true : false
        
        modifyButtonState(currentPageIndex: prevIndex)
    }
    
    //align cell to the screen edge
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let x = targetContentOffset.pointee.x
        let currentPageIndex = Int(x / view.frame.width)
        
        pageControl.currentPage = currentPageIndex

        modifyButtonState(currentPageIndex: currentPageIndex)
    }
    //select or enable buttons for page position
    fileprivate func modifyButtonState(currentPageIndex: Int){
        nextButton.isSelected = currentPageIndex == pages.count - 1 ? true : false
        previousButton.isEnabled = currentPageIndex > 0 ? true : false
    }
    
    fileprivate func setupControls(){
       
        let bottomControlsStackView = UIStackView(arrangedSubviews: [previousButton, pageControl, nextButton])
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.distribution = .fillEqually
        
        view.addSubview(bottomControlsStackView)
        
        NSLayoutConstraint.activate([
            bottomControlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            bottomControlsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            bottomControlsStackView.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        //skip button
        view.addSubview(skipButton)
        skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 19).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SwipingCell
        
        let page = pages[indexPath.item]

        cell.parentVC = self//passing dismiss to parent
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
