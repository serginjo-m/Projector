//
//  SidePanelView.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

// this extension hide keyboard when user
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class SidePanelView: ElementsViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    var realm: Realm!//create a var
    // as project id is defined, creates existing categories array
    
    //Fetch Selected Project for Step CV modifications
    var project: ProjectList?
    
    var projectId = String() {
        didSet{
            //as ID defined, retreave project from DB
            project = ProjectListRepository.instance.getProjectList(id: projectId)
            //creates grouped data source for table view
            assembleGroupedData()
        }
    }
    
    let valuePickerDataSource = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "eventsTableViewCell"
    
    //use for create new instance of StatisticData
    
    var selectedValue: Int?
    
    //grouped statistic data by category
    var groupedDataDictionary = [ String : [StatisticData]]()
    var tableViewDataSource = [StatisticData]()
    var categoryKey = ""{
        didSet{
            createTableViewDataSource(key: categoryKey)
            //reset all picker components
            valuePicker.selectRow(0, inComponent: 0, animated: false)
            valuePicker.selectRow(0, inComponent: 1, animated: false)
            valuePicker.selectRow(0, inComponent: 2, animated: false)
            commentTextField.text = ""
        }
    }
    
    
    
    let selectedStatisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "This is Date"
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    //TABLE VIEW
    let panelTableView = UITableView()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        textField.placeholder = "Insert New Item"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        return textField
    }()
    
    let valuePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .clear
        picker.selectedRow(inComponent: 5)
        picker.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        picker.layer.borderWidth = 1
        return picker
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Value", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.titleLabel?.textColor = .black
        button.isEnabled = false
        return button
    }()
    
    override func setupTableView() {
        realm = try! Realm()//create an instance of object
        
        backgroundColor = .white
        addSubview(selectedStatisticsLabel)
        addSubview(panelTableView)
        addSubview(commentTextField)
        addSubview(valuePicker)
        addSubview(saveButton)
        
        panelTableView.delegate = self
        panelTableView.dataSource = self
        
        valuePicker.delegate = self
        valuePicker.dataSource = self
        
        commentTextField.delegate = self
        
        panelTableView.register(PanelTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setupConstraints()
    }
    
    //creates grouped dictionary by categories
    func assembleGroupedData(){
        guard let statistics = project?.projectStatistics else {return}
        //[ Date : [Event]]
        groupedDataDictionary = Dictionary(grouping: statistics) { (statistic) -> String in
            return statistic.category
        }
    }
    //this func creates datasource for my table view from groupedDataDictionary or clear data and then reaload
    func createTableViewDataSource(key: String){
        //clear
        tableViewDataSource.removeAll()
        //check if data exist (also avouid optionals)
        guard let array = groupedDataDictionary[key] else {
            panelTableView.reloadData()
            return
        }
        //assign data to array
        tableViewDataSource = array
        //reload
        panelTableView.reloadData()
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        //template
        let statisticData: StatisticData = self.defineStatisticDataTemplate()
        //save to database
        try! self.realm!.write ({
            guard let proj = project else {return}
            proj.projectStatistics.append(statisticData)
        })
        
        //---------------------- It definitely need some improvement -------------------------------------------
        //assign the same values lead to reload of data and view
        let id = projectId
        projectId = id
        let key = categoryKey
        categoryKey = key
        
    }
    //creates event instance
    func defineStatisticDataTemplate() -> StatisticData{
        let statisticData = StatisticData()
        
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = String(valuePickerDataSource[row])
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let val1 = valuePickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let val2 = valuePickerDataSource[pickerView.selectedRow(inComponent: 1)]
        let val3 = valuePickerDataSource[pickerView.selectedRow(inComponent: 2)]
        
        selectedValue = val1*100 + val2*10 + val3
        updateSaveButtonState()
    }
    
    
    
    //table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewDataSource.count
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? PanelTableViewCell else {
            fatalError( "The dequeued cell is not an instance of EventTableViewCell." )
        }
        
        cell.data = tableViewDataSource[indexPath.row]
        return cell
    }
    
    
    //text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = commentTextField.text ?? ""
        let value = selectedValue ?? 0
        saveButton.isEnabled = !text.isEmpty && value > 0
    }
    
    func setupConstraints(){
    
        selectedStatisticsLabel.translatesAutoresizingMaskIntoConstraints = false
        panelTableView.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.translatesAutoresizingMaskIntoConstraints  = false
        valuePicker.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        selectedStatisticsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        selectedStatisticsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        selectedStatisticsLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        selectedStatisticsLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        commentTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        commentTextField.leftAnchor.constraint(equalTo: leftAnchor, constant:  24).isActive = true
        commentTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        commentTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -150).isActive = true
        
        valuePicker.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -20).isActive = true
        valuePicker.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        valuePicker.widthAnchor.constraint(equalTo: commentTextField.widthAnchor, multiplier: 1).isActive = true
        valuePicker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.leftAnchor.constraint(equalTo: leftAnchor, constant:  24).isActive = true
        saveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        saveButton.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 20).isActive = true
        
        panelTableView.topAnchor.constraint(equalTo: selectedStatisticsLabel.bottomAnchor, constant:  21).isActive = true
        panelTableView.leftAnchor.constraint(equalTo: leftAnchor, constant:  24).isActive = true
        panelTableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        panelTableView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: 0).isActive = true
        panelTableView.separatorStyle = .none
        
        
    }
}

class PanelTableViewCell: UITableViewCell {
    
    //template
    var data: StatisticData? {
        didSet {
            //check if ...
            guard let data = data else { return }
            taskLabel.text = "\(data.number) - \(data.comment)"
        }
    }
  
    let titleIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        return image
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.text = "-100$ Surface Cleaner"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(taskLabel)
        addSubview(titleIcon)
        
        titleIcon.frame = CGRect(x: 0, y: 8, width: 16, height: 14)
        taskLabel.frame = CGRect(x: 23, y: 0, width: 250, height: 30)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
