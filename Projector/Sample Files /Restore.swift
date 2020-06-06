/*

import UIKit
import RealmSwift
import Foundation

class ProgresControl: UIStackView {
    
    //MARK: Properties
    var progressBox = [UIStackView]()
    var progressChar = [UIProgressView]()
    var txtLabels = [UILabel]()
    
    var list: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressBar()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.axis = NSLayoutConstraint.Axis.horizontal
        self.distribution = UIStackView.Distribution.equalSpacing
        self.alignment = UIStackView.Alignment.center
        self.spacing = 1
        setupProgressBar()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: Methods
    func setupProgressBar(){ //let progressBar: UIProgressView - expect an issue here?
        
        //clear any existing stackViews
        for stackView in progressBox {
            removeArrangedSubview(stackView)
            stackView.removeFromSuperview()
        }
        progressBox.removeAll()
        
        //there was "number" before
        for _ in 0..<6 {
            
            //Progress Bar
            let progressView = UIProgressView()
            progressView.progressTintColor = UIColor(red: 1, green: 0.7, blue: 0.0, alpha: 1)
            progressView.trackTintColor = UIColor(red: 0.2 , green: 0.2, blue: 0.2 , alpha: 1)
            
            progressView.clipsToBounds = true
            progressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
            progressView.layer.cornerRadius = 5
            progressView.transform = progressView.transform.scaledBy(x: 2, y: 0.5)
            
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            progressView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            progressView.progress = 0.0
            
            //Text Label
            let textLabel = UILabel()
            textLabel.font = UIFont.systemFont(ofSize: 16.0)
            textLabel.textColor = UIColor.white
            //textLabel.backgroundColor = UIColor.yellow
            textLabel.widthAnchor.constraint(equalToConstant: self.frame.width / 6).isActive = true
            textLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true//?
            textLabel.textAlignment = .center
            
            //Stack View
            let stackViewBox = UIStackView()//container for prog.bar
            stackViewBox.axis = NSLayoutConstraint.Axis.vertical
            stackViewBox.distribution = UIStackView.Distribution.equalSpacing
            stackViewBox.alignment = UIStackView.Alignment.center
            stackViewBox.spacing = 40.0
            
            stackViewBox.addArrangedSubview(progressView)
            stackViewBox.addArrangedSubview(textLabel)
            stackViewBox.translatesAutoresizingMaskIntoConstraints = false
            
            // Add an item to the stackView
            //addArrangedSubview(stackViewBox)
            
            //Add an item to the array
            progressBox.append(stackViewBox)
            progressChar.append(progressView)
            txtLabels.append(textLabel)
        }
        updateMyProjectsProgress()
    }
    
    func updateMyProjectsProgress(){
        //Here I can iterate through my array and retreave an index of item
        for (index, project) in progressChar.enumerated() {
            
            var myProjectProgress: Float{
                get{
                    //full progress of progressView
                    let achievedProject: Float = 1.0
                    //perform calculations only if project exist in array
                    if index <= list.count - 1{
                        //find how many parts to achieve in project
                        let numberOfStepsInProject = Float(list[index].projectStep.count)
                        // counter for completed steps
                        var completedStepsInProject: Float = 0.0
                        //calculating number of completed steps in project
                        for item in list[index].projectStep {
                            if item.complete == true{
                                completedStepsInProject += 1.0
                            }
                        }
                        //calculate completed percentage
                        let completedPercentage = (achievedProject / numberOfStepsInProject) * completedStepsInProject
                        return completedPercentage
                    }
                    return 0.0
                }
            }
            project.progress = myProjectProgress
            txtLabels[index].text = "\(Int(round(100 * project.progress)))%"
        }
        
    }
}
*/
