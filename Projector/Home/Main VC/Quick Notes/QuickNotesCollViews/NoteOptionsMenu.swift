//
//  NoteOptionsMenu.swift
//  Projector
//
//  Created by Serginjo Melnik on 23/10/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class NoteOptionsMenu: UIView,UITableViewDelegate, UITableViewDataSource {
    
    var delegate: BaseCollectionViewDelegate?
    var currentNoteIndex: Int?
    
    lazy var dismissContainerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let originalImage = UIImage(named: "horizontal_dots")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    lazy var noteToProjectStepButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create project step", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var noteToEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New calendar event", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var removeNoteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Remove note", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.init(displayP3Red: 255/255, green: 113/255, blue: 113/255, alpha: 1), for: .normal)
        return button
    }()
    
    let projectsTableViewTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Select Project From List"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    //table view
    lazy var baseTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.isHidden = true
        return tableView
    }()
    
    
    var cellIdentifier = "cellId"
    
    var projects: Results<ProjectList>{
        get{
            return ProjectListRepository.instance.getProjectLists()
        }
        set{
            //update...
        }
    }
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        
        addSubview(noteToProjectStepButton)
        addSubview(noteToEventButton)
        addSubview(removeNoteButton)
        addSubview(projectsTableViewTitle)
        addSubview(baseTableView)
        addSubview(dismissContainerButton)
        
        dismissContainerButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dismissContainerButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dismissContainerButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        dismissContainerButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        noteToProjectStepButton.topAnchor.constraint(equalTo: topAnchor, constant: 21).isActive = true
        noteToProjectStepButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18).isActive = true
        noteToProjectStepButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        noteToProjectStepButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        noteToEventButton.topAnchor.constraint(equalTo: noteToProjectStepButton.bottomAnchor, constant: 7).isActive = true
        noteToEventButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18).isActive = true
        noteToEventButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        noteToEventButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        removeNoteButton.topAnchor.constraint(equalTo: noteToEventButton.bottomAnchor, constant: 7).isActive = true
        removeNoteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18).isActive = true
        removeNoteButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        removeNoteButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        projectsTableViewTitle.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        projectsTableViewTitle.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        projectsTableViewTitle.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        projectsTableViewTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        baseTableView.topAnchor.constraint(equalTo: projectsTableViewTitle.bottomAnchor, constant: 0).isActive = true
        baseTableView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        baseTableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        baseTableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? BaseTableViewCell else {fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )}
        cell.template = projects[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegateOption = delegate, let noteIndex = currentNoteIndex else {return}
        
        delegateOption.convertNoteToStep(index: noteIndex, project: projects[indexPath.row])

    }
}


class BaseTableViewCell: UITableViewCell {
    //data template
    var template: ProjectList? {
        didSet{
            
            if let template = template {
                
                if let image = template.selectedImagePathUrl{
                    projectImage.image = retreaveImageForProject(myUrl: image)
                }
                projectName.text = template.name
            }
        }
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "scheduledStepEvent")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
    
    let projectImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "river"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let projectName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "No Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.15)
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCell()
    }
    
    func setupCell(){

        //add views
        [contentContainerView, projectImage, projectName].forEach { (subview) in
            addSubview(subview)
        }

        //constraints
        contentContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        contentContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        contentContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        projectImage.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 10).isActive = true
        projectImage.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor, constant: 10).isActive = true
        projectImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        projectImage.widthAnchor.constraint(equalToConstant: 48).isActive = true

        projectName.topAnchor.constraint(equalTo: projectImage.topAnchor, constant: 0).isActive = true
        projectName.leftAnchor.constraint(equalTo: projectImage.rightAnchor, constant: 18).isActive = true
        projectName.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor, constant: -18).isActive = true
        projectName.bottomAnchor.constraint(equalTo: projectImage.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
