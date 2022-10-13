//
//  ProjectWayVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 29/09/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectWayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    var cellIdentifier = "cellId"
    
    var project: ProjectList?
    
    var steps: [ProjectStep] = []

    var projectSections: [StepWaySection] = []
    
    var groupedSteps: [String : [ProjectStep]] = [:]
    //requested for section index midification
    var stepsByIndexes: [Int : [ProjectStep]] = [:]
    
    //Project Image created programatically
     var projectImageView: UIImageView = {
         let PIV = UIImageView()
         PIV.translatesAutoresizingMaskIntoConstraints = false
         PIV.contentMode = UIImageView.ContentMode.scaleAspectFill
         PIV.clipsToBounds = true
         PIV.layer.cornerRadius = 13
         return PIV
     }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
   
    let projectTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "This is Project Name"
        title.font = UIFont.boldSystemFont(ofSize: 27)
        title.textAlignment = .center
        title.textColor = UIColor.init(white: 1, alpha: 1)
        title.numberOfLines = 0
        return title
    }()
    
    let projectTitleShadow: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "This is Project Name"
        title.font = UIFont.boldSystemFont(ofSize: 27)
        title.textAlignment = .center
        title.textColor = UIColor.init(white: 0, alpha: 1)
        title.numberOfLines = 0
        return title
    }()
    
    //table view
    lazy var projectWayTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProjectWayCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        return tableView
    }()
    
    lazy var sectionOptionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        return view
    }()
    
    lazy var dismissContainerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let originalImage = UIImage(named: "horizontal_dots")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.addTarget(self, action: #selector(hideOptionsView(_:)), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy var editSectionNameButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit Section name", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(editSectionName(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var changeSectionIndexButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change section index", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(changeSectionIndex(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var removeSectionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Remove section", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.init(displayP3Red: 255/255, green: 113/255, blue: 113/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(removeSection(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var applySectionModificationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
        button.setImage(UIImage(named: "crossIcon"), for: .normal)
        button.addTarget(self, action: #selector(applyModificationForSection(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.isHidden = true
        return button
    }()
    
    lazy var cancelRenameButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setImage(UIImage(named: "crossIcon"), for: .normal)
        button.addTarget(self, action: #selector(backToOptionsMenu), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.isHidden = true
        return button
    }()
    
    //name text field
    lazy var sectionTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "New Section Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Handle the text field's user input through delegate callback.
        textField.delegate = self
        textField.isHidden = true
        return textField
    }()
    
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 224/255, alpha: 1)
        return view
    }()
    
    //variable constraints for animation
    var sectionOptionsRightConstraint: NSLayoutConstraint?
    var sectionOptionsTopConstraint: NSLayoutConstraint?
    //inputs animation approach
    var sectionOptionsLeadingConstraint: NSLayoutConstraint!
    var sectionOptionsWidthConstraint: NSLayoutConstraint!
    var sectionOptionsHeightConstraint: NSLayoutConstraint!
    
    
    //MARK: Init
    init(projectId: String, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
                
        self.project = ProjectListRepository.instance.getProjectList(id: projectId)
        
        if let project = project {
            steps.append(contentsOf: project.projectStep)
            
            if let projectImageUrl = project.selectedImagePathUrl {
                projectImageView.retreaveImageUsingURLString(myUrl: projectImageUrl)
            }
            
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        view.addSubview(projectImageView)
        view.addSubview(dismissButton)
        view.addSubview(projectTitleShadow)
        view.addSubview(projectTitle)
        view.addSubview(lineView)
        view.addSubview(projectWayTableView)
        view.addSubview(sectionOptionsContainer)
        
        
        sectionOptionsContainer.addSubview(dismissContainerButton)
        sectionOptionsContainer.addSubview(editSectionNameButton)
        sectionOptionsContainer.addSubview(changeSectionIndexButton)
        sectionOptionsContainer.addSubview(removeSectionButton)
        sectionOptionsContainer.addSubview(sectionTextField)
        sectionOptionsContainer.addSubview(applySectionModificationButton)
        sectionOptionsContainer.addSubview(cancelRenameButton)
        //title & database
        configureViewController()

        setupConstraints()
    }
    
    
    //MARK: Methods
    fileprivate func configureViewController(){
        //important: call it to make extension working
        self.hideKeyboardWhenTappedAround()
        
        self.projectWayTableView.sectionHeaderHeight = 50
        
        if let project = project{
            projectTitle.text = project.name
            projectTitleShadow.text = projectTitle.text
        }
        //configure database
        self.updateDatabase()
    }
    
    fileprivate func updateDatabase(){
        //database
        groupedSteps = Dictionary(grouping: steps, by: { step -> String in
            guard let section = step.section else {return step.id}
            return section.name
        })
        
        stepsByIndexes = Dictionary(grouping: steps, by: { step -> Int in
            guard let section = step.section else {return 0}
            return section.indexNumber
        })
                
        projectSections = groupedSteps.map { (key, value) in
            guard let projectStep = value.first, let stepSectionObject = projectStep.section else {return StepWaySection()}
            
            return stepSectionObject
        }.sorted(by: { a, b in
            return a.indexNumber > b.indexNumber
        })
    }
    
    @objc private func handleDismiss(){
        dismiss(animated: true)
    }
    
    @objc func removeSection(_ sender: UIButton){
        
        let section = self.projectSections[sender.tag]
        
        //create new alert window
        let alertVC = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        
        if let selectedSectionArray = groupedSteps[section.name] {
            
            if selectedSectionArray.isEmpty == true {
                
                alertVC.title = "Delete Section?"
                alertVC.message = "Are You sure You want to delete this section?"
                
                //delete button
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
                    
                    ProjectListRepository.instance.deleteSection(section: section)
                    
                    self.sectionOptionsContainer.isHidden = true
                    
                    self.updateDatabase()
                    
                    self.projectWayTableView.reloadData()
                })
                
                
                alertVC.addAction(deleteAction)
                
            }else{
                
                alertVC.title = "Section Still Contains Steps!"
                alertVC.message = "Please move or delete steps previously."
                
            }
        }

        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(cancelAction)
        
        
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func changeSectionIndex(_ sender: UIButton){
        
        sectionTextField.attributedPlaceholder = NSAttributedString(
            string: "\(projectSections[sender.tag].indexNumber)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        sectionTextField.keyboardType = .numberPad
        
        applySectionModificationButton.tag = 0
        optionsMenuToggle(toggle: false)
    }
    
    @objc func editSectionName(_ sender: UIButton){
        
        
        sectionTextField.attributedPlaceholder = NSAttributedString(
            string: "New Section Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        sectionTextField.keyboardType = .default
        
        applySectionModificationButton.tag = 1
        optionsMenuToggle(toggle: false)
    }
    
    @objc func applyModificationForSection(_ sender: UIButton) {
        if sender.tag == 0 {
            applyNewIndexForSection()
        }else if sender.tag == 1 {
            applyNewNameForSection()
        }
    }
    
    private func applyNewIndexForSection(){
        
        if let intText = sectionTextField.text, let integerValue = Int(intText){
            
            let dictionaryResult = stepsByIndexes[integerValue]
            
            if dictionaryResult == nil {
                
                ProjectListRepository.instance.updateSectionIndex(indexNumber: integerValue, section: projectSections[changeSectionIndexButton.tag])
                
            }else{
                let currentSectionIndex = projectSections[changeSectionIndexButton.tag].indexNumber
                let resoponseMessage = integerValue == currentSectionIndex ? "\(integerValue) is current number" : "number \(intText) is in use"
                sectionTextField.text = nil
                sectionTextField.attributedPlaceholder = NSAttributedString(
                    string: resoponseMessage,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemPink]
                )
            }
        }
        
        sectionTextField.text = nil
        
        self.updateDatabase()
        
        projectWayTableView.reloadData()
        
        hideOptionsView(self.dismissContainerButton)
        
        optionsMenuToggle(toggle: true)
        
    }
    
    private func applyNewNameForSection(){
        
        guard let textFieldText = sectionTextField.text else {return}
        
        ProjectListRepository.instance.updateSectionName(name: textFieldText, section: projectSections[editSectionNameButton.tag])
        
        sectionTextField.text = nil
        
        self.updateDatabase()
        
        projectWayTableView.reloadData()
        
        optionsMenuToggle(toggle: true)
    }
    
    @objc func backToOptionsMenu(){
        optionsMenuToggle(toggle: true)
        
        sectionTextField.text = nil
    }
    
    fileprivate func optionsMenuToggle(toggle: Bool ){
        
        //order is important for constraints
        if toggle == true {
            sectionOptionsLeadingConstraint.isActive = !toggle
            sectionOptionsWidthConstraint.isActive = toggle
        }else{
            sectionOptionsWidthConstraint.isActive = toggle
            sectionOptionsLeadingConstraint.isActive = !toggle
        }
        
        
        sectionOptionsHeightConstraint.constant = toggle == true ? 183 : 80
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
        sectionTextField.isHidden = toggle
        cancelRenameButton.isHidden = toggle
        applySectionModificationButton.isHidden = toggle
        editSectionNameButton.isHidden = !toggle
        changeSectionIndexButton.isHidden = !toggle
        removeSectionButton.isHidden = !toggle
    }
    
    @objc func hideOptionsView(_ sender: UIButton) {
        sectionOptionsContainer.isHidden = true
    }
    
    //menu position next to the selected cell button
    @objc func showOptions(_ sender: UIButton) {

        self.editSectionNameButton.tag = sender.tag
        self.changeSectionIndexButton.tag = sender.tag
        self.removeSectionButton.tag = sender.tag
        
        let buttonFrame = sender.superview?.convert(sender.frame, to: nil)
        guard let topOffset = buttonFrame?.origin.y, let rightOffset = buttonFrame?.origin.x, let buttonWidth = buttonFrame?.width else {return}
        
        sectionOptionsTopConstraint?.constant = topOffset
        sectionOptionsRightConstraint?.constant = rightOffset + buttonWidth

        sectionOptionsContainer.isHidden = false
    }
    
    //MARK: Constraints
    func setupConstraints(){
        
        sectionOptionsRightConstraint = sectionOptionsContainer.rightAnchor.constraint(equalTo: view.leftAnchor)
        sectionOptionsTopConstraint = sectionOptionsContainer.topAnchor.constraint(equalTo: view.topAnchor)
        sectionOptionsWidthConstraint = sectionOptionsContainer.widthAnchor.constraint(equalToConstant: 227)
        sectionOptionsLeadingConstraint = sectionOptionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)//not active for now
        sectionOptionsHeightConstraint = sectionOptionsContainer.heightAnchor.constraint(equalToConstant: 183)
        sectionOptionsHeightConstraint?.isActive = true
        sectionOptionsRightConstraint?.isActive = true
        sectionOptionsTopConstraint?.isActive = true
        sectionOptionsWidthConstraint?.isActive = true
        
        dismissContainerButton.topAnchor.constraint(equalTo: sectionOptionsContainer.topAnchor).isActive = true
        dismissContainerButton.trailingAnchor.constraint(equalTo: sectionOptionsContainer.trailingAnchor).isActive = true
        dismissContainerButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        dismissContainerButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        editSectionNameButton.topAnchor.constraint(equalTo: sectionOptionsContainer.topAnchor, constant: 21).isActive = true
        editSectionNameButton.leadingAnchor.constraint(equalTo: sectionOptionsContainer.leadingAnchor, constant: 18).isActive = true
        editSectionNameButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        editSectionNameButton.trailingAnchor.constraint(equalTo: sectionOptionsContainer.trailingAnchor).isActive = true
        
        changeSectionIndexButton.topAnchor.constraint(equalTo: editSectionNameButton.bottomAnchor, constant: 7).isActive = true
        changeSectionIndexButton.leadingAnchor.constraint(equalTo: sectionOptionsContainer.leadingAnchor, constant: 18).isActive = true
        changeSectionIndexButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        changeSectionIndexButton.trailingAnchor.constraint(equalTo: sectionOptionsContainer.trailingAnchor).isActive = true
        
        removeSectionButton.topAnchor.constraint(equalTo: changeSectionIndexButton.bottomAnchor, constant: 7).isActive = true
        removeSectionButton.leadingAnchor.constraint(equalTo: sectionOptionsContainer.leadingAnchor, constant: 18).isActive = true
        removeSectionButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        removeSectionButton.trailingAnchor.constraint(equalTo: sectionOptionsContainer.trailingAnchor).isActive = true
        
        
        sectionTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sectionTextField.centerYAnchor.constraint(equalTo: sectionOptionsContainer.centerYAnchor).isActive = true
        sectionTextField.leadingAnchor.constraint(equalTo: applySectionModificationButton.trailingAnchor, constant:  20).isActive = true
        sectionTextField.trailingAnchor.constraint(equalTo: sectionOptionsContainer.trailingAnchor, constant: -15).isActive = true
        
        
        
        cancelRenameButton.centerYAnchor.constraint(equalTo: sectionTextField.centerYAnchor).isActive = true
        cancelRenameButton.leadingAnchor.constraint(equalTo: sectionOptionsContainer.leadingAnchor, constant: 20).isActive = true
        cancelRenameButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        cancelRenameButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        applySectionModificationButton.centerYAnchor.constraint(equalTo: sectionTextField.centerYAnchor).isActive = true
        applySectionModificationButton.leadingAnchor.constraint(equalTo: cancelRenameButton.trailingAnchor, constant: 20).isActive = true
        applySectionModificationButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        applySectionModificationButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: projectImageView.topAnchor, constant: 7).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: projectImageView.leadingAnchor, constant: 7).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        
        if let project = self.project {
            
            let rect = NSString(string: project.name).boundingRect(with: CGSize(width: view.frame.width - 124, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 27)], context: nil)
            
            projectTitle.heightAnchor.constraint(equalToConstant: rect.height + 10).isActive = true
        }else{
            projectTitle.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        projectTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62).isActive = true
        projectTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -62).isActive = true
        projectTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35).isActive = true
        
        projectTitleShadow.leadingAnchor.constraint(equalTo: projectTitle.leadingAnchor, constant: 1).isActive = true
        projectTitleShadow.trailingAnchor.constraint(equalTo: projectTitle.trailingAnchor, constant: 1).isActive = true
        projectTitleShadow.topAnchor.constraint(equalTo: projectTitle.topAnchor, constant: 1).isActive = true
        projectTitleShadow.bottomAnchor.constraint(equalTo: projectTitle.bottomAnchor, constant: 1).isActive = true
        
        projectImageView.topAnchor.constraint(equalTo: projectTitle.topAnchor, constant: -20).isActive = true
        projectImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        projectImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        projectImageView.bottomAnchor.constraint(equalTo: projectTitle.bottomAnchor, constant: 20).isActive = true
        
        
        projectWayTableView.topAnchor.constraint(equalTo: projectTitle.bottomAnchor, constant: 32).isActive = true
        projectWayTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        projectWayTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        projectWayTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        lineView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        lineView.topAnchor.constraint(equalTo: projectImageView.bottomAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: projectWayTableView.bottomAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: projectWayTableView.leadingAnchor, constant: 23).isActive = true
    }
    
    //MARK: TextField
    //text field
    func textFieldDidEndEditing(_ textField: UITextField) {
//        updateSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
//        saveButton.isEnabled = false
    }
    
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return projectSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        //TODO: SHOULD CALCULATE HEIGHT RECT BASED ON TEXT
        
        let headerView = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        headerView.menuButton.addTarget(self, action: #selector(showOptions(_:)), for: .touchUpInside)
        headerView.menuButton.tag = section
        
        
        headerView.sectionIndexLabel.text = String(projectSections[section].indexNumber)
        
        
        headerView.sectionTitle.text = projectSections[section].name
        return headerView
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //TODO: SHOULD CALCULATE HEIGHT RECT BASED ON TEXT
        return 50
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        if let stepsArrayForSection = groupedSteps[projectSections[indexPath.section].name] {
            
            dragItem.localObject = stepsArrayForSection[indexPath.row]
        }
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        
        
        if var stepsArrayForSection = groupedSteps[projectSections[sourceIndexPath.section].name] {
            
            //hold step reference for updating inside database
            let targetStep = stepsArrayForSection[sourceIndexPath.row]
            
            let mover = stepsArrayForSection.remove(at: sourceIndexPath.row)
            
            groupedSteps[projectSections[sourceIndexPath.section].name] = stepsArrayForSection
            
            if var destinationArrayForSection = groupedSteps[projectSections[destinationIndexPath.section].name]{
                
                destinationArrayForSection.insert(mover, at: destinationIndexPath.row)

                groupedSteps[projectSections[destinationIndexPath.section].name] = destinationArrayForSection
                
                
                
                let section = projectSections[destinationIndexPath.section]
                
                ProjectListRepository.instance.updateStepSection(step: targetStep, section: section)
                
            }
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let numberOfStepsInSection = groupedSteps[projectSections[section].name] {
            return numberOfStepsInSection.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? ProjectWayCell else {fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )}
        
        if let stepsArrayForSection = groupedSteps[projectSections[indexPath.section].name] {
            cell.template = stepsArrayForSection[indexPath.row]
        }
        
        cell.contentView.isUserInteractionEnabled = false//<-- solution why cell button is not triggered
        
        return cell
    }
    
    
}
//MARK: Cell
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
    }
    
    func setupCell(){
        addSubview(stepTitleLabel)
        addSubview(displayButton)
        
        
        
        displayButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        displayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        displayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        displayButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        stepTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stepTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50).isActive = true
        stepTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36).isActive = true
        stepTitleLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
//MARK: Section Header View
class SectionHeaderView: UIView {
    
    let sectionTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is dummy text for debug purpose only"
        label.backgroundColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let sectionIndexLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "!"
        return label
    }()
    
    let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 224/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        return view
    }()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        
        
        addSubview(circleView)
        addSubview(sectionTitle)
        addSubview(sectionIndexLabel)
        addSubview(menuButton)
        
        
        circleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13).isActive = true
        circleView.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        sectionTitle.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 15).isActive = true
        sectionTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sectionTitle.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -15).isActive = true
        sectionTitle.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        sectionIndexLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
        sectionIndexLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
        sectionIndexLabel.heightAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        sectionIndexLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
        
        menuButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        menuButton.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
