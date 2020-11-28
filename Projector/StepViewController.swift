//
//  StepVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 21.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

protocol StepViewControllerDelegate: class {
    //this function is dedicated to perform reload to all views related to this object
    func someKindOfFunctionThatPerformRelaod()
}

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StepViewControllerDelegate {
    
    //EDIT VC
    let editStepViewController = EditStepViewController()
    
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "stepTableViewCell"
    
    //TABLE VIEW
    let stepTableView = UITableView()
    
    //PARENT VC - WHOLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    weak var parentVC: DetailViewController?
    
    //scroll view container
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    //Instance of Project Selected by User
    var projectStep: ProjectStep? {
        get{
            //Retrieve a single object with unique identifier (stepID)
            return ProjectListRepository.instance.getProjectStep(id: stepID!)
        }
    }
    
    //step id passed by detail VC
    var stepID: String?
    
    //creates an instance of extension
    let myStepImagesCV = StepImagesCollectionView()
    //step values
    let stepNumbersCV = StepNumbersCollectionView()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    let circleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "redCircle")
        return image
    }()
    
    var stepNameTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Step Name"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let completeStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeSelectedValue(button:)), for: .touchUpInside)
        button.setTitle("Complete", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    let editStepButton: UIButton = {
        let button = UIButton()
//        button.addTarget(self, action: #selector(changeSelectedValue(button:)), for: .touchUpInside)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    let removeStepButton: UIButton = {
        let button = UIButton()
//        button.addTarget(self, action: #selector(changeSelectedValue(button:)), for: .touchUpInside)
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    var stepValuesTitle: UILabel = {
        let label = UILabel()
        label.text = "Step Values"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var stepItemsTitle: UILabel = {
        let label = UILabel()
        label.text = "Items Todo"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //perform all configuration separated by categories
        performPageConfigurations()
    }
    
    
    private func performPageConfigurations(){
        
        
        
        //by default - black
        view.backgroundColor = .white
        
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add items to a view
        [dismissButton, stepTableView, myStepImagesCV, categoryLabel, circleImage, completeStepButton,editStepButton, removeStepButton, stepNameTitle, stepValuesTitle, stepNumbersCV, stepItemsTitle].forEach {
            contentUIView.addSubview($0)
        }
        
        //------------------------ temporary solution -----------------------------
        guard let step = projectStep else {return}
        stepNameTitle.text = step.name
        completeStepButton.isSelected = step.complete
        stepNumbersCV.step = step
        categoryLabel.text = step.category
        
        //this logic makes stepnamelabel size correct
        let rect = NSString(string: step.name).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], context: nil)
        
        
        //CONSTRAINTS
        setupLayout(titleRectHeight: rect.height)
        
        //IMAGES CV CONFIGURATION
        configureImageCV()
        
        //TABLE VIEW CONFIGURATION
        configureStepTableView()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //TABLE VIEW CONFIGURATION
    private func configureStepTableView(){
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.register(StepTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        stepTableView.separatorStyle = .none
    }
    
    //IMAGES CV CONFIGURATION
    private func configureImageCV(){
        
        //clear before append
        myStepImagesCV.photosArray.removeAll()
        
        //append images to collections view array
        if let imageArray = projectStep?.selectedPhotosArray{
            for imageURL in imageArray {
                myStepImagesCV.photosArray.append(retreaveImageForStep(myUrl: imageURL))
            }
        }
        
        //define step inside class instance
        myStepImagesCV.step = projectStep
    }
    
    //return UIImage by URL
    func retreaveImageForStep(myUrl: String) -> UIImage{
        var stepImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            stepImage = UIImage(data: imageData)!
        }
        return stepImage
    }

    
    //table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = projectStep?.itemsArray.count  {
            return num
        }
        return 0
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? StepTableViewCell else {
            fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )
        }
        //turn of change background color from selected cell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.taskLabel.text = "Description Note"
        if let string = projectStep?.itemsArray[indexPath.row] {
            cell.descriptionLabel.text = string
        }
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeItem(button:)), for: .touchUpInside)
        return cell
    }
    
    //RELOAD ALL VIEWS
    func someKindOfFunctionThatPerformRelaod(){
        
        //configure image collection view
        configureImageCV()
        myStepImagesCV.stepImagesCollectionView.reloadData()
        
        //configure stepTableView
        configureStepTableView()
        parentVC?.stepsCollectionView.reloadData()
        parentVC?.delegate?.reloadTableView()
    }
    
    //REMOVE
    @objc func removeItem(button: UIButton){
        print("item removed")
//        if let myStep = projectStep {
//            ProjectListRepository.instance.deleteStepItem(step: myStep, itemAtIndex: button.tag)
//            stepTableView.reloadData()
//        }
    }
    
    //COMPLETE
    @objc func changeSelectedValue(button: UIButton) {
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        ProjectListRepository.instance.updateStepCompletionStatus(step: projectStep!, isComplete: button.isSelected)
        parentVC?.stepsCollectionView.reloadData()
        parentVC?.delegate?.reloadTableView()
    }
    
    //EDIT ACTION
    @objc func editButtonAction(_ sender: Any){
        
        editStepViewController.stepViewSetting.id = stepID ?? ""
        editStepViewController.stepViewSetting.name = projectStep?.name ?? ""
        editStepViewController.stepViewSetting.category = projectStep?.category ?? "Other"
        editStepViewController.stepViewSetting.index = {
            var int = 0
            for (num, item) in editStepViewController.stepCategory.sortedCategories.enumerated() {
                if projectStep?.category == item {
                    int = num
                }
            }
            return int
        }()
        
        editStepViewController.stepViewSetting.photoArr = {
            var arrPhoto = [UIImage]()
            //plus image
            let defaultImage = UIImage(named: "plusIconV2")
            //unwrap optional
            if let photo = defaultImage{
                arrPhoto.append(photo)
            }
            //append images
            if myStepImagesCV.photosArray.count > 0{
                for image in myStepImagesCV.photosArray{
                    arrPhoto.append(image)
                }
            }
            return arrPhoto
        }()
        
        editStepViewController.stepViewSetting.urlArr = {
            var array = [String]()
            if let arr = projectStep?.selectedPhotosArray{
                for url in arr{
                    array.append(url)
                }
            }
            return array
        }()
        
        editStepViewController.stepViewSetting.items = {
            var stepItems = [String]()
            if let itemsArray = projectStep?.itemsArray{
                for item in itemsArray{
                    stepItems.append(item)
                }
            }
            return stepItems
        }()
        editStepViewController.stepViewSetting.price = projectStep?.cost ?? 0
        editStepViewController.stepViewSetting.distance = projectStep?.distance ?? 0
        editStepViewController.stepViewSetting.complete = projectStep?.complete ?? false
        
        //------------- I don't realy like this approach, becouse it seems like a routine cycle
        editStepViewController.delegate = self
        
        //present edit VC
        self.show(editStepViewController, sender: sender)
    }
    
    //perforn all positioning configurations
    private func setupLayout(titleRectHeight: CGFloat){
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        myStepImagesCV.translatesAutoresizingMaskIntoConstraints = false
        stepTableView.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        completeStepButton.translatesAutoresizingMaskIntoConstraints = false
        editStepButton.translatesAutoresizingMaskIntoConstraints = false
        removeStepButton.translatesAutoresizingMaskIntoConstraints = false
        stepNameTitle.translatesAutoresizingMaskIntoConstraints = false
        stepValuesTitle.translatesAutoresizingMaskIntoConstraints = false
        stepNumbersCV.translatesAutoresizingMaskIntoConstraints = false
        stepItemsTitle.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        //diff size string need width calculation for constraints
        guard let categoryLabelString = categoryLabel.text else {return}
        let categoryLabelSize = ceil(categoryLabelString.size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]).width)
        
        categoryLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        categoryLabel.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor, constant: 0).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabelSize).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        circleImage.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor, constant: 0).isActive = true
        circleImage.rightAnchor.constraint(equalTo: categoryLabel.leftAnchor, constant: -6).isActive = true
        circleImage.widthAnchor.constraint(equalToConstant: 8).isActive = true
        circleImage.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        // 2 or 1 line title
        if titleRectHeight > 25{
            stepNameTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 22).isActive = true
            stepNameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
            stepNameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
            stepNameTitle.heightAnchor.constraint(equalToConstant: 66).isActive = true
        }else{
            stepNameTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 22).isActive = true
            stepNameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
            stepNameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
            stepNameTitle.heightAnchor.constraint(equalToConstant: 33).isActive = true
        }
        
        completeStepButton.topAnchor.constraint(equalTo: stepNameTitle.bottomAnchor, constant: 18).isActive = true
        completeStepButton.leftAnchor.constraint(equalTo: dismissButton.leftAnchor, constant: 0).isActive = true
        completeStepButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        completeStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        editStepButton.centerYAnchor.constraint(equalTo: completeStepButton.centerYAnchor, constant: 0).isActive = true
        editStepButton.leftAnchor.constraint(equalTo: completeStepButton.rightAnchor, constant: 29).isActive = true
        editStepButton.widthAnchor.constraint(equalToConstant: 31).isActive = true
        editStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        removeStepButton.centerYAnchor.constraint(equalTo: completeStepButton.centerYAnchor, constant: 0).isActive = true
        removeStepButton.leftAnchor.constraint(equalTo: editStepButton.rightAnchor, constant: 29).isActive = true
        removeStepButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        removeStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        myStepImagesCV.topAnchor.constraint(equalTo: completeStepButton.bottomAnchor, constant:  30).isActive = true
        myStepImagesCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  16).isActive = true
        myStepImagesCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -16).isActive = true
        myStepImagesCV.heightAnchor.constraint(equalToConstant: 144).isActive = true
        
        stepValuesTitle.topAnchor.constraint(equalTo: myStepImagesCV.bottomAnchor, constant: 30).isActive = true
        stepValuesTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepValuesTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepValuesTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        stepNumbersCV.topAnchor.constraint(equalTo: stepValuesTitle.bottomAnchor, constant: 0).isActive = true
        stepNumbersCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepNumbersCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepNumbersCV.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        stepItemsTitle.topAnchor.constraint(equalTo: stepNumbersCV.bottomAnchor, constant: 20).isActive = true
        stepItemsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepItemsTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepItemsTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        stepTableView.topAnchor.constraint(equalTo: stepItemsTitle.bottomAnchor, constant:  9).isActive = true
        stepTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
    }
}

class StepTableViewCell: UITableViewCell {

    let titleIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        return image
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "removeItem"), for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.contentMode = .center
        button.imageView!.contentMode = .scaleAspectFill
        
        button.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        
        return button
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        //label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bg.layer.cornerRadius = 12
//        bg.layer.borderWidth = 1
//        bg.layer.borderColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        bg.layer.masksToBounds = true
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = UIColor.lightGray
        
        addSubview(taskLabel)
        addSubview(titleIcon)
        
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        backgroundBubble.addSubview(removeButton)
        
        titleIcon.frame = CGRect(x: 0, y: 8, width: 16, height: 14)
        taskLabel.frame = CGRect(x: 23, y: 0, width: 250, height: 30)
       // removeButton.frame = CGRect(x: Int(frame.width) - 67, y: 5, width: 77, height: 17)
        
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundBubble.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16),
            backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16),
            
            removeButton.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            removeButton.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            removeButton.widthAnchor.constraint(equalToConstant: 35),
            removeButton.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
