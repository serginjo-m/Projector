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
    
    var step: ProjectStep?
    
    var stepVC: StepViewController?
    
    //cancel button
    let closeStackView: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
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
    let saveStackView: UIStackView = {
        let stack = UIStackView()
        return stack
    }()
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
        title.font = UIFont.systemFont(ofSize: 18)
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
//        view.backgroundColor = UIColor.yellow
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
        
        view.addSubview(titleLabel)
        view.addSubview(closeStackView)
        closeStackView.addSubview(closeButton)
        closeStackView.addSubview(closeButtonTitle)
        view.addSubview(saveStackView)
        saveStackView.addSubview(saveButton)
        saveStackView.addSubview(saveButtonTitle)
        view.addSubview(noteTitle)
        view.addSubview(noteTextView)
        
        titleLabel.frame = CGRect(x:(view.frame.width - 250) / 2, y: 35, width: 250, height: 30)
        //close button
        closeStackView.frame = CGRect(x: 15, y: 35, width: 30, height: 39)
        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 24)
        closeButtonTitle.frame = CGRect(x:0, y: 24, width: 30, height: 15)
        //26x20
        saveStackView.frame = CGRect(x: view.frame.width - 45, y: 35, width: 30, height: 39)
        saveButton.frame = CGRect(x: 0, y: 0, width: 30, height: 24)
        saveButtonTitle.frame = CGRect(x:0, y: 24, width: 30, height: 15)
        
        noteTitle.frame = CGRect(x: 15, y: 100, width: 170, height: 30)
        noteTextView.frame = CGRect(x: 15, y: 130, width: view.frame.width - 30, height: 100)
        
        realm = try! Realm()//create an instance of object
    }
    
    
    //Dismiss
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    @objc func saveAction(button: UIButton){
        dismiss(animated: true) {
            
            try! self.realm!.write ({//here we actualy add a new object called projectList
                self.step?.itemsArray.append(self.noteTextView.text)
            })
            //clear before dismiss
            self.noteTextView.text = ""
            self.stepVC?.stepTableView.reloadData()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
