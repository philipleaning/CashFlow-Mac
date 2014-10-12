//
//  CashFlowStore.swift
//  CashFlow
//
//  Created by Alexandre Lopoukhine on 05/10/2014.
//  Copyright (c) 2014 bluetatami. All rights reserved.
//

import Foundation

class CFStore {
    var accountNames:    [String] = []
    
    var events: [CFEvent] = []
    
    //Singleton class stuff - its a database... This shouldn't hurt
    class var sharedInstance: CFStore {
        struct Static {
            static var instance: CFStore?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CFStore()
        }
        
        return Static.instance!
    }
    
    func performAction(eventType: CFEventType, atDate date: NSDate) {
        // Find index to insert event at
        var insertionIndex: Int?
        for (index, event) in enumerate(events) {
            if event.date.compare(date) == .OrderedDescending {
                insertionIndex = index
                break
            }
        }
        
        let newEvent = CFEvent(date: date, eventType: eventType, resultState: [:])
        
        let bla = insertionIndex
        
        if let index = insertionIndex {
            events.insert(newEvent, atIndex: index)
        } else {
            events.append(newEvent)
        }
        
        // Recompute all the event results
        recomputeAll()
    }
    
    func openAccount(accountName: String, initialBalance: Int, date: NSDate) {
        if !arrayContainsElement(accountNames, accountName) {
            accountNames.append(accountName)
        }
        let newEventType = CFEventType.OpenAccount(accountName: accountName, initialBalance: initialBalance)
        performAction(newEventType, atDate: date)
    }
    
    func transfer(fromAccount: String, toAccount: String, amount: Int, date: NSDate) {
        performAction(.Transfer(fromAccount: fromAccount, toAccount: toAccount, amount: amount) , atDate: date)
    }
    
    func closeAccount(accountName: String, date: NSDate) {
        performAction(.CloseAccount(accountName: accountName), atDate: date)
    }
    
    func earn(accountName: String, amount: Int, date: NSDate) {
        performAction(.Earn(toAccount: accountName, amount: amount), atDate: date)
    }
    
    func spend(accountName: String, amount: Int, date: NSDate) {
        performAction(.Spend(fromAccount: accountName, amount: amount), atDate: date)
    }
    
    func recomputeAll() {
        var previousState: [String:Int] = [:]
        0..<events.count
        for eventIndex in 0..<events.count {
            eventIndex
            switch events[eventIndex].eventType {
            case .OpenAccount(account: let newAccount, initialBalance: let initialBalance):
                previousState[newAccount] = initialBalance
            case .CloseAccount(account: let account):
                previousState.removeValueForKey(account)
            case .Transfer(fromAccount: let fromAccount, toAccount: let toAccount, amount: let amountTransferred):
                if let previousFrom = previousState[fromAccount] {
                    previousState[fromAccount] =  previousFrom - amountTransferred
                }
                if let previousTo = previousState[toAccount] {
                    previousState[toAccount] =  previousTo + amountTransferred
                }
            case let .Earn(toAccount: toAccount, amount: amount):
                if let previousTo = previousState[toAccount] {
                    previousState[toAccount] =  previousTo + amount
                }
            case let .Spend(fromAccount: fromAccount, amount: amount):
                if let previousFrom = previousState[fromAccount] {
                    previousState[fromAccount] =  previousFrom - amount
                }
            }
            
            
            events[eventIndex].resultState = previousState
        }
    }
    
    var description: String {
        var returnedString = "\n"
        
        for event in events {
            switch event.eventType {
            case .OpenAccount(accountName: let accountName, initialBalance: let initialBalance):
                returnedString += "Open account \(accountName)"
            case .CloseAccount(accountName: let accountName):
                returnedString += "Close account \(accountName)"
            case .Transfer(fromAccount: let fromAccountName, toAccount: let toAccountName, amount: let amount):
                returnedString += "Transfer \(amount) from \(fromAccountName) to \(toAccountName)"
            case let .Earn(toAccount: account, amount: amount):
                returnedString += "Earn \(amount) to \(account)"
            case let .Spend(fromAccount: account, amount: amount):
                returnedString += "Spend \(amount) from \(account)"
            }
            returnedString += "\n\t\t\t\t \(event.resultState) \n"
        }
        
        return returnedString
    }
}

func arrayContainsElement<T: Equatable>(array: Array<T>, element: T) -> Bool {
    for el in array {
        if el == element {
            return true
        }
    }
    return false
}

func firstIndexOf<T: Equatable>(array: Array<T>, element: T) -> Int? {
    for (index, el) in enumerate(array) {
        if el == element {
            return index
        }
    }
    return nil
}

struct CFEvent {
    let date:      NSDate
    let eventType: CFEventType
    var resultState: [String: Int]
}

enum CFEventType {
    case OpenAccount(accountName: String, initialBalance: Int)
    case CloseAccount(accountName: String)
    case Transfer(fromAccount: String, toAccount: String, amount: Int)
    case Earn(toAccount: String, amount: Int)
    case Spend(fromAccount: String, amount: Int)
}

