//
//  Canvas View.swift
//  Projector
//
//  Created by Serginjo Melnik on 13.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class DrawCanvasView: UIView {
   
    var canvasObject = CanvasNote()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("context is not defined")
            return
        }
        
        canvasObject.canvasLines.forEach { (line) in
            for (i, p) in line.singleLine.enumerated(){
                let color = IntToStrokeColor(color: line.color)
                
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(CGFloat(line.strokeWidth))
                context.setLineCap(.round)
   
                let point = CGPoint(x: CGFloat(p.x / 2.2), y: CGFloat(p.y / 2.2))
                
                if i == 0{
                
                    context.move(to: point)
                    
                }else{
                    
                    context.addLine(to: point)
                }
            }
            
            context.strokePath()
        }
    }
    
    private func IntToStrokeColor(color: Int) -> UIColor {
        switch color {
        case 0:
            return UIColor.yellow
        case 1:
            return UIColor.red
        case 2:
            return UIColor.blue
        case 3:
            return UIColor.black
        default:
            return UIColor.black
        }
    }
}
