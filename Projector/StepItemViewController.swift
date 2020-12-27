//
//  StepItemViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepItemViewController: UIViewController {
    
    var realm: Realm!//create a var
    
    var stepID: String?
    //Instance of Project Selected by User
    var projectStep: ProjectStep? {
        get{
            //Retrieve a single object with unique identifier (stepID)
            return ProjectListRepository.instance.getProjectStep(id: stepID!)
        }
    }
   
    
    var stepItemsTableView: UITableView?
    
    //cancel button
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        return button
    }()
    let closeButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Close"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.darkGray
        return label
    }()
    //save button
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "save"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(saveAction(button:)), for: .touchDown)
        return button
    }()
    let saveButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Save"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.darkGray
        return label
    }()
    //title
    let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Something Long"
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor.darkGray
        title.font = UIFont.systemFont(ofSize: 15)
        return title
    }()
    
    let noteTitle: UILabel = {
        let label = UILabel()
        label.text = "Add Your Note Here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let noteTextView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.darkGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        //perform adding & positioning of views
        setupLayout()
        
        realm = try! Realm()//create an instance of object
    }
    
    private func setupLayout(){
        //calls closure for each item
        [titleLabel, closeButton, closeButtonTitle, saveButton, saveButtonTitle, noteTitle, noteTextView].forEach {
            view.addSubview($0)
        }
        
        noteTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 80, left: 16, bottom: 0, right: 0), size: .init(width: 170, height: 30))
        //note text view
        noteTextView.anchor(top: noteTitle.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 7, left: 16, bottom: 0, right: 16))
        noteTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        saveButton.anchor(top: nil, leading: nil, bottom: titleLabel.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 4, right: 16), size: .init(width: 30, height: 24))
        saveButtonTitle.anchor(top: saveButton.bottomAnchor, leading: nil, bottom: nil, trailing: saveButton.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 30, height: 15))
        
        closeButton.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: titleLabel.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 16, bottom: 4, right: 0), size: .init(width: 30, height: 24))
        closeButtonTitle.anchor(top: closeButton.bottomAnchor, leading: closeButton.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 30, height: 15))

        //title
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 250, height: 30))
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    //Dismiss
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    @objc func saveAction(button: UIButton){
        dismiss(animated: true) {
            
            try! self.realm!.write ({//here we actualy add a new object called projectList
                self.projectStep?.itemsArray.append(self.noteTextView.text)
            })
            //clear before dismiss
            //self.noteTextView.text = ""
            if let tableView = self.stepItemsTableView {
                tableView.reloadData()
            }
        }
        
    }
    
}

//this extension provides constraints
extension UIView {
    //fill superview
    func fillSuperview(){
        //attantion to call :)
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    //match size of another view
    func anchorSize( to view: UIView){
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    //do basic constraint configurations
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        //cancel autoresizing :)
        translatesAutoresizingMaskIntoConstraints = false
        //constraints configuration
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading{
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true//has "-"
        }
        if let trailing = trailing{
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true//has "-"
        }
        //define size
        if size.width != 0{
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0{
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
