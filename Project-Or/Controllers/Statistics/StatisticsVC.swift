//
//  StatisticsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    var cellIdentifier = "cellId"
    
    //table view
    lazy var statisticTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(StatisticCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        return tableView
    }()
    
    var projects: Results<ProjectList>{
        get{
            return ProjectListRepository.instance.getProjectLists()
        }
        set{
            //update...
        }
    }
    
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    var contentUIView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let pageTitle: UILabel = {
        let label = UILabel()
        label.text = "Statistics"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let categoriesTitle: UILabel = {
        let label = UILabel()
        label.text = "Total Projects Expenses"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()

    let categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let chartTitle: UILabel = {
        let label = UILabel()
        label.text = "Current Month Expenses"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let barChartView = BarChartView()
    
    let projectsTVTitle: UILabel = {
        let label = UILabel()
        label.text = "Expenses by Projects"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    
    //configure categories numbers
    fileprivate func setupCategories() {
        
        categoriesStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        var totalMoney = 0
        var totalTime = 0
        var totalFuel = 0
        
        if projects.count > 0{
            for project in projects {
                if let money = project.money{
                    totalMoney += money
                }
                if let time = project.time{
                    totalTime += time
                }
                if let fuel = project.fuel{
                    totalFuel += fuel
                }
            }
        }
        
        let moneyNumberStackView = StatisticContainer(
            image: "money-1",
            categoryText: "Money Spent",
            number: String(totalMoney),
            units: "$")
        let timeNumberStackView = StatisticContainer(
            image: "time",
            categoryText: "Time Spent",
            number: String(totalTime),
            units: "H")
        let fuelNumberStackView = StatisticContainer(
            image: "fuel",
            categoryText: "Fuel Spent",
            number: String(totalFuel),
            units: "L")
        
        
        //add to stack view
        [moneyNumberStackView, timeNumberStackView, fuelNumberStackView].forEach {
            categoriesStackView.addArrangedSubview($0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        view.backgroundColor = .white
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        [pageTitle, categoriesTitle, categoriesStackView, chartTitle, barChartView, projectsTVTitle, statisticTableView].forEach {
            contentUIView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //update project database
        projects = ProjectListRepository.instance.getProjectLists()
        //configure categories numbers
        setupCategories()
        
        barChartView.barChartController.setStatisticsDictionary()
        barChartView.barChartController.setCategoriesMaximumValue()
        barChartView.barChartController.defineItemsArray()
        barChartView.barChartController.collectionView.reloadData()
        
        statisticTableView.reloadData()
    }
    

    //MARK: Table View Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? StatisticCell else {fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )}
        cell.template = projects[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    private func setupConstraints(){
        
        statisticTableView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        pageTitle.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 25).isActive = true
        pageTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        pageTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        pageTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        categoriesTitle.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 37).isActive = true
        categoriesTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        categoriesTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        categoriesTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.topAnchor.constraint(equalTo: categoriesTitle.bottomAnchor, constant: 29).isActive = true
        categoriesStackView.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 15).isActive = true
        categoriesStackView.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -15).isActive = true
        categoriesStackView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        chartTitle.topAnchor.constraint(equalTo: categoriesStackView.bottomAnchor, constant: 25).isActive = true
        chartTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        chartTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        chartTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        barChartView.topAnchor.constraint(equalTo: chartTitle.bottomAnchor, constant: 20).isActive = true
        barChartView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        barChartView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        barChartView.heightAnchor.constraint(equalToConstant: 182).isActive = true
        
        projectsTVTitle.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 25).isActive = true
        projectsTVTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectsTVTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        projectsTVTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        statisticTableView.topAnchor.constraint(equalTo: projectsTVTitle.bottomAnchor, constant: 20).isActive = true
        statisticTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        statisticTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        statisticTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
    }
}
