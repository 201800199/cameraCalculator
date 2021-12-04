//
//  ExplainViewController.swift
//  Camera_Calculator
//
//  Created by MobileProg on 30/11/2021.
//

import UIKit

class ExplainViewController: UIViewController {

    var equation:String = ""
    var array = [String]()
    
    @IBOutlet weak var equationLabel: UILabel!
    
    @IBOutlet weak var explainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        equationLabel.text = equation
        explainLabel.text = ""
        
        var i:String = ""
        for char in equation{
            //array.append(char)
            if (char.isNumber){
                i = i+String(char)
            }else{
                array.append(i)
                array.append(String(char))
                i=""
            }
        }
        array.append(i)
        
        //print(array)
        
        convertToPostfix(infix: array)
        // Do any additional setup after loading the view.
    }
    
    func isNumber(s:String)->Bool{
        var num = Int(s)
        if (num==nil){
            return false
        }
        else{
            return true
        }
    }
    
    func convertToPostfix(infix: [String]){
        var postfix = [String]()
        let s = Stack<String>()
        for i in 0...infix.count-1{
            let top = infix[i]
            if (isNumber(s: top)){
                postfix.append(top)
            }
            else if(top == "("){
                s.push(top)
            }else if (top == "^"){
                s.push(top)
            }else if(top == ")"){
                while(!s.empty() && s.top != "("){
                    postfix.append(s.pop()!)
                }
                if(s.top! == "("){
                    s.pop()
                }
            }else{
                while (!s.empty() && prec(top) <= prec(s.top!)){
                    postfix.append(s.pop()!)
                }
                s.push(top)
            }
        }
        while(!s.empty()){
            postfix.append(s.pop()!)
        }
        //print(postfix)
        evaluatePost(postfix: postfix)
    }
    
    func evaluatePost(postfix: [String]){
        var a:Double = 0
        var b:Double = 0
        let s = Stack<String>()
        var isValid:Bool = true
        var i:Int = 0
        var text:String = ""
        while(i<postfix.count && isValid){
            let top = postfix[i]
            if(isNumber(s: top)){
                s.push(String(top))
            }else if(s.size()>1){
                a = Double(s.pop()!)!
                b = Double(s.pop()!)!
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
                }else{
                    isValid = false
                }
            }
            else{
                isValid = false
            }
            i += 1
        }
        print(text)
        explainLabel.text = text
        //print("Answer is \(s.pop())")
    }
    
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
    
    func isOperator(_ text: String) -> Bool{
        if (text == "+" || text == "-" ||
                    text == "*" || text == "/" ||
                    text == "^")
                {
                    return true;
                }
                return false;
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
