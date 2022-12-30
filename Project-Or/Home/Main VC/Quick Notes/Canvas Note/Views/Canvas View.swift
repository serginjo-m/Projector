//
//  Canvas View.swift
//  Projector
//
//  Created by Serginjo Melnik on 13.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CanvasView: UIView {
    //MARK: Properties
    //object that fits to realm
    var canvasObject = CanvasNote()
    //redo func
    var removedCanvasLines = List<SingleLineObject>()
    
    //public function
    let colorPalette = ColorPalette()
    
    fileprivate var strokeColor = UIColor.red
    
    fileprivate var strokeWidth: Float = 15
    
    //MARK: Methods
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
            guard let element = canvasObject.canvasLines.last else {return}
            
            canvasObject.canvasLines.removeLast()
            
            removedCanvasLines.append(element)
            //going to execute draw func again
            setNeedsDisplay()
        }
    }
    
    func redo(){
        //remove last line
        guard let element = removedCanvasLines.last else {return}
        
        removedCanvasLines.removeLast()
        
        canvasObject.canvasLines.append(element)
        //going to execute draw func again
        setNeedsDisplay()
    }
    
    func clear() {
        //remove all elements
        canvasObject.canvasLines.removeAll()
        //going to execute draw func again
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("context is not defined")
            return
        }
    
        canvasObject.canvasLines.forEach { (line) in
            for (i, p) in line.singleLine.enumerated(){
                let color = IntToStrokeColor(num: line.color)

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
    
    
    func renderImageFromCanvas() -> UIImage{
        
        let fmt = UIGraphicsImageRendererFormat()
        
        fmt.scale = 1
        
        fmt.opaque = true
        
        let rndr = UIGraphicsImageRenderer(size: CGSize(width: self.frame.width, height: self.frame.height), format: fmt)
        
        let image = rndr.image { ctx in
            //a bit gray background
            ctx.cgContext.setFillColor(UIColor.init(white: 239/255, alpha: 1).cgColor)
            ctx.cgContext.fill(self.bounds)
            
            canvasObject.canvasLines.forEach { (line) in
                for (i, p) in line.singleLine.enumerated(){
                    let color = IntToStrokeColor(num: line.color)
                    
                    ctx.cgContext.setStrokeColor(color.cgColor)
                    ctx.cgContext.setLineWidth(CGFloat(line.strokeWidth))
                    ctx.cgContext.setLineCap(.round)
                    
                    //convert object to CGPoint
                    let point = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))

                    //line first point
                    if i == 0{
                        //starts
                        ctx.cgContext.move(to: point)
                        
                    }else{
                        //ends
                        ctx.cgContext.addLine(to: point)
                        
                    }
                }

                ctx.cgContext.strokePath()
            }
            
        }
        
        return image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //clear removed lines cache, as user starts drawing
        removedCanvasLines.removeAll()
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
        guard let number = colorPalette.colorToInt[color] else {return 0}
        return number
    }
    
    private func IntToStrokeColor(num: Int) -> UIColor {
        guard let color = colorPalette.intToColor[num] else {return UIColor.green}
        return color
    }
}
