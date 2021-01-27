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
    
    //TABLE VIEW
    let eventsTableView = UITableView()
    
    //data for collection view
    var events: [Event] = []
    
    //parent already has this function and call to it, so only thing I need is to override it!
    override func setupTableView(){
        
        backgroundColor = .white
        
        addSubview(selectedDateLabel)
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
        
            eventsTableView.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant:  21).isActive = true
            eventsTableView.leftAnchor.constraint(equalTo: leftAnchor, constant:  24).isActive = true
            eventsTableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
            eventsTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
            
            eventsTableView.separatorStyle = .none
        
    }
    
    //table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
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
        //remove event from database
        ProjectListRepository.instance.deleteEvent(event: self.events[button.tag])
        //remove from table view datasource
        events.remove(at: button.tag)
        //reload tableView
        self.eventsTableView.reloadData()
//        print("this is event \(self.events[button.tag])")
    }
    
    
    
}
class EventTableViewCell: UITableViewCell {
    
    var event: Event? {
        didSet{
            guard let event = event else {return}
            
            taskLabel.text = event.title.uppercased()
            
            if let description = event.descr{
                descriptionLabel.text = description
            }else{
                descriptionLabel.text = "no description ..."
            }
        }
    }
    let titleIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        return image
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "removeItem"), for: .normal)
        //        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.contentMode = .center
        button.imageView!.contentMode = .scaleAspectFill
        
        button.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        
        return button
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        //label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bg.layer.cornerRadius = 12
        //        bg.layer.borderWidth = 1
        //        bg.layer.borderColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        bg.layer.masksToBounds = true
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = UIColor.lightGray
        
        addSubview(taskLabel)
        addSubview(titleIcon)
        
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        backgroundBubble.addSubview(removeButton)
        
        titleIcon.frame = CGRect(x: 0, y: 8, width: 16, height: 14)
        taskLabel.frame = CGRect(x: 23, y: 0, width: 250, height: 30)
        // removeButton.frame = CGRect(x: Int(frame.width) - 67, y: 5, width: 77, height: 17)
        
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundBubble.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -37),
            
            backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16),
            backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 37),
            
            removeButton.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            removeButton.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            removeButton.widthAnchor.constraint(equalToConstant: 35),
            removeButton.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
