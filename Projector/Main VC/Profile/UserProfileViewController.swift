//
//  UserProfileViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 19/03/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, CircleTransitionable {
    
    var transitionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.backgroundColor = .black
//        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    var mainView: UIView {
        return view
    }
    
    let contentTextView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 26.0)]
        let storyAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0)]
        
        let mutableAttrString = NSMutableAttributedString(string: "Beep boop, you've unlocked a new\n something or other that I call \"Tech Talk\"\n\n", attributes:titleAttributes)
        mutableAttrString.append(NSAttributedString(string: "Hi, I'm Pong. Tap the black dot,\n choose stuff you care about and close\n me when you're done. You're going to\n like me.\n\nTouch me.", attributes:storyAttributes))
        
        textView.attributedText = mutableAttrString
        textView.backgroundColor = .clear
        
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        // Do any additional setup after loading the view.
        view.addSubview(transitionButton)
        view.addSubview(contentTextView)
        
        contentTextView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        contentTextView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        contentTextView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        contentTextView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
        transitionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 19).isActive = true
        transitionButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        transitionButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        transitionButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        if let navController = navigationController{
            let transitionCoordinator = TransitionCoordinator()
            navController.delegate = transitionCoordinator
            navigationController?.popViewController(animated: true)
        }
    }
}
