//
//  ProgressControl.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.01.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

/*import UIKit
import RealmSwift
import Foundation

class ProgressControl: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Database
    var list: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
    }
    //MARK: Properties
    private let cellID = "cellId"

    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressBar()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupProgressBar()
    }
    
    //here creates a horizontal collectionView inside stackView
    let progressCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    //MARK: Methods
    func setupProgressBar(){
        
            // Add a collectionView to the stackView
            addArrangedSubview(progressCollectionView)
        
            // ?? here we specify delegate & datasourse for generating our individual horizontal cells
            progressCollectionView.dataSource = self
            progressCollectionView.delegate = self
        
            //Class is need to be registered in order of using inside
            progressCollectionView.register(ProgressCell.self, forCellWithReuseIdentifier: cellID)
        
            //CollectionView constraints
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": progressCollectionView]))
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": progressCollectionView]))
        
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    //don't know what was an issue with index path, but it works right now!?
    //defining what actually our cell is
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProgressCell
        cell.template = list[indexPath.item]
        return cell
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 82, height: frame.height)
    }
    
}

class ProgressCell: UICollectionViewCell{
    
    //colors based on projects category
    /*let progressColor = [
        "TRAVEL" : UIColor(red: 0.5, green: 0.7, blue: 0.0, alpha: 1),
        "FINANCE" : UIColor(red: 1, green: 0.7, blue: 0.0, alpha: 1),
        "LEARNING" : UIColor(red: 0.3, green: 0.7, blue: 0.0, alpha: 1),
        "FUN" : UIColor(red: 0.6, green: 0.7, blue: 0.0, alpha: 1),
        "OTHER" : UIColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 1)
    ]*/
 
    //It'll be like a template for our cell
    var template: ProjectList? {
        //didSet uses for logic purposes!
        didSet{
            //safely unwrapping my optional
            if let steps = template?.steps {
                stepsNum.text = "\(steps)"
            }
            
            if let name = template?.name {
                projectName.text = name
            }
            
            if let actual = template?.budget, let total = template?.totalCost {
                investedText.text = "INVESTED \(actual) / \(total)"
            }
            
            if let prog = template?.progress {
                progressView.progress = prog
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3
        layer.masksToBounds = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    //Progress Bar
    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.progressTintColor = UIColor(red: 0.3, green: 0.7, blue: 0.0, alpha: 1)
        pv.trackTintColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        pv.clipsToBounds = true
        pv.transform = CGAffineTransform(rotationAngle: .pi / -2)
        pv.transform = pv.transform.scaledBy(x: 1, y: 1)
        pv.progress = 0.5
        pv.layer.masksToBounds = true
        return pv
    }()
    
    //Number of Steps
    let stepsNum: UILabel = {
        let sn = UILabel()
        sn.text = "23"
        sn.font = UIFont.systemFont(ofSize: 35.0)
        sn.textAlignment = NSTextAlignment.center
        sn.textColor = UIColor.white
        return sn
    }()
    let stepsText:UILabel = {
        let st = UILabel()
        st.text = "STEPS"
        st.textAlignment = NSTextAlignment.center
        st.font = UIFont.systemFont(ofSize: 12.0)
        st.textColor = UIColor.white
        return st
    }()
    let projectName:UILabel = {
        let pn = UILabel()
        pn.text = "Travel to Europe on Motorcycle"
        pn.textAlignment = NSTextAlignment.center
        pn.font = UIFont.systemFont(ofSize: 16.0)
        pn.textColor = UIColor.white
        pn.numberOfLines = 3
        return pn
    }()
    let investedText:UILabel = {
        let it = UILabel()
        it.text = "INVESTED 0 / 0"
        it.textColor = UIColor.white
        it.numberOfLines = 2
        it.textAlignment = NSTextAlignment.center
        it.font = UIFont.systemFont(ofSize: 14.0)
        return it
    }()
    
    //var prog:CGFloat = 20.0
    
    func setupViews(){
        
        //still can't understand how it declared ???
        backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        
        addSubview(progressView)
        addSubview(stepsNum)
        addSubview(stepsText)
        addSubview(projectName)
        addSubview(investedText)
        //progress view configurations
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 55.0).isActive = true
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -55.0).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: 210).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        stepsNum.frame = CGRect(x: 0, y: 21, width: frame.width, height: 50)
        stepsText.frame = CGRect(x: 0, y: 51, width: frame.width, height: 35)
        projectName.frame = CGRect(x: 8, y: 85, width: frame.width - 16, height: 60)
        investedText.frame = CGRect(x: 0, y: frame.height - 50, width: frame.width, height: 40)
        
        
    }
}
*/
