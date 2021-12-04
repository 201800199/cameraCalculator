//
//  Stack.swift
//  Camera_Calculator
//
//  Created by MobileProg on 30/11/2021.
//

import UIKit

class Stack<T> {
    
    private var elements:[T] = []

    func push(_ element: T) {
        elements.append(element)
      }

    func pop() -> T? {
        guard !elements.isEmpty else {
          return nil
        }
        return elements.popLast()
      }

    func size()->Int{
        return elements.count
    }
    func empty()-> Bool{
        if(elements.isEmpty){
            return true
        }else{
            return false
        }
    }
    
    var top: T? {
        return elements.last
      }
    
    
}
