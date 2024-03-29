//
//  SidePanelView.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class SidePanelView: ElementsView, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    var realm: Realm!
    var project: ProjectList?
    var projectId = String() {
        didSet{
            project = ProjectListRepository.instance.getProjectList(id: projectId)
        }
    }
    
    let valuePickerDataSource = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    let cellIdentifier = "eventsTableViewCell"
    
    var selectedValue: Int?
    var investedValue = 0
    var spendedValue = 0
    
    var tableViewDataSource = [StatisticData](){
        didSet{
            investedValue = 0
            spendedValue  = 0
        
            for item in tableViewDataSource{
                if item.positiveNegative == 1{
                    investedValue += item.number
                }else{
                    spendedValue += item.number
                }
            }
            
            switch categoryKey{
            case "money":
                totalValueLabel.text = "\(investedValue)$ | \(spendedValue)$"
            case "time":
                totalValueLabel.text = "\(spendedValue) Hours"
            case "fuel":
                totalValueLabel.text = "\(spendedValue) Liters"
            default:
                break
            }
            
        }
    }
    
    var categoryKey = "" {
        didSet{
            configurationByCategory(category: categoryKey)
            createTableViewDataSource(key: categoryKey)
            plusMinusSegmentedControl.selectedSegmentIndex = 0
            valuePicker.selectRow(0, inComponent: 0, animated: false)
            valuePicker.selectRow(0, inComponent: 1, animated: false)
            valuePicker.selectRow(0, inComponent: 2, animated: false)
            commentTextField.text = ""
            selectedValue = nil
            saveButton.isEnabled = false
        }
    }
    
    let selectedStatisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "This is Date"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let totalValueLabel: UILabel = {
        let label = UILabel()
        label.text = "10.542 $"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    let statisticImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "totalCost")
        return image
    }()
    
    lazy var openViewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(displayP3Red: 65/255, green: 50/255, blue: 67/255, alpha: 1)
        button.setImage(UIImage.init(named: "minusSymbol"), for: .normal)
        button.addTarget(self, action: #selector(handleAnimate), for: .touchUpInside)
        button.layer.cornerRadius = 18
        return button
    }()
    let minusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "verticalBar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var maxHeightAnchor: NSLayoutConstraint?
    var minHeightAnchor: NSLayoutConstraint?
    
    lazy var panelTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PanelTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        return tableView
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 65/255, green: 50/255, blue: 67/255, alpha: 1)
        view.clipsToBounds = true
        return view
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 0.3)])
        textField.font = UIFont.boldSystemFont(ofSize: 22)
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        return view
    }()
    
    let plusMinusSegmentedControl: UISegmentedControl = {
        let items = ["minus", "plus"]
        let control = UISegmentedControl(items: items)
        control.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        control.tintColor = UIColor.init(white: 0.9, alpha: 1)
        control.layer.masksToBounds = true
        control.layer.cornerRadius = 5
        control.setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: UIColor.init(red: 56/255, green: 44/255, blue: 57/255, alpha: 1)], for: .normal)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let valuePickerTitle: UILabel = {
        let label = UILabel()
        label.text = "Movement"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let valuePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .clear
        return picker
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add New Element", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor.init(displayP3Red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.titleLabel?.textColor = .white
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func setupTableView() {
        realm = try! Realm()
        
        backgroundColor = .white
        
        addSubview(selectedStatisticsLabel)
        addSubview(totalValueLabel)
        addSubview(statisticImage)
        addSubview(containerView)
        containerView.addSubview(plusMinusSegmentedControl)
        containerView.addSubview(valuePickerTitle)
        containerView.addSubview(valuePicker)
        containerView.addSubview(commentTextField)
        containerView.addSubview(lineUIView)
        containerView.addSubview(saveButton)
        addSubview(openViewButton)
        addSubview(minusImageView)
        addSubview(panelTableView)
        
        valuePicker.delegate = self
        valuePicker.dataSource = self
        
        commentTextField.delegate = self

        setupConstraints()
    }
    
    func configurationByCategory(category: String){
        switch category {
        case "money" :
            plusMinusSegmentedControl.isHidden = false
            statisticImage.image = UIImage(named: "totalCost")
            selectedStatisticsLabel.text = "Invested | Spended"
            backgroundColor = UIColor.init(displayP3Red: 95/255, green: 74/255, blue: 99/255, alpha: 1)
            containerView.backgroundColor = UIColor.init(displayP3Red: 65/255, green: 50/255, blue: 67/255, alpha: 1)
            openViewButton.backgroundColor = UIColor.init(displayP3Red: 65/255, green: 50/255, blue: 67/255, alpha: 1)
        case "time":
            plusMinusSegmentedControl.isHidden = true
            statisticImage.image = UIImage(named: "clock")
            selectedStatisticsLabel.text = "Time Spended"
            backgroundColor = UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1)
            containerView.backgroundColor = UIColor.init(displayP3Red: 17/255, green: 85/255, blue: 187/255, alpha: 1)
            openViewButton.backgroundColor = UIColor.init(displayP3Red: 17/255, green: 85/255, blue: 187/255, alpha: 1)
        case "fuel":
            plusMinusSegmentedControl.isHidden = true
            statisticImage.image = UIImage(named: "fuelC")
            selectedStatisticsLabel.text = "Fuel Spended"
            backgroundColor = UIColor.init(red: 217/255, green: 98/255, blue: 72/255, alpha: 1)
            containerView.backgroundColor = UIColor.init(displayP3Red: 121/255, green: 51/255, blue: 35/255, alpha: 1)
            openViewButton.backgroundColor = UIColor.init(displayP3Red: 121/255, green: 51/255, blue: 35/255, alpha: 1)
        default:
            break
        }
    }
    
    func createTableViewDataSource(key: String){
        guard let project = project else {return}
        tableViewDataSource.removeAll()
        
        if let dictionary = project.groupedDictionary{
            guard let array = dictionary[key] else {
                panelTableView.reloadData()
                return
            }
            tableViewDataSource = array
        }
        panelTableView.reloadData()
    }
    
    @objc func saveAction(_ sender: Any) {
        guard let proj = project else {return}
        let statisticData: StatisticData = self.defineStatisticDataTemplate()
        try! self.realm!.write ({
            proj.projectStatistics.append(statisticData)
        })
        let addSubtract = statisticData.positiveNegative == 0 ? "-" : "+"
        UserActivitySingleton.shared.createUserActivity(description: "\(proj.name):\n \(addSubtract)\(statisticData.number)  to \(statisticData.category)")
        let id = projectId
        projectId = id
        let key = categoryKey
        categoryKey = key
    }

    @objc func handleAnimate(){
        guard let minHeight = minHeightAnchor else {return}
        if minHeight.isActive == true{
            minHeightAnchor?.isActive = false
            maxHeightAnchor?.isActive = true
        }else{
            maxHeightAnchor?.isActive = false
            minHeightAnchor?.isActive = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.minusImageView.transform = self.minusImageView.transform.rotated(by: CGFloat(Double.pi/2))
            self.layoutIfNeeded()
        }, completion: nil)
    }

    func defineStatisticDataTemplate() -> StatisticData{
        let statisticData = StatisticData()
        statisticData.positiveNegative = plusMinusSegmentedControl.selectedSegmentIndex
        if let number = selectedValue{
            statisticData.number = number
        }
        if let text = commentTextField.text{
            statisticData.comment = text
        }
        statisticData.category = categoryKey
        return statisticData
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return valuePickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        for view in pickerView.subviews{
            var frame = view.frame
            frame.size.height = 2
            view.frame = frame
            view.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        }
        let row = String(valuePickerDataSource[row])
        return NSAttributedString(string: row, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let val1 = valuePickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let val2 = valuePickerDataSource[pickerView.selectedRow(inComponent: 1)]
        let val3 = valuePickerDataSource[pickerView.selectedRow(inComponent: 2)]
        selectedValue = val1*100 + val2*10 + val3
        updateSaveButtonState()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? PanelTableViewCell else {
            fatalError( "The dequeued cell is not an instance of EventTableViewCell." )
        }
        cell.data = tableViewDataSource[indexPath.row]
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    private func updateSaveButtonState(){
        let text = commentTextField.text ?? ""
        let value = selectedValue ?? 0
        saveButton.isEnabled = !text.isEmpty && value > 0
    }
    
    func setupConstraints(){
        [selectedStatisticsLabel, panelTableView, commentTextField, valuePicker, saveButton, totalValueLabel, statisticImage, containerView,valuePickerTitle, lineUIView].forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
       
        statisticImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        statisticImage.topAnchor.constraint(equalTo: selectedStatisticsLabel.topAnchor, constant: 0).isActive = true
        statisticImage.widthAnchor.constraint(equalToConstant: 69).isActive = true
        statisticImage.heightAnchor.constraint(equalToConstant: 73).isActive = true
        
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        containerView.topAnchor.constraint(equalTo: statisticImage.bottomAnchor, constant: 0).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        //height constraints animation
        minHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: 2)
        maxHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: 310)
        minHeightAnchor?.isActive = true
        
        openViewButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
        openViewButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -18).isActive = true
        openViewButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        openViewButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        minusImageView.centerXAnchor.constraint(equalTo: openViewButton.centerXAnchor, constant: 0).isActive = true
        minusImageView.centerYAnchor.constraint(equalTo: openViewButton.centerYAnchor, constant: 0).isActive = true
        minusImageView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        minusImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        valuePickerTitle.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
        valuePickerTitle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30).isActive = true
        valuePickerTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        valuePickerTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        plusMinusSegmentedControl.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        plusMinusSegmentedControl.topAnchor.constraint(equalTo: valuePickerTitle.topAnchor, constant: 0).isActive = true
        plusMinusSegmentedControl.widthAnchor.constraint(equalToConstant: 110).isActive = true
        plusMinusSegmentedControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        valuePicker.topAnchor.constraint(equalTo: valuePickerTitle.bottomAnchor, constant: 19).isActive = true
        valuePicker.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        valuePicker.widthAnchor.constraint(equalTo: commentTextField.widthAnchor, multiplier: 1).isActive = true
        valuePicker.heightAnchor.constraint(equalToConstant: 80).isActive = true

        commentTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        commentTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:  15).isActive = true
        commentTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        commentTextField.topAnchor.constraint(equalTo: valuePicker.bottomAnchor, constant: 17).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 7).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:  24).isActive = true
        saveButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -24).isActive = true
        saveButton.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 35).isActive = true
        
        selectedStatisticsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18).isActive = true
        selectedStatisticsLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        selectedStatisticsLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        selectedStatisticsLabel.leftAnchor.constraint(equalTo: statisticImage.rightAnchor, constant: 15).isActive = true
        
        totalValueLabel.topAnchor.constraint(equalTo: selectedStatisticsLabel.bottomAnchor, constant: 0).isActive = true
        totalValueLabel.leftAnchor.constraint(equalTo: statisticImage.rightAnchor, constant: 15).isActive = true
        totalValueLabel.heightAnchor.constraint(equalToConstant: 31).isActive = true
        totalValueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        
        panelTableView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant:  21).isActive = true
        panelTableView.leftAnchor.constraint(equalTo: leftAnchor, constant:  24).isActive = true
        panelTableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        panelTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        panelTableView.separatorStyle = .none
    }
}
