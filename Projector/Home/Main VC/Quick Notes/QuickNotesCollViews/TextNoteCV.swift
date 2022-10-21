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

    //custom zoom in logic
    override func performZoomInForStartingImageView(startingImageView: UIView){
        
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        //canvas
        let zoomingImageView = UIView(frame: startingFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.backgroundColor = UIColor.init(white: 229/255, alpha: 1)
        
        let label = UILabel()
        if let textNoteCell = startingImageView as? TextNoteCell {
            label.text = textNoteCell.textLabel.text
        }
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 25)
//        label.transform = CGAffineTransform(scaleX: 0.35, y: 0.35) //Scale label area
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        zoomingImageView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: zoomingImageView.topAnchor, constant: 10).isActive = true
        label.leadingAnchor.constraint(equalTo: zoomingImageView.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: zoomingImageView.trailingAnchor, constant: -10).isActive = true
        label.bottomAnchor.constraint(equalTo: zoomingImageView.bottomAnchor, constant: -10).isActive = true
       


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
    
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        return button
    }()
    
    //remove item
    @objc func deleteAction (_ sender: UIButton){
        guard let delegate = self.delegate else {return}
        //remove object
        ProjectListRepository.instance.deleteTextNote(textNote: item)
        //update cv
        delegate.updateDatabase()
    }
    
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
        
        addSubview(deleteButton)
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}
//MARK: Pinterest Extension
// Pinterest Layout Configurations
extension TextNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(items[indexPath.row].height + 20)
        return cellHeight
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}
