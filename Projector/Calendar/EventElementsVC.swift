//
//  EventElementsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 06.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//because I need to reuse it in DetailViewController
class ElementsViewController: UIView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableView(){
        
    }
}

class EventElementsViewController: ElementsViewController, UITableViewDelegate, UITableViewDataSource{
    
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "eventsTableViewCell"
    
    let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "This is Date"
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    //small orange line
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 229/255, alpha: 1)
        return view
    }()
    
    //TABLE VIEW
    let eventsTableView = UITableView()
    
    //data for collection view
    var events: [Event] = []
    
    //parent already has this function and call to it, so only thing I need is to override it!
    override func setupTableView(){
        backgroundColor = .white
        
        addSubview(selectedDateLabel)
        addSubview(lineView)
        addSubview(eventsTableView)
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.register(EventTableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        setupConstraints()
    }
    
    func setupConstraints(){
        
        NSLayoutConstraint.deactivate(eventsTableView.constraints)
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        selectedDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        selectedDateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        selectedDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        selectedDateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        lineView.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 13).isActive = true
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    
        eventsTableView.topAnchor.constraint(equalTo: lineView.topAnchor, constant:  15).isActive = true
        eventsTableView.leadingAnchor.constraint(equalTo: lineView.leadingAnchor, constant:  0).isActive = true
        eventsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        eventsTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        eventsTableView.separatorStyle = .none
        eventsTableView.backgroundColor = .clear
    
    }
    
    //table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? EventTableViewCell else {
            fatalError( "The dequeued cell is not an instance of EventTableViewCell." )
        }
        
        cell.event = events[indexPath.row]
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeItem(button:)), for: .touchUpInside)
        return cell
    }
    
    //REMOVE ITEM
    @objc func removeItem(button: UIButton){
        UserActivitySingleton.shared.createUserActivity(description: "\(self.events[button.tag].title) event was removed")

        //remove event from database
        ProjectListRepository.instance.deleteEvent(event: self.events[button.tag])
        //remove from table view datasource
        events.remove(at: button.tag)
        //reload tableView
        self.eventsTableView.reloadData()
    }

}

//gradint inside view so it can use constraints
class GradientView: UIView {
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    private let gradientStartColor: UIColor
    private let gradientMiddleColor: UIColor
    private let gradientEndColor: UIColor
    
    init(gradientStartColor: UIColor, gradientMiddleColor: UIColor, gradientEndColor: UIColor) {
        self.gradientStartColor = gradientStartColor
        self.gradientMiddleColor = gradientMiddleColor
        self.gradientEndColor = gradientEndColor
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
        gradient.locations = [0.0, 0.3, 0.6]
    }
    
    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        gradient.colors = [gradientEndColor.cgColor, gradientMiddleColor.cgColor, gradientStartColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}


class EventTableViewCell: UITableViewCell {
    
