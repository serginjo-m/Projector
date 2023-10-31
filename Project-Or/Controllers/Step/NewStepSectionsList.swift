//
//  NewStepSectionsList.swift
//  Projector
//
//  Created by Serginjo Melnik on 29/09/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//MARK: OK
class NewStepSectionsList: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Properties
    var cellIdentifier = "cellId"
    
    var projectId: String
    
    var sections: [StepWaySection] = []
    
    var parentViewControllerExtension: NewStepViewController?
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 4
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.contentHorizontalAlignment = .left
        button.layer.masksToBounds = true
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select step section"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    //name text field
    lazy var sectionTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.placeholder = "New Step Section"
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // Handle the text field's user input through delegate callback.
        textField.delegate = self
        return textField
    }()
    
    lazy var addSectionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
        let midnightBlack = UIColor.init(white: 55/255, alpha: 1)
        button.setBackgroundColor(midnightBlack, forState: .disabled)
        button.setImage(UIImage(named: "crossIcon"), for: .normal)
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.isEnabled = false
        return button
    }()
    
    //table view
    lazy var sectionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SectionCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        return tableView
    }()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(sectionTextField)
        view.addSubview(addSectionButton)
        view.addSubview(sectionsTableView)
        
        setupConstraints()
        
    }
    
    //MARK: Initialization
    init(projectId: String, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.projectId = projectId
        let allSections = ProjectListRepository.instance.getAllStepSections()
        let sectionsDictionary = Dictionary(grouping: allSections) { section -> String in
            return section.projectId
        }
        if let currentProjectSections = sectionsDictionary[projectId] {
            self.sections = currentProjectSections
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    
    fileprivate func setupConstraints(){
        
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 90).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 23).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        sectionTextField.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 40).isActive = true
        sectionTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        sectionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        sectionTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addSectionButton.centerYAnchor.constraint(equalTo: sectionTextField.centerYAnchor).isActive = true
        addSectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addSectionButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        addSectionButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        sectionsTableView.topAnchor.constraint(equalTo: sectionTextField.bottomAnchor, constant: 0).isActive = true
        sectionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sectionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sectionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    @objc private func handleDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapAddButton(){
        
        if let sectionName = self.sectionTextField.text  {
            let section = StepWaySection()
            section.name = sectionName
            section.projectId = self.projectId
            section.indexNumber = sections.count
            setStepSectionAndDismiss(stepWaySection: section)
        }
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField){
        updatePlusButtonState()
    }
    
    private func setStepSectionAndDismiss(stepWaySection: StepWaySection){
        parentViewControllerExtension?.stepSection = stepWaySection
        parentViewControllerExtension?.sectionButton.setTitle("   \(stepWaySection.name)", for: .normal)
        dismiss(animated: true)
    }
    
    private func updatePlusButtonState(){
        //Disable the Save button when text field is empty.
        let text = sectionTextField.text ?? ""
        addSectionButton.isEnabled = !text.isEmpty
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePlusButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: TableView section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? SectionCell else {fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )}
        
        cell.sectionNameLabel.text = "\(sections[indexPath.row].indexNumber)   \(sections[indexPath.row].name)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setStepSectionAndDismiss(stepWaySection: self.sections[indexPath.row])
    }
}
