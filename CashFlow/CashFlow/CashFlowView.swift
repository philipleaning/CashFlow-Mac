//
//  CashFlowView.swift
//  CashFlow
//
//  Created by Alexandre Lopoukhine on 05/10/2014.
//  Copyright (c) 2014 bluetatami. All rights reserved.
//

import Cocoa

class CashFlowView: NSView {
    let store: CFStore
    var isFlipped = true
    
    
    override func drawRect(dirtyRect: NSRect) {
        
        func flowPath(#fromPoint: NSPoint, #toPoint: NSPoint, #width: CGFloat) -> NSBezierPath {
            if width == 0 {return NSBezierPath()}
            let fromOffsetPoint = NSPoint(x: fromPoint.x + width, y: fromPoint.y)
            let toOffsetPoint   = NSPoint(x: toPoint.x   + width, y: toPoint.y  )
            
            let transferHeight:         CGFloat = toPoint.y - fromPoint.y
            let controlPointProportion: CGFloat = fromPoint.x < toPoint.x ? 0.7 : 0.3
            
            let controlpointheights: (a: CGFloat, b: CGFloat) = (transferHeight * controlPointProportion, transferHeight * (1-controlPointProportion))
            
            
            let fromControlPoint1 = NSPoint(x: fromPoint.x,
                y: fromPoint.y + controlpointheights.a)
            let fromControlPoint2 = NSPoint(x: fromPoint.x + width,
                y: fromPoint.y + controlpointheights.b)
            let toControlPoint1   = NSPoint(x: toPoint.x,
                y: toPoint.y - controlpointheights.b)
            let toControlPoint2   = NSPoint(x: toPoint.x + width,
                y: toPoint.y - controlpointheights.a)
            
            let transferPath = NSBezierPath()
            transferPath.moveToPoint(fromPoint)
            transferPath.curveToPoint(toPoint, controlPoint1: fromControlPoint1, controlPoint2: toControlPoint1)
            transferPath.lineToPoint(toOffsetPoint)
            transferPath.curveToPoint(fromOffsetPoint, controlPoint1: toControlPoint2, controlPoint2: fromControlPoint2)
            transferPath.closePath()
            
            return transferPath
        }
        
        func incomePath(#toPoint: NSPoint, #width: CGFloat) -> NSBezierPath {
            if width == 0 {return NSBezierPath()}
            
            // toPoint is the bottom right point on the curve
            let incomePath = NSBezierPath()
            incomePath.moveToPoint(toPoint)
            incomePath.appendBezierPathWithArcWithCenter(NSPoint(x: toPoint.x - 25, y: toPoint.y), radius: 25, startAngle: 0, endAngle: 270, clockwise: true)
            incomePath.lineToPoint(NSPoint(x: 0, y: toPoint.y - 25))
            incomePath.lineToPoint(NSPoint(x: 0, y: toPoint.y - 5 ))
            incomePath.appendBezierPathWithArcWithCenter(NSPoint(x: toPoint.x - width - 5, y: toPoint.y), radius: 5, startAngle: 270, endAngle: 0)
            incomePath.closePath()
            
            return incomePath
        }
        
        func spendPath(#fromPoint: NSPoint, #width: CGFloat) -> NSBezierPath {
            if width == 0 {return NSBezierPath()}
            
            let incomePath = NSBezierPath()
            incomePath.moveToPoint(fromPoint)
            incomePath.appendBezierPathWithArcWithCenter(NSPoint(x: fromPoint.x + 25, y: fromPoint.y), radius: 25, startAngle: 180, endAngle: 90, clockwise: true)
            incomePath.lineToPoint(NSPoint(x: dirtyRect.width, y: fromPoint.y + 25))
            incomePath.lineToPoint(NSPoint(x: dirtyRect.width, y: fromPoint.y + 5 ))
            incomePath.appendBezierPathWithArcWithCenter(NSPoint(x: fromPoint.x + width + 5, y: fromPoint.y), radius: 5, startAngle: 90, endAngle: 180, clockwise: false)
            incomePath.closePath()
            
            return incomePath
        }
        
        super.drawRect(dirtyRect)
        
        let borderWidth:       CGFloat = 30
        
        let accountTrackWidth: CGFloat = dirtyRect.width / CGFloat(store.accountNames.count + 1)
        
        let eventHeight: CGFloat = 100
        
        let visibleEvents = store.events[0..<min(9, store.events.count)]
        
        // Find what the largest number is and determine number of units per pixel
        var maximumBalance = 1
        for event in visibleEvents {
            for (_, balance) in event.resultState {
                if maximumBalance < balance {
                    maximumBalance = balance
                }
            }
        }
        let pixelsPerUnit: CGFloat = accountTrackWidth / CGFloat(maximumBalance)
        
        NSColor.grayColor().setStroke()
        
        for (eventIndex, event) in enumerate(visibleEvents) {
            NSColor.blueColor().setFill()
            
            let y = eventHeight * CGFloat(eventIndex)
            
            // Draw transitions between rectangles
            switch event.eventType {
            case let .OpenAccount(accountName: account, initialBalance: initialBalance):
                // Draw rectangles for resulting states
                for (accountName, amount) in event.resultState {
                    if (accountName != account) {
                        if let accountIndex = firstIndexOf(store.accountNames, accountName) {
                            let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex)*(borderWidth + accountTrackWidth)
                            let width:  CGFloat = CGFloat(amount) * pixelsPerUnit
                            let balanceRect = NSRect(x: x, y: y, width: width, height: eventHeight)
                            NSRectFill(balanceRect)
                        }
                    }
                }
                
            case let .Transfer(fromAccount: fromAccount, toAccount: toAccount, amount: amount):
                // Draw rectangles for resulting states
                for (accountName, amount) in event.resultState {
                    if (accountName != fromAccount && accountName != toAccount) {
                        if let accountIndex = firstIndexOf(store.accountNames, accountName) {
                            let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex)*(borderWidth + accountTrackWidth)
                            let width:  CGFloat = CGFloat(amount) * pixelsPerUnit
                            let balanceRect = NSRect(x: x, y: y, width: width, height: eventHeight)
                            NSRectFill(balanceRect)
                        }
                    }
                }
                
                if eventIndex > 0 {
                    if let fromAccountIndex = firstIndexOf(store.accountNames, fromAccount) {
                        if let toAccountIndex = firstIndexOf(store.accountNames, toAccount) {
                            let fromCarryOverWidth   = CGFloat(event.resultState[fromAccount]!) * pixelsPerUnit
                            let transferWidth: CGFloat = CGFloat(amount) * pixelsPerUnit
                            let toCarryOverWidth     = CGFloat(visibleEvents[eventIndex - 1].resultState[toAccount]!) * pixelsPerUnit
                            
                            
                            let fromX: CGFloat      = accountTrackWidth/2.0 + CGFloat(fromAccountIndex) * (borderWidth + accountTrackWidth)
                            let toX:   CGFloat      = accountTrackWidth/2.0 + CGFloat(toAccountIndex)   * (borderWidth + accountTrackWidth)
                            
                            let (fromCarryOverXTop, fromTransferX, toCarryOverXTop) = fromAccountIndex < toAccountIndex ?
                                (fromX, fromX + fromCarryOverWidth, toX) : (fromX + transferWidth, fromX, toX)
                            
                            let (fromCarryOverXBottom, toTransferX, toCarryOverXBottom) = fromAccountIndex < toAccountIndex ?
                                (fromX, toX, toX + transferWidth) : (fromX, toX + toCarryOverWidth, toX)
                            
                            let fromCarryOverPath = flowPath(fromPoint: NSPoint(x: fromCarryOverXTop, y: y),
                                toPoint: NSPoint(x: fromCarryOverXBottom, y: y + eventHeight),
                                width: fromCarryOverWidth)
                            fromCarryOverPath.fill()
                            
                            let toCarryOverPath = flowPath(fromPoint: NSPoint(x: toCarryOverXTop, y: y),
                                toPoint: NSPoint(x: toCarryOverXBottom, y: y + eventHeight),
                                width: toCarryOverWidth)
                            toCarryOverPath.fill()
                            
                            let transferPath = flowPath(fromPoint: NSPoint(x: fromTransferX, y: y),
                                toPoint: NSPoint(x: toTransferX, y: y + eventHeight),
                                width: transferWidth)
                            transferPath.fill()
                            
                        }
                    }
                }
                
            case let .Earn(toAccount: account, amount: amount):
                // Draw rectangles for resulting states
                for (accountName, amount) in event.resultState {
                    if (accountName != account) {
                        if let accountIndex = firstIndexOf(store.accountNames, accountName) {
                            let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex)*(borderWidth + accountTrackWidth)
                            let width:  CGFloat = CGFloat(amount) * pixelsPerUnit
                            let balanceRect = NSRect(x: x, y: y, width: width, height: eventHeight)
                            NSRectFill(balanceRect)
                        }
                    }
                }
                