    var event: Event? {
        didSet{
            
            guard let event = event, let date = event.date else {return}
            //event date configuration
            let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: date)
            
            if let hour = components.hour, let minute = components.minute{

                let string = "\(hour):\(minute)   \(event.title)"
                
                let mutableString = NSMutableAttributedString(string: string, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                
                let greenColor = UIColor.init(red: 31/255, green: 177/255, blue: 68/255, alpha: 1)
                
                mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: greenColor, range: NSRange(location:0, length:5))
                
                taskLabel.attributedText = mutableString
            }
            
            
            //--------------------------------------------------------------------------------------------
            //---------------- this bit of logic needs to be refined a bit -------------------------------
            //--------------------------------------------------------------------------------------------
            
            if let image = event.picture{
                eventImageView.retreaveImageUsingURLString(myUrl: image)
                
                gradientView.isHidden = false
                shadowLabel.isHidden = false
                removeButton.isSelected = false
                descriptionLabel.text = "\n\n\n\n"//adds top spacing to description
                shadowLabel.text = descriptionLabel.text
            }else{
                eventImageView.image = nil
                
                gradientView.isHidden = true
                shadowLabel.isHidden = true
                removeButton.isSelected = true
                descriptionLabel.text = ""//remove top spacing if there is no image
            }
            //define description
            if let description = event.descr{
                descriptionLabel.text! += description
                shadowLabel.text = descriptionLabel.text
            }else{
                descriptionLabel.text = "no description ..."
                shadowLabel.text = descriptionLabel.text
            }
            
            //description label height
            let rect = NSString(string: descriptionLabel.text!).boundingRect(with: CGSize(width: frame.width , height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
            
            //----------------------------------------------------------------------------------------
            //----------------------------- image needs proper sizing --------------------------------
            //----------------------------------------------------------------------------------------
            
            //configure image height constraint based on description label height
            imageHeightAnchor?.constant = rect.height + 100

            if event.category == "projectStep"{
                descriptionLabel.textColor = .white
                removeButton.backgroundColor = UIColor.init(white: 32/255, alpha: 1)
                eventImageView.isHidden = false
            }else{
                descriptionLabel.textColor = UIColor.init(white: 85/255, alpha: 1)
                removeButton.backgroundColor = UIColor.init(white: 230/255, alpha: 1)
                eventImageView.isHidden = true
            }
        }
    }
    
    let orangeLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 255/255, green: 116/255, blue: 166/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.init(white: 115/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "big3Dots"), for: .normal)
        button.setImage(UIImage(named: "bigBlack3Dots"), for: .selected)
        button.contentMode = .center
        button.imageView!.contentMode = .scaleAspectFill
        button.backgroundColor = UIColor.init(white: 230/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        label.textColor = UIColor.init(white: 85/255, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let shadowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        label.textColor = UIColor.init(white: 0.2, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.init(white: 241/255, alpha: 1)
        bg.layer.cornerRadius = 12
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = true
        return bg
    }()
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "workspace")
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
   
    let gradientView: GradientView = {
        let topColor = UIColor.init(white: 32/255, alpha: 0)
        let middleColor = UIColor.init(white: 32/255, alpha: 0.68)
        let bottomColor = UIColor.init(white: 32/255, alpha: 1)
        let gradient = GradientView(gradientStartColor: topColor, gradientMiddleColor: middleColor, gradientEndColor: bottomColor)
        gradient.isHidden = true
        gradient.translatesAutoresizingMaskIntoConstraints = false
        return gradient
    }()
    
    var imageHeightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(taskLabel)
        addSubview(orangeLine)
        
        addSubview(backgroundBubble)
        addSubview(shadowLabel)
        addSubview(descriptionLabel)
        
        
        backgroundBubble.addSubview(eventImageView)
        
        backgroundBubble.addSubview(gradientView)
        backgroundBubble.addSubview(removeButton)
        
        
        let constraints = [
            
            orangeLine.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            orangeLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            orangeLine.widthAnchor.constraint(equalToConstant: 2),
            orangeLine.heightAnchor.constraint(equalToConstant: 26),
            
            taskLabel.topAnchor.constraint(equalTo: orangeLine.topAnchor, constant: 0),
            taskLabel.leadingAnchor.constraint(equalTo: orangeLine.trailingAnchor, constant: 13),
            taskLabel.heightAnchor.constraint(equalToConstant: 26),
            taskLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            descriptionLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 22),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -37),
            
            shadowLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 23),
            shadowLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 33),
            shadowLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -29),
            shadowLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36),
            
            backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16),
            backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 37),
            
            gradientView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            gradientView.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0),
            gradientView.leftAnchor.constraint(equalTo: backgroundBubble.leftAnchor, constant: 0),
            gradientView.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            
            removeButton.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            removeButton.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        eventImageView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0).isActive = true
        
        imageHeightAnchor = eventImageView.heightAnchor.constraint(equalToConstant: 100)
        
        imageHeightAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
