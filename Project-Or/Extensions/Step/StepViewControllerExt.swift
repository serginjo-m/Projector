//
//  StepViewControllerExt.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

extension StepViewController {
    
    func performZoomForCollectionImageView(startingImageView: UIView){
        hideReminderView()
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingImageFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        let zoomingImageView = UIImageView(frame: startingImageFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomOut)))
        zoomingImageView.backgroundColor = .red
        if let cellImageView = startingImageView as? StepImageCell, let url = cellImageView.template {
            zoomingImageView.retreaveImageUsingURLString(myUrl: url)
        }

        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black

            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            let height = self.startingImageFrame!.height / self.startingImageFrame!.width * keyWindow.frame.width
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {

                self.blackBackgroundView?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center

            }, completion: nil)

        }

    }
    
    @objc func handleImageZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 5
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingImageFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                
                //remove it completely
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    func performZoomForStartingEventView(stepItem: StepItem, startingView: UIView){
        hideReminderView()
        
        guard let stepTableViewCell = startingView as? StepTableViewCell else {return}
        self.startingView = stepTableViewCell
        self.startingView?.isHidden = true

        guard let itemTemplate = stepTableViewCell.template,
              let unwStartingFrame = startingView.superview?.convert(startingView.frame, to: nil) else {return}

        let zoomFrame = CGRect(x: unwStartingFrame.origin.x, y: unwStartingFrame.origin.y, width: unwStartingFrame.width, height: unwStartingFrame.height)

        startingFrame = zoomFrame

        let zoomingView = StepItemZoomingView(stepItem: itemTemplate, frame: zoomFrame)
        zoomingView.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOutItem)))
        
        zoomingView.title.text = stepTableViewCell.itemTitle.text
        zoomingView.descriptionLabel.text = stepTableViewCell.descriptionLabel.text
        zoomingView.descriptionTextView.text = zoomingView.descriptionLabel.text
        zoomingView.removeButton.addTarget(self, action: #selector(removeStepItem(_:)), for: .touchUpInside)
        zoomingView.editButton.addTarget( self, action: #selector(editStepItem(_:)), for: .touchUpInside)
        
        if let keyWindow = UIApplication.shared.keyWindow {

            self.zoomBackgroundView = UIView(frame: keyWindow.frame)

            zoomBackgroundView?.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
            zoomBackgroundView?.alpha = 0
            keyWindow.addSubview(zoomBackgroundView!)
            
            keyWindow.addSubview(zoomingView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width * 0.9, height: keyWindow.frame.height * 0.9)
                
                self.zoomBackgroundView?.alpha = 1
                zoomingView.dismissView.alpha = 1
                zoomingView.removeButton.alpha = 1
                zoomingView.editButton.alpha = 1
                
                zoomingView.layoutIfNeeded()
                zoomingView.center = keyWindow.center
                
            } completion: { (completed: Bool) in
                //
            }
        }
    }
    
    @objc func zoomOutItem(tapGesture: UITapGestureRecognizer){
        
        if let zoomOutView = tapGesture.view?.superview{
            zoomOutView.layer.cornerRadius = 11
            zoomOutView.clipsToBounds = true
            
            guard  let zoom = zoomOutView as? StepItemZoomingView else {return}
            
            zoom.dismissView.alpha = 0
            zoom.removeButton.alpha = 0
            zoom.editButton.alpha = 0
            zoom.thinUnderline.alpha = 0
            zoom.descriptionTextView.alpha = 0
            zoom.descriptionLabel.alpha = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {

                zoomOutView.frame = self.startingFrame!

                self.zoomBackgroundView?.alpha = 0
                
                    if let startingView = self.startingView as? StepTableViewCell {
                        
                        zoom.bubbleBottomAnchor.isActive = false
                        zoom.bubbleBottomLabelAnchor.isActive = true
                        
                        zoom.bubbleTopAnchor.isActive = false
                        zoom.bubbleTopLabelAnchor.isActive = true
                        
                        zoom.iconLeftAnchor.isActive = false
                        zoom.iconLeftCompactAnchor.isActive = true
                        
                        zoom.titleTopAnchor.constant = 0
                        zoom.descriptionTopAnchor.constant = 20
                        
                        zoom.descriptionHeightAnchor.isActive = false
                        zoom.descriptionBottomAnchor.isActive = true
                        
                        zoom.title.font = startingView.itemTitle.font
                        zoom.descriptionLabel.font = startingView.descriptionLabel.font
                        
                        if startingView.descriptionLabel.isHidden == true{
                            zoom.descriptionLabel.alpha = 0
                        }
                    }
                zoomOutView.layoutIfNeeded()
                
            } completion: { (completed: Bool) in
                zoomOutView.removeFromSuperview()
                self.startingView?.isHidden = false
            }
        }
    }
    
    @objc func removeStepItem(_ sender: UIButton){
        
        guard let cell = self.startingView as? StepTableViewCell,
              let stepItem = cell.template,
              let zoomingItemView = sender.superview as? StepItemZoomingView else {return}
        
        let alertVC = UIAlertController(title: "Delete Step Item?", message: "Are You sure You want to delete this Step Item?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            zoomingItemView.removeFromSuperview()
            self.zoomBackgroundView?.alpha = 0
            self.startingView?.isHidden = false
            ProjectListRepository.instance.deleteStepItem(stepItem: stepItem)
            self.stepTableView.reloadData()
        })
        
        alertVC.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func editStepItem(_ sender: UIButton){
        guard let cell = self.startingView as? StepTableViewCell,
              let stepItem = cell.template,
              let zoomingItemView = sender.superview as? StepItemZoomingView else {return}
        let newStepItemVC = StepItemViewController()
        newStepItemVC.stepItem = stepItem
        newStepItemVC.itemTitleTextField.text = stepItem.title
        newStepItemVC.noteTextView.text = stepItem.text
        newStepItemVC.stepID = self.stepID
        newStepItemVC.modalPresentationStyle = .fullScreen
        zoomingItemView.removeFromSuperview()
        self.zoomBackgroundView?.alpha = 0
        self.startingView?.isHidden = false
        present(newStepItemVC, animated: true)
    }
}
