//
//  CanvasCVViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class TextNotesCollectionViewController: BaseCollectionViewController<TextNoteCell, TextNote>{
    
    //MARK: Properties
    var textNotes: Results<TextNote>{
        get{
            return ProjectListRepository.instance.getTextNotes()
        }
        set{
            //need this option for updating after delete
        }
    }
    
    //animation start point
    var startingFrame: CGRect?
    //black bg
    var blackBackgroundView: UIView?
    //view to zoom in
    var startingImageView: UIView?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
        viewControllerTitle.text = "Text Notes"
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDatabase()
    }
    
    //MARK: Methods
    //reload everything
    override func updateDatabase() {
        //update data base
        textNotes = ProjectListRepository.instance.getTextNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    //convert Realm Result<...> to an array of object.
    func setupDatabase() {
        
        //clear old data from array
        items.removeAll()
        
        //not so efficient, but it works
        for item in textNotes {
            items.append(item)
        }
        
    }
    
    @objc override func convertToEvent(_ sender: UIButton){
        
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}
        let quickNote = items[index]
        let newEventViewController = NewEventViewController()
        newEventViewController.modalTransitionStyle = .coverVertical
        newEventViewController.modalPresentationStyle = .fullScreen
                //define event name
        newEventViewController.descriptionTextView.text = quickNote.text
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        //show new event view controller
        present(newEventViewController, animated: true, completion: nil)
       
    }
    
    override func removeQuickNote(_ sender: UIButton) {
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}
        let quickNote = items[index]
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Text Note?", message: "Are You sure You want to delete this note?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            ProjectListRepository.instance.deleteTextNote(textNote: quickNote)
            
            self.sectionOptionsContainer.isHidden = true

            self.updateDatabase()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    override func convertNoteToStep(index: Int, project: ProjectList) {
        
        let textNote = textNotes[index]
        
        let wordsArray = textNote.text.components(separatedBy: " ")
        
        var compoundTitleForStep = ""
        
        if wordsArray.count < 3 {
            guard let firstWord = wordsArray.first else {return}
            compoundTitleForStep = firstWord
        }else{
            for number in 0...2 {
                if number < 2 {
                    compoundTitleForStep.append("\(wordsArray[number]) ")
                }else{
                    compoundTitleForStep.append("\(wordsArray[number])...")
                }
            }
        }
        
        let newStepViewController = NewStepViewController()
        newStepViewController.projectId = project.id
        newStepViewController.viewControllerTitle.text = project.name
        newStepViewController.stepNameTextField.text = compoundTitleForStep
        newStepViewController.comment = textNote.text
        newStepViewController.descriptionTextView.text = textNote.text
        newStepViewController.modalPresentationStyle = .fullScreen
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        present(newStepViewController, animated: true)
    }
    

    //custom zoom in logic
    override func performZoomInForStartingImageView(startingImageView: UIView){
        
        if sectionOptionsContainer.isHidden == false {
            optionsMenuToggle(toggle: true)
            sectionOptionsContainer.isHidden = true
        }
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        //canvas
        let zoomingImageView = TextNoteView(frame: startingFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.backgroundColor = UIColor.init(white: 229/255, alpha: 1)
        
       
        if let textNoteCell = startingImageView as? TextNoteCell {
            zoomingImageView.textLabel.text = textNoteCell.textLabel.text
        }
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black

            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)

            //math? of proportion with one side
            //h2 / w2 = h1 / w1
            //h2 = h1 / w1 * w2

            let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
//                label.transform = CGAffineTransform(scaleX: 1, y: 1) //Scale label area
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center

            }, completion: nil)

        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 5
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                if let label = zoomOutImageView.subviews.first as? UILabel {
//                    label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) //Scale label area
                    label.font = UIFont.boldSystemFont(ofSize: 15)
                }
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                
                //remove it completely
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
//MARK: Cell
//Photo note cell
class TextNoteCell: BaseCollectionViewCell<TextNote> {
    
    //It'll be like a template for our cell
    override var item: TextNote! {
        //didSet uses for logic purposes!
        didSet{
            textLabel.text = item.text
        }
    }
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //call to zoom in logic
    @objc func handleZoomTap(sender: UITapGestureRecognizer){

        guard let delegate = self.delegate else {return}
        
        if let view = sender.view {
            delegate.performZoomInForStartingImageView(startingImageView: view)
        }
    }
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.init(white: 229/255, alpha: 1)
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
      
    }
}
//MARK: Pinterest Extension
// Pinterest Layout Configurations
extension TextNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let text = items[indexPath.row].text
        
        let rect = NSString(string: text).boundingRect(with: CGSize(width: view.frame.width - 30, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
        
        return rect.height + 30
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}

class TextNoteView: UIView {
    
    let textLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 25)
    //        label.transform = CGAffineTransform(scaleX: 0.35, y: 0.35) //Scale label area
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
