//
//  ExplainViewController.swift
//  Camera_Calculator
//
//  Created by MobileProg on 30/11/2021.
//

import UIKit

class ExplainViewController: UIViewController {

    //variables to store equation
    var equation:String = ""
    var equationArray = [String]()
    
    @IBOutlet weak var equationLabel: UILabel!
    @IBOutlet weak var explainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //reset values of labels
        equationLabel.text = equation
        explainLabel.text = ""
        
        var i:String = ""
        //for loop to iterate through string characters
        for char in equation{
            //if character is number add it to i
            if (char.isNumber){
                i = i+String(char)
            }else{
                //if character is operator add i as well as operator then clear i
                equationArray.append(i)
                equationArray.append(String(char))
                i=""
            }
        }
        //add i to array one last time for last element in equation
        equationArray.append(i)
        
        //call convertToPostfix
        convertToPostfix(infix: equationArray)
        // Do any additional setup after loading the view.
    }
    
    func isNumber(s:String)->Bool{
        //convert string into int
        let num = Int(s)
        //if num is empty, string is not an integer.
        if (num==nil){
            return false
        }
        else{
            return true
        }
    }
    
    //function to convert infix expression to postfix
    func convertToPostfix(infix: [String]){
        //variables for postfix equation and stack
        var postfix = [String]()
        let s = Stack<String>()
        //for loop to iterate through infix equation array
        for i in 0...infix.count-1{
            let top = infix[i] //variable for current element in array
            if (isNumber(s: top)){ //if current element is a number add it to array
                postfix.append(top)
            }
            else if(top == "("){ //if current element is an open bracket add it to stack
                s.push(top)
            }else if (top == "^"){ // if current element is ^ denoting exponentials add it to stack
                s.push(top)
            }else if(top == ")"){ // if current element is closed bracket
                while(!s.empty() && s.top != "("){ //add all elements in stack to array till (
                    postfix.append(s.pop()!)
                }
                if(s.top! == "("){ // remove ( from stack
                    s.pop()
                }
            }else{ //add operators to array according to precedence
                while (!s.empty() && prec(top) <= prec(s.top!)){
                    postfix.append(s.pop()!)
                }
                s.push(top) //add top element to array
            }
        }
        while(!s.empty()){ // add whatever remains in stack to array
            postfix.append(s.pop()!)
        }
        evaluatePost(postfix: postfix)
    }
    
    // function to solve postfix expression and get step by step explaination on screen
    func evaluatePost(postfix: [String]){
        //variables to store numbers for calculation
        var a:Double = 0
        var b:Double = 0
        let s = Stack<String>() // stack for evaluating
        var isValid:Bool = true // boolean to ensure expression is valid
        var i:Int = 0 //used to iterate through expression array
        var text:String = "" //variable to store explaination text in
        //iterate while expression is valid
        while(i<postfix.count && isValid){
            let top = postfix[i] //variable to store current value from array
            if(isNumber(s: top)){ // if current value is number add it to stack
                s.push(String(top))
            }// if stack contains 2 or more elements, remove top two from stack and store them in variables
            else if(s.size()>1){
                a = Double(s.pop()!)!
                b = Double(s.pop()!)!
                //preform calculation based on operator
                //calculation is added to string and used for explaination
                if(top == "+"){
                    s.push(String(b+a))
                    text = text + "\(b) + \(a) = \(b+a)\n\n"
                }else if(top == "-"){
                    s.push(String(b+a))
                    text = text + "\(b) - \(a) = \(b-a)\n\n"
                }else if(top == "*"){
                    s.push(String(b*a))
                    text = text + "\(b) * \(a) = \(b*a)\n\n"
                }else if(top == "/"){
                    s.push(String(b/a))
                    text = text + "\(b) / \(a) = \(b/a)\n\n"
                }else if(top == "^"){
                    s.push(String(pow(b,a)))
                    text = text + "\(b) ^ \(a) = \(pow(b,a))\n\n"
                }else{// if top element is not operatror, expression is not valid
                    isValid = false
                }
            }// if top element is not number and stack contains less than 2 items, expression is not valid
            else{
                isValid = false
            }
            i += 1
        }
        explainLabel.text = text //show explaination on screen
    }
    
    //function to return precedence of operators
    func prec(_ text: String) -> Int{
        if (text == "+" || text == "-")
                {
                    return 1;
                }
                else if (text == "*" || text == "/")
                {
                    return 2;
                }
                else if (text == "^")
                {
                    return 3;
                }
                return -1;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
