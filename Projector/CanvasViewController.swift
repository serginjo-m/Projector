//
//  CanvasNote.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CanvasView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.setStrokeColor(UIColor.brown.cgColor)
        context.setLineWidth(10)
        context.setLineCap(.butt)
     
        canvasObject.canvasLines.forEach { (line) in

            for (i, p) in line.singleLine.enumerated(){
                //convert object to CGPoint
                let point = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))
                
                //line first point
                if i == 0{
                    //starts
                    context.move(to: point)
                }else{
                    //ends
                    context.addLine(to: point)
                }
            }
        }
        
        context.strokePath()
    }
    
    //object that fits to realm
    let canvasObject = CanvasNote()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        canvasObject.canvasLines.append(SingleLineObject())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: nil) else {return}
        
        //write CGPoint to custom object
        let linePoint = LineCGPoint()
        linePoint.x = Float(point.x)
        linePoint.y = Float(point.y)
        
        //capture line from array
        //instead of getting copy of line
        guard let lastLine = canvasObject.canvasLines.last else {return}
        canvasObject.canvasLines.removeLast()
        //add new point to line
        lastLine.singleLine.append(linePoint)
        //add it back into the lines array
        canvasObject.canvasLines.append(lastLine)
        //redraw canvas
        setNeedsDisplay()
    }
}

class CanvasViewController: UIViewController {
    
    let canvas = CanvasView()
    
    let dismissButton: UIButton = {
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
        label.text = "New Shot"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("    Save to...", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        
        view.addSubview(canvas)
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(saveButton)
        
        canvas.backgroundColor = .white
        canvas.frame = view.frame
        
        setupConstraints()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        //ALERT MENU
        let alert = UIAlertController(title: "Select Save Option", message: "Please select the desired Save Option", preferredStyle: .actionSheet)
        
        //creates save options
        ["Save To Project", "Save To Project Step", "Save To Events"].forEach {
            let action = UIAlertAction(title: $0, style: .default) { (action: UIAlertAction) in
                self.dismiss(animated: true, completion: {
                    //perform something
                })
            }
            
            alert.addAction(action)
        }
        
        //SAVE TO QUICK NOTES
        let action1 = UIAlertAction(title: "Save To Quick Notes", style: .default) { (action: UIAlertAction) in
            //get canvas object
            let canvasNote = self.canvas.canvasObject
            //save to data base
            ProjectListRepository.instance.createCanvasNote(canvasNote: canvasNote)
            //add action to activity journal
            UserActivitySingleton.shared.createUserActivity(description: "Canvas Note was Created")
            //exit from view
            self.dismiss(animated: true, completion: {
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            // Do nothing
        }
        
        alert.addAction(action1)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
    }
}