                if let accountIndex = firstIndexOf(store.accountNames, account) {
                    let amountWidth = CGFloat(amount) * pixelsPerUnit
                    let carryOverWidth = CGFloat(event.resultState[account]!) * pixelsPerUnit - amountWidth
                    
                    let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex) * (borderWidth + accountTrackWidth)
                    
                    let carryOverPath = flowPath(fromPoint: NSPoint(x: x, y: y),
                        toPoint: NSPoint(x: x + amountWidth, y: y + eventHeight),
                        width: carryOverWidth)
                    carryOverPath.fill()
                    
                    NSColor.greenColor().setFill()
                    let incomePath = incomePath(toPoint: NSPoint(x: x + amountWidth, y: y + eventHeight), width: amountWidth)
                    
                    incomePath.fill()
                }
            case let .Spend(fromAccountAccount: account, amount: amount):
                // Draw rectangles for resulting states
                for (accountName, amount) in event.resultState {
                    if (accountName != account) {
                        if let accountIndex = firstIndexOf(store.accountNames, accountName) {
                            let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex)*(borderWidth + accountTrackWidth)
                            let width:  CGFloat = CGFloat(amount) * pixelsPerUnit
                            let balanceRect = NSRect(x: x, y: y, width: width, height: eventHeight)
                            NSRectFill(balanceRect)
                        }
                    }
                }
                
                
                if let accountIndex = firstIndexOf(store.accountNames, account) {
                    let amountWidth = CGFloat(amount) * pixelsPerUnit
                    let carryOverWidth = CGFloat(event.resultState[account]!) * pixelsPerUnit
                    
                    let x: CGFloat      = accountTrackWidth/2.0 + CGFloat(accountIndex) * (borderWidth + accountTrackWidth)
                    
                    let carryOverPath = flowPath(fromPoint: NSPoint(x: x, y: y),
                        toPoint: NSPoint(x: x, y: y + eventHeight),
                        width: carryOverWidth)
                    carryOverPath.fill()
                    
                    NSColor.redColor().setFill()
                    
                    let spendPath = spendPath(fromPoint: NSPoint(x: x + carryOverWidth, y: y), width: amountWidth)
                    
                    spendPath.fill()
                }
            default:
                let bla = 4
            }
        }
    }
    
    
    
    init(frame frameRect: NSRect, _ store: CFStore) {
        self.store = store
        super.init(frame: frameRect)
    }
    
    required init(coder: NSCoder) {
        store = CFStore()
        store.description
        
        var dateSeed = 0
        func dateGenerator() -> NSDate {
            let poop = dateSeed++ * 60 * 60 - (7 * 24 * 60 * 60)
            let bla = NSDate().dateByAddingTimeInterval(NSTimeInterval(poop))
            return bla
        }
        
        let myFirstAccount = "myFirstAccount"
        store.openAccount(myFirstAccount, initialBalance: 0, date: dateGenerator())
        
        store.earn(myFirstAccount, amount: 100, date: dateGenerator())
        store.description
        store.earn(myFirstAccount, amount: 200, date: dateGenerator())
        store.description
        store.earn(myFirstAccount, amount: 100, date: dateGenerator())
        store.description
        
        
        let mySecondAccount = "mySecondAccount"
        store.openAccount(mySecondAccount, initialBalance: 0, date: dateGenerator())
        
        store.transfer(myFirstAccount, toAccount: mySecondAccount, amount: 100, date: dateGenerator())
        
        store.transfer(mySecondAccount, toAccount: myFirstAccount, amount: 50, date: dateGenerator())
        
        store.transfer(myFirstAccount, toAccount: mySecondAccount, amount: 200, date: dateGenerator())
        
        store.spend(mySecondAccount, amount: 100, date: dateGenerator())
        
        store.description
        super.init(coder: coder)
    }
}