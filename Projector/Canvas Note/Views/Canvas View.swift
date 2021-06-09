//
//  Canvas View.swift
//  Projector
//
//  Created by Serginjo Melnik on 13.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    //public function
    fileprivate var strokeColor = UIColor.red
    fileprivate var strokeWidth: Float = 7
    
    func setStrokeColor(color: UIColor){
        self.strokeColor = color 
    }
    
    func setStrokeWidth(width: Float){
        self.strokeWidth = width
    }
    
    func undo(){
        //prevent from crash if there is no lines in array
        if canvasObject.canvasLines.count > 0 {
            
            //remove last line
            canvasObject.canvasLines.removeLast()
            //going to execute draw func again
            setNeedsDisplay()
        }
    }
    
    func clear() {
        //remove all elements
        canvasObject.canvasLines.removeAll()
        //going to execute draw func again
        setNeedsDisplay()
    }
    
    //object that fits to realm
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
                
                //convert object to CGPoint
                let point = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))

                //line first point
                if i == 0{
                    //starts
                    context.move(to: point)
                    
                }else{
                    //ends
                    context.addLine(to: point)
                    
                }
            }

            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        canvasObject.canvasLines.append(SingleLineObject())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: nil) else {return}
        
        //write CGPoint to custom object
        let linePoint = LineCGPoint()
        linePoint.x = Float(point.x)
        linePoint.y = Float(point.y)
        
        //calculating max height of canvas
        if Int(point.y) > canvasObject.canvasMaxHeight {
            canvasObject.canvasMaxHeight = Int(point.y)
        }
        
        //capture line from array
        //instead of getting copy of line
        guard let lastLine = canvasObject.canvasLines.last else {return}
        canvasObject.canvasLines.removeLast()
        //add new point to line
        lastLine.singleLine.append(linePoint)
        lastLine.color = strokeColorToInt(color: strokeColor)
        lastLine.strokeWidth = strokeWidth
        //add it back into the lines array
        canvasObject.canvasLines.append(lastLine)
        //redraw canvas
        setNeedsDisplay()
    }
    
    private func strokeColorToInt(color: UIColor) -> Int {
        switch color {
        case UIColor.yellow:
            return 0
        case UIColor.red:
            return 1
        case UIColor.blue:
            return 2
        case UIColor.black:
            return 3
        default:
            return 0
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
