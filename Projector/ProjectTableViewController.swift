//
//  ProjectTableViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 08.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    
    //MARK: Properties
    var projects = [ProjectList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //load the sample data
        loadProjects()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProjectTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? ProjectTableViewCell else {
            fatalError( "The dequeued cell is not an instance of MealTableViewCell." )
        }
        
        //Fetches the appropriate project for the data source layout.
        let project = projects[indexPath.row]
        
        cell.nameLabel.text = project.name
        cell.categoryLabel.text = project.category
        cell.dateLabel.text = project.date
        cell.stepLabel.text = project.description
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private Methods
    private func loadProjects() {
        
        let project1 = ProjectList()
        project1.name = "Happy New Year"
        project1.category = "Tourism"
        project1.date = "01/01/2020"
        project1.steps = 4
        
        let project2 = ProjectList()
        project2.name = "MarryCristmass"
        project1.category = "Tourism"
        project1.date = "01/01/2020"
        project1.steps = 5
        
        
        
        projects += [project1, project2]
        
        
    }

}
