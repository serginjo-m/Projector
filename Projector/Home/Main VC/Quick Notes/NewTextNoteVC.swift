//
//  TextNoteVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 13.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class TextNoteViewController: UIViewController,  UINavigationControllerDelegate, UITextViewDelegate{
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Text Note"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    let noteTitle: UILabel = {
        let label = UILabel()
        label.text = "Add Your Note Here"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var noteTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        textView.font = UIFont.boldSystemFont(ofSize: 17)
        textView.textColor = UIColor.init(white: 0.3, alpha: 1)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        view.addSubview(saveButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(noteTitle)
        view.addSubview(noteTextView)
        
        setupConstraints()
        //includes keyboard dismiss func from extension
        self.hideKeyboardWhenTappedAround()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        guard let textNoteString = self.noteTextView.text else {return}
        
        let textNote = self.createTextNote(text: textNoteString)
        
        ProjectListRepository.instance.createTextNote(textNote: textNote)
        UserActivitySingleton.shared.createUserActivity(description: "Text Note was Created")
        self.dismiss(animated: true)
    }
    
    //create text note object
    func createTextNote(text: String) -> TextNote{
        //        guard let height = self.selectedImageHeight, let width = selectedImageWidth else {fatalError()}
        let textNote = TextNote()
        
        let rect = NSString(string: text).boundingRect(with: CGSize(width: view.frame.width / 2.2, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
        
        textNote.height = Int(rect.height)
        textNote.text = text
        
        return textNote
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty == false {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
    
    func setupConstraints(){
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        noteTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 20).isActive = true
        noteTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        noteTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        noteTitle.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        noteTextView.topAnchor.constraint(equalTo: noteTitle.bottomAnchor, constant: 10).isActive = true
        noteTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        noteTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
}
