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
    let store = CFStore.sharedInstance

    let borderWidth:       CGFloat = 30
    
    var accountTrackWidth: CGFloat = 0
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        accountTrackWidth = dirtyRect.width / CGFloat(store.accountNames.count + 1) - 30.0
        drawRectAt(CGPoint(x: 0, y: 0), Height: self.frame.height, Width: accountTrackWidth/2.0, withString: "In")
        drawRectAt(CGPoint(x: dirtyRect.width - (accountTrackWidth/2.0), y: 0), Height: self.frame.height, Width: accountTrackWidth/2.0, withString: "Out")
        
        let accountNames = store.accountNames
        
        for (index, anAccount) in enumerate(accountNames) {
            let name = anAccount as NSString
            let origin = CGPoint(x:accountTrackWidth/2.0 + (borderWidth*CGFloat(index+1)) + CGFloat(index)*accountTrackWidth, y: 0)
            drawRectAt(origin, Height: self.frame.height, Width: accountTrackWidth, withString: name)
        }


        
    }
    
    func drawRectAt(Point: CGPoint, Height: CGFloat, Width: CGFloat, withString: String) {
        let containingRect = CGRectMake(Point.x, Point.y, Width, Height)
        let drawnString: NSString = withString
        
        NSColor.redColor().setFill()
        NSRectFill(containingRect)

        var attributeArray: [String: NSObject] = [:]
        attributeArray[NSForegroundColorAttributeName] = NSColor.blackColor()
        
        let nameFont = NSFont.systemFontOfSize(17)
        var nameParagraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        nameParagraphStyle.alignment = NSTextAlignment.CenterTextAlignment

        var  attributeDictionary: [String: NSObject] =
            [NSFontAttributeName:           nameFont,
                NSParagraphStyleAttributeName: nameParagraphStyle]
        
        drawnString.drawInRect(containingRect, withAttributes: attributeDictionary)
        

    }
}