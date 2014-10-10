//
//  CashFlowTopView.swift
//  CashFlow
//
//  Created by Philip Leaning on 10/10/2014.
//  Copyright (c) 2014 bluetatami. All rights reserved.
//

import Foundation
import Cocoa

class CFTopView: NSView {
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        drawRectAt(CGPoint(x: 10, y: -30), Height: 40, Width: 40, withString: "Hi")
        
    }
    
    func drawRectAt(Point: CGPoint, Height: CGFloat, Width: CGFloat, withString: String) {
        let containingRect = CGRectMake(Point.x, Point.y, Width, Height)
        let drawnString: NSString = withString
        
        
        var attributeArray: [String: NSObject] = [:]
        attributeArray[NSForegroundColorAttributeName] = NSColor.redColor()
        
        drawnString.drawInRect(containingRect, withAttributes: attributeArray)

    }
}