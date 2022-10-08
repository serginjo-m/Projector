//
//  ProjectWayVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 29/09/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectWayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    
    //MARK: Properties
    var cellIdentifier = "cellId"
    
    var project: ProjectList?
    
    var steps: [ProjectStep] = []
    
    var projectSections: [String] = []
    
    var groupedSteps: [String : [ProjectStep]] = [:]
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 4
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.masksToBounds = true
        return button
    }()
   
    let projectTitle: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "This is Project Name"
        title.font = UIFont.boldSystemFont(ofSize: 35)
        title.textAlignment = .left
        title.textColor = UIColor.init(white: 0.1, alpha: 1)
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
        tableView.allowsSelection = true
        return tableView
    }()
    
    
    //MARK: Init
    init(projectId: String, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
                
        self.project = ProjectListRepository.instance.getProjectList(id: projectId)
        
        if let project = project {
            steps.append(contentsOf: project.projectStep)
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(dismissButton)
        view.addSubview(projectTitle)
        view.addSubview(projectWayTableView)
        //title & database
        configureViewController()

        setupConstraints()
    }
    
    fileprivate func configureViewController(){
        
        if let project = project{
            projectTitle.text = project.name
        }
        
        //database
        groupedSteps = Dictionary(grouping: steps, by: { step -> String in
            guard let section = step.section else {return step.id}
            return section.name
        })
        
        projectSections = groupedSteps.map({ $0.key})
    }
    
    //MARK: Methods
    @objc private func handleDismiss(){
        dismiss(animated: true)
    }
    
    func setupConstraints(){
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        projectTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        projectTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        projectTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        projectTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 30).isActive = true
        
        projectWayTableView.topAnchor.constraint(equalTo: projectTitle.bottomAnchor, constant: 0).isActive = true
        projectWayTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        projectWayTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        projectWayTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return projectSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "\(projectSections.count - section)   \(projectSections[section])"
        
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        if let stepsArrayForSection = groupedSteps[projectSections[indexPath.section]] {
            dragItem.localObject = stepsArrayForSection[indexPath.row]
        }
            return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if var stepsArrayForSection = groupedSteps[projectSections[sourceIndexPath.section]] {
            
            let mover = stepsArrayForSection.remove(at: sourceIndexPath.row)
            
            groupedSteps[projectSections[sourceIndexPath.section]] = stepsArrayForSection
            
            if var destinationArrayForSection = groupedSteps[projectSections[destinationIndexPath.section]]{
                
                destinationArrayForSection.insert(mover, at: destinationIndexPath.row)

                groupedSteps[projectSections[destinationIndexPath.section]] = destinationArrayForSection
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let numberOfStepsInSection = groupedSteps[projectSections[section]] {
            return numberOfStepsInSection.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? ProjectWayCell else {fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )}
        
        if let stepsArrayForSection = groupedSteps[projectSections[indexPath.section]] {
            cell.template = stepsArrayForSection[indexPath.row]
        }
        
        return cell
    }
    
    
}
//MARK: Cell
class ProjectWayCell: UITableViewCell {
    
    var template: ProjectStep? {
        didSet{
            guard let template = template else {return}
            
            stepTitleLabel.text = template.name
        }
    }
    
    let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCell()
    }
    
    
    func setupCell(){
        addSubview(stepTitleLabel)
        
        stepTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stepTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        stepTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stepTitleLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
