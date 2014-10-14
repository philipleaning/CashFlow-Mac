//
//  CashFlowBottomView.swift
//  CashFlow
//
//  Created by Philip Leaning on 10/10/2014.
//  Copyright (c) 2014 bluetatami. All rights reserved.
//

import Foundation
import Cocoa

class CFBottomView: NSView {
    let store = CFStore.sharedInstance
    
    let borderWidth:       CGFloat = 30
    
    var accountTrackWidth: CGFloat = 0
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        NSColor(calibratedWhite: 0.29, alpha: 1.0).setFill()
        NSRectFill(dirtyRect)
        
        drawDividingLineAtTop()

        accountTrackWidth = dirtyRect.width / CGFloat(store.accountNames.count + 1) - 30.0
        let accountNames = store.accountNames
        
        for (index, anAccount) in enumerate(accountNames) {
            let balance: Int = store.events.last!.resultState[anAccount]!
            let origin = CGPoint(x:accountTrackWidth/2.0 + (borderWidth*CGFloat(index+1)) + CGFloat(index)*accountTrackWidth, y: 0)
            drawRectAt(origin, Height: self.frame.height, Width: accountTrackWidth, withString: "\(balance)")
        }
        
    }
    
    func drawRectAt(Point: CGPoint, Height: CGFloat, Width: CGFloat, withString: String) {
        let containingRect = CGRectMake(Point.x, Point.y, Width, Height)
        let drawnString: NSString = withString
        //Font properties for "attribute string"
        let nameFont = NSFont.systemFontOfSize(17)
        var nameParagraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        nameParagraphStyle.alignment = NSTextAlignment.CenterTextAlignment
        let fontColor = NSColor(calibratedWhite: 0.9, alpha: 1.0)
        //Dictionary of font properties
        var  attributeDictionary: [String: NSObject] =
        [NSFontAttributeName:           nameFont,
            NSParagraphStyleAttributeName: nameParagraphStyle,
            NSForegroundColorAttributeName: fontColor]
        
        drawnString.drawInRect(containingRect, withAttributes: attributeDictionary)
    }
    
    func drawDividingLineAtTop() {
        var linePath = NSBezierPath()
        let height = self.frame.height
        linePath.moveToPoint(CGPoint(x: 0, y: height))
        linePath.lineToPoint(CGPoint(x: self.frame.width, y: height))
        NSColor(calibratedWhite: 0.9, alpha: 1.0).setStroke()
        linePath.stroke()
    }
}