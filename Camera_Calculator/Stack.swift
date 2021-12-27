//
//  Stack.swift
//  Camera_Calculator
//
//  Created by MobileProg on 30/11/2021.
//

import UIKit

class Stack<T> {
    
    //array to hold all elements
    private var elements:[T] = []

    //add element to array
    func push(_ element: T) {
        elements.append(element)
      }
    
    //remove top element and return it
    func pop() -> T? {
        guard !elements.isEmpty else {
          return nil
        }
        return elements.popLast()
      }
    
    //get size of array
    func size()->Int{
        return elements.count
    }
    
    //check if array is empty
    func empty()-> Bool{
        if(elements.isEmpty){
            return true
        }else{
            return false
        }
    }
    //get top element of array
    var top: T? {
        return elements.last
      }
    
    
}
