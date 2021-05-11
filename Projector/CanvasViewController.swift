//
//  CanvasNote.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Canvas: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.setStrokeColor(UIColor.brown.cgColor)
        context.setLineWidth(10)
        context.setLineCap(.butt)
        
        lines.forEach { (line) in
            
            for (i, p) in line.enumerated(){
                
                //line first point
                if i == 0{
                    //starts
                    context.move(to: p)
                }else{
                    //ends
                    context.addLine(to: p)
                }
            }
             
        }
        
        
        
        context.strokePath()
    }
    
//    var line = [CGPoint]()
    
    var lines = [[CGPoint]]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: nil) else {return}
        
        //capture line from array
        //instead of getting copy of line
        guard var lastLine = lines.popLast() else {return}
        lastLine.append(point)
        
        //add it back into the lines array
        lines.append(lastLine)
        
//        var lastLine = lines.last
//        lastLine?.append(point)

        
        //redraw canvas
        setNeedsDisplay()
    }
}

class CanvasViewController: UIViewController {
    
    let canvas = Canvas()
    
    override func viewDidLoad() {
        
        
        view.addSubview(canvas)
        canvas.backgroundColor = .white
        canvas.frame = view.frame
    }
}
