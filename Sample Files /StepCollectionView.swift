////
////  StepCollectionView.swift
////  Projector
////
////  Created by Serginjo Melnik on 31.10.2021.
////  Copyright © 2021 Serginjo Melnik. All rights reserved.
////
//
//import UIKit
//
//class StepCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
//
//    
//    
//    
//    var cellId = "cellID"
//    
//    
//
//    //here creates a horizontal collectionView
//    let stepsCollectionView: UICollectionView = {
//        
//        //instance for UICollectionView purposes
//        let layout = PinterestLayout()
//
//        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
//        // & also we need to specify how "big" it needs to be
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//
//        collectionView.backgroundColor = UIColor.clear
//        
//        //deactivate default constraints
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        return collectionView
//    }()
//    
//    lazy var collectionStackView: UIStackView = {
//
//        let stack = UIStackView()
//        
//        stack.addSubview(stepsCollectionView)
//        
//        //specify delegate & datasourse for generating our individual horizontal cells
//        stepsCollectionView.dataSource = self
//        stepsCollectionView.delegate = self
//        
//        stepsCollectionView.showsHorizontalScrollIndicator = false
//        stepsCollectionView.showsVerticalScrollIndicator = false
//        
//        stepsCollectionView.isScrollEnabled = false
//        
//        //Class is need to be registered in order of using inside
//        stepsCollectionView.register(StepCell.self, forCellWithReuseIdentifier: cellId)
//        
//        //CollectionView constraints
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//        
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//        
//        
//        
//        return stack
//    }()
//
//    override func viewDidLoad() {
//        //setupLayout()
//        
//        //        if let layout = stepsCollectionView.collectionViewLayout as? PinterestLayout {
//        //            layout.delegate = self
//        //        }
//        
//        //this two things
//        //        updateMyArray()
//        
//        //update CV
//        //        stepsCollectionView.reloadData()
//        
//        //create dictionary for steps deleting purposes
//        //        createStepIdDictionary()
//    }
//    
//
//
//    //    //MARK: Collection View Section
//    //    //size
//    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    //        //define cell width
//    //        let cellWidth = self.stepsCollectionView.frame.width/2 - 5
//    //        return CGSize(width: cellWidth, height: 173)
//    //    }
//    //number of cells
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 4
//    }
//
//    //define the cell
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepCell
//        cell.layer.cornerRadius = 12
//        cell.backgroundColor = .blue
//
//        //        let step = localStepsArray[indexPath.row]
//
//        //        cell.stepNameLabel.text = step.name
//        //        cell.doneButton.isSelected = step.complete
//        
//        //        //not all steps include images
//        //        if step.selectedPhotosArray.count > 0 {
//        //            cell.imageView.image = self.delegate?.retreaveImageForProject(myUrl: step.selectedPhotosArray[0])
//        //        }else{
//        //            cell.imageView.image = nil
//        //        }
//        
//        //add tags for being able identify selected cell
//        //        cell.doneButton.tag = stepsIdDictionary[step.id]!
//        //        cell.deleteButton.tag = stepsIdDictionary[step.id]!
//        //        cell.doneButton.addTarget(self, action: #selector(itemCompleted(button:)), for: .touchDown)
//        //        cell.deleteButton.addTarget(self, action: #selector(deleteStep(button:)), for: .touchDown)
//        
//        return cell
//    }
//    //
//    //    //turn cells to be selectable
//    //    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//    //        return true
//    //    }
//    //
//    //    //action when user selects the cell
//    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    //        //segue to step details
//    //        //performSegue(withIdentifier: "ShowStepViewController", sender: nil)
//    //
//    //        showStepDetails(index: indexPath.item)
//    //
//    //    }
//    //    //makes cells deselectable
//    //    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//    //        return true
//    //    }
//    //    //define color of deselected cell
//    //    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//    //
//    //    }
//
//    //    //DELETE ACTION
//    //    @objc func deleteStep( button: UIButton){
//    //        //create new alert window
//    //        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
//    //        //cancel button
//    //        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//    //        //delete button
//    //        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
//    //
//    //            UserActivitySingleton.shared.createUserActivity(description: "Deleted \(self.localStepsArray[button.tag].name)")
//    //
//    //            //delete step in data base
//    //            ProjectListRepository.instance.deleteProjectStep(list: self.projectInstance!, stepAtIndex: button.tag)
//    //            //update array for collection veiw
//    //            self.updateMyArray()
//    //            //reload views with new data after editing
//    //            self.reloadViews()
//    //            //perform actions step by step
//    //            self.stepCategoriesFilter.updateCategoriesCV()
//    //        })
//    //
//    //        alertVC.addAction(cancelAction)
//    //        alertVC.addAction(deleteAction)
//    //        //shows an alert window
//    //        present(alertVC, animated: true, completion: nil)
//    //    }
//    //
//    //    //COMPLETED ACTION
//    //    @objc func itemCompleted(button: UIButton){
//    //        guard let step = projectInstance?.projectStep[button.tag] else {return}
//    //        //assign an opposite value to button.isSeleceted
//    //        button.isSelected = !button.isSelected
//    //
//    //        //func that change complete bool of the step
//    //        ProjectListRepository.instance.updateStepCompletionStatus(step: step, isComplete: button.isSelected)
//    //
//    //        let completedString = button.isSelected == true ? "completed" : "not completed"
//    //        UserActivitySingleton.shared.createUserActivity(description: "\(step.name) is \(completedString)")
//    //        //update views after data source has been changed
//    //        reloadViews()
//    //    }
//    //
//    //    //MARK: FILTER LOGIC
//    //
//    //    //creates array for CV based on data source
//    //    func updateMyArray(){
//    //        guard let array = projectInstance?.projectStep else {return}
//    //        //clear all step from array
//    //        localStepsArray.removeAll()
//    //
//    //        //add all steps to array
//    //        for item in array {
//    //            localStepsArray.append(item)
//    //        }
//    //        /*becouse of dequeue issue have to
//    //         create dictionary where step id is corresponds to position in ...
//    //         */
//    //        createStepIdDictionary()
//    //    }
//    //
//    //    //DELETE PURPOSES
//    //    //Dictionary that holds position of step in array based on step id
//    //    func createStepIdDictionary(){
//    //        //clear old data
//    //        stepsIdDictionary.removeAll()
//    //
//    //        if let stArr = projectInstance?.projectStep{
//    //            for step in stArr{
//    //                stepsIdDictionary[step.id] = stArr.index(of: step)
//    //            }
//    //        }
//    //    }
//}
