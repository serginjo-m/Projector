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
    var canvasObject = CanvasNote()
    
    var removedCanvasLines = List<SingleLineObject>()
    
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
       
        if canvasObject.canvasLines.count > 0 {
        
            guard let element = canvasObject.canvasLines.last else {return}
            
            canvasObject.canvasLines.removeLast()
            
            removedCanvasLines.append(element)
            
            setNeedsDisplay()
        }
    }
    
    func redo(){
        guard let element = removedCanvasLines.last else {return}
        
        removedCanvasLines.removeLast()
        
        canvasObject.canvasLines.append(element)
        
        setNeedsDisplay()
    }
    
    func clear() {
        canvasObject.canvasLines.removeAll()
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
                
                let point = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))

                if i == 0{
                    context.move(to: point)
                }else{
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
            ctx.cgContext.setFillColor(UIColor.init(white: 239/255, alpha: 1).cgColor)
            ctx.cgContext.fill(self.bounds)
            
            canvasObject.canvasLines.forEach { (line) in
                for (i, p) in line.singleLine.enumerated(){
                    let color = IntToStrokeColor(num: line.color)
                    
                    ctx.cgContext.setStrokeColor(color.cgColor)
                    ctx.cgContext.setLineWidth(CGFloat(line.strokeWidth))
                    ctx.cgContext.setLineCap(.round)
                    
                    let point = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))

                    if i == 0{
                        ctx.cgContext.move(to: point)
                    }else{
                        ctx.cgContext.addLine(to: point)
                    }
                }

                ctx.cgContext.strokePath()
            }
            
        }
        
        return image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removedCanvasLines.removeAll()
        canvasObject.canvasLines.append(SingleLineObject())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: nil) else {return}

        let linePoint = LineCGPoint()
        linePoint.x = Float(point.x)
        linePoint.y = Float(point.y)

        if Int(point.y) > canvasObject.canvasMaxHeight {
            canvasObject.canvasMaxHeight = Int(point.y)
        }

        guard let lastLine = canvasObject.canvasLines.last else {return}
        canvasObject.canvasLines.removeLast()

        lastLine.singleLine.append(linePoint)
        lastLine.color = strokeColorToInt(color: strokeColor)
        lastLine.strokeWidth = strokeWidth

        canvasObject.canvasLines.append(lastLine)

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
