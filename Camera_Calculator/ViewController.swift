//
//  ViewController.swift
//  Camera_Calculator
//
//  Created by MobileProg on 15/11/2021.
//

import UIKit
import Vision
//import MathParser
import Expression
import WebKit
class ViewController: UIViewController {

    //variables for calculator functionality
    var value:Double = 0;
    var prevValue:Double = 0;
    var Calculating:Bool = false;
    var operation = 0;
    
    //boolean variables to check wheteher calculation has been done previously
    var firstoperator:Bool = true;
    var calculated:Bool = false;

    //value to store the height of the image
    var imageH:CGFloat = 0
    
    //value for the overlay layer of the view
    let overlayLayer = CALayer();
    
    //var  recognizedWords:[String] = [String]()
    //var recognizedRegion:String = String()
    
    //dictionary containing math formulas, their solutions and website associtated witht them
    let formulaDict = ["\\((?<num1>[0-9a-z]+)\\+(?<num2>[0-9a-z]+)\\)\\^2":["x^2 + 2*x*y + y^2", "https://byjus.com/maths/algebraic-identities/"], //(x+y)^2
                       "\\((?<num1>[0-9a-z]+)-(?<num2>[0-9a-z]+)\\)\\^2":["x^2 - 2*x*y + y^2","https://byjus.com/maths/algebraic-identities/"],//x-y)^2
                        ]
    
    
    //iboutlets for all storyboard elements
    @IBOutlet weak var displayAll: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var everything: UIStackView!
    @IBOutlet weak var cancelbutton: UIButton!
    @IBOutlet weak var ExplainButton: UIButton!
    @IBOutlet weak var LearnMorebtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var ReturnfromWebV: UIButton!
    //@IBOutlet weak var IVHconstraint: NSLayoutConstraint!
    
    //function to hide imageview without selecting an equation
    @IBAction func ReturnfromPic(_ sender: Any) {
        hideImageV()
        
    }
    
    //function to hide the webview on button click
    @IBAction func HideWebV(_ sender: Any) {
        webView.isHidden = true
        ReturnfromWebV.isHidden = true
    }
    
    //function to segue into explain view controller and pass equation string
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //store equation and its solution as text
        guard let text1 = displayAll.text else {return}
        guard let text2 = displayLabel.text else {return}
        let target = segue.destination as! ExplainViewController
        //send text to target view controller during segue
        target.equation = text1 + " = " + text2
    }
    
    //function to return from
   // @IBAction func unwindToVC(_ unwindSegue: UIStoryboardSegue) {
     //   _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    //}
    
    //function to hide all elements of the image view
    func hideImageV(){
        ImageView.isHidden = true
        everything.isHidden = false
        cancelbutton.isEnabled = false
        cancelbutton.isHidden = true
        //remove all subviews and sublayers from the imageview to remove bounding boxes from screen
        ImageView.subviews.forEach{ $0.removeFromSuperview()}
        ImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    //function to open camera/photo library on button click
    @IBAction func CameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){ //check whether device has camera
            picker.sourceType = .camera //open camera
        }else {
        picker.sourceType = .photoLibrary// open photo library if device has no camera
        }
        present(picker, animated: true)
        picker.delegate = self
    }
    
    //function to find and recognize text from an image
    func recognizeText(image:UIImage?){
        
        guard let cgimage = image?.cgImage else{return} //convert UIImage to CGImage
        
        
        let handler = VNImageRequestHandler(cgImage: cgimage, options: [:]) //create vision services handler
        
        // create vision request
        let rRequest = VNRecognizeTextRequest{ rRequest , error in
            
            //get observations as VNRecognizedTextObservation for text recognition
            guard let rObservations = rRequest.results as? [VNRecognizedTextObservation],
                  error == nil else {return}
            
            //call drawRect function for each recognized text on screen after normalizing bounding box
            for observation in rObservations {
                guard let text = observation.topCandidates(1).first?.string else{ return }
                    let nRect = self.normalise(observation: observation)
                    self.drawRect(overlayLayer: self.overlayLayer, nRect: nRect, bValue: text)

            }

            
        }
        //perforn request on handler
        do{
            try handler.perform([rRequest])
        }catch{
            print(error)
        }
        
    }
    //function to normalise the boundingbox of VNRecognizedTextObservation and return the normalized bounding box
    func normalise(observation: VNRecognizedTextObservation)->CGRect{
        
        return CGRect(
            x: observation.boundingBox.origin.x,
            y: 1 - observation.boundingBox.origin.y - observation.boundingBox.height ,
            width : observation.boundingBox.width,
            height: observation.boundingBox.height
        )
        
    }
    
    //function to draw bounding boxes around recognized text
    func drawRect(overlayLayer: CALayer, nRect: CGRect, bValue:String) {
        //set up coordinates of bounding box origin
        let x = nRect.origin.x * ImageView.layer.frame.size.width
        let y = nRect.origin.y * imageH + (0.5 * (ImageView.layer.frame.height-imageH))
        //set up width and hieght of bounding box
        let width = nRect.width * ImageView.layer.frame.size.width
        let height = nRect.height * ImageView.layer.frame.size.height

//create bounding box as CALayer
          let outline = CALayer()
          outline.frame = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.1)
          outline.borderWidth = 2.0
          outline.borderColor = UIColor.red.cgColor
        //create button for each recognized text
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.addTarget(self, action: #selector(RectangleClicked), for: .touchUpInside)
        button.accessibilityLabel = bValue //add value of text to button

        //add boundingbox to imageview
        ImageView.layer.addSublayer(outline)
        //add button to view
        ImageView.addSubview(button)
        ImageView.isUserInteractionEnabled = true// enable user interaction so user can click on buttons
    }
    
    //function to calculate value of equation or solution to formula.
    @objc func RectangleClicked(sender:UIButton!){
        //variables for formula detection using RegEx
        var matched:Bool = false
        var website:String = ""
        var sol:String = ""
        var numbers:[String] = []
        //extract equation from button accessability label
        guard let buttonVal = sender.accessibilityLabel else {return}
        //detemine the range of the equation
        let range = NSRange(location: 0, length: buttonVal.utf16.count)
        //iterate through formulaDict patterns and try to find match
        for pattern in formulaDict.keys{
            let regex = try! NSRegularExpression(pattern: pattern)
            //if match is found
            if let matches = regex.firstMatch(in: buttonVal, options: [], range: range){
                    // set all variable accordingly
                    matched=true
                    website = formulaDict[pattern]![1]
                    sol = formulaDict[pattern]![0]
                    //replace general values of solution with corresponding values in given equation
                    for name in ["num1","num2"]{
                        let matchrange = matches.range(withName: name)
                        if let substring = Range(matchrange,in: buttonVal){
                            print(String(buttonVal[substring]))
                            numbers.append(String(buttonVal[substring]))
                        }
                    }
            }
        }
        if(matched){
            sol = sol.replacingOccurrences(of: "x", with: numbers[0])
            sol = sol.replacingOccurrences(of: "y", with: numbers[1])
            displayAll.text = buttonVal
            displayLabel.text = sol
            let url = URL(string: website)!
           // webView.isHidden=false
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
            LearnMorebtn.isHidden = false
            LearnMorebtn.isEnabled = true
        }
        else{
            let expression = Expression(buttonVal)
            let result = try? expression.evaluate()
            guard let answer = result else{return}
            displayLabel.text = String(answer)
            displayAll.text = buttonVal
            ExplainButton.isHidden = false
            ExplainButton.isEnabled = true
        }
        hideImageV()
        
    }
    @IBAction func learnMoreClicked(_ sender: Any) {
        ReturnfromWebV.isHidden = false
        webView.isHidden = false
    }
    
    @IBAction func Numbers(_ sender: UIButton) {
        
        //hide explain and learn more buttons when user inputs a number
        if(ExplainButton.isEnabled == true){
            ExplainButton.isHidden = true
            ExplainButton.isEnabled = false
        }
        if(LearnMorebtn.isEnabled == true){
            LearnMorebtn.isHidden = false
            LearnMorebtn.isEnabled = true
        }
        if calculated == true{
            value = 0
            displayLabel.text = "0"
            displayAll.text = "0"
            prevValue = 0
            operation = 0
            firstoperator = true;
            calculated = false;
        }
        //if operator has been entered
        if Calculating == true{
            displayLabel.text = String(sender.tag - 1)
            value = Double(displayLabel.text!)!
            Calculating = false
            
        }else{
            //if user clicks on one of the numbered buttons
            if (displayLabel.text == "0" && sender.tag != 18 && sender.tag != 17){ //if displaylabel is 0 change it to pressed number
                displayLabel.text = String(sender.tag - 1)//s
            }else if sender.tag == 18{ // if delete button is pressed
                //delete last character
                if displayLabel.text != "0"{ //if number on screen is not 0
                    displayLabel.text = String(displayLabel.text!.dropLast()) //delete last character
                    if displayLabel.text == ""{ // if label becomes empty change it to 0
                        displayLabel.text = "0"
                    }
                }
            }else if sender.tag == 17{ // if decimal point button is presased add decimal point to label
                // add decimal point
                displayLabel.text = displayLabel.text! + "."
            }else{
                displayLabel.text = displayLabel.text! + String(sender.tag - 1) // add value to button to label
            }
            //store the value of label for calculations
            value = Double(displayLabel.text!)!
        }
        
        //17 is decimal point
        // 18 is backspace
        
        
       
    }
    
    @IBAction func buttons(_ sender: UIButton) {
        
        if(ExplainButton.isEnabled == true){
            ExplainButton.isHidden = true
            ExplainButton.isEnabled = false
        }
        if(LearnMorebtn.isEnabled == true){
            LearnMorebtn.isHidden = false
            LearnMorebtn.isEnabled = true
        }
        if displayLabel.text != "" && sender.tag != 11 && sender.tag != 16{
            if calculated{
                calculated = false
            }
            else if firstoperator == false {
                // if not first operator pressed, calculate the answer.
                displayAll.text = displayAll.text! + displayLabel.text!
                if operation == 12{
                    displayLabel.text = String(prevValue/value)
                }else if operation == 13{
                    displayLabel.text = String(prevValue*value)
                }else if operation == 14{
                    displayLabel.text = String(prevValue-value)
                }else if operation == 15{
                    displayLabel.text = String(prevValue+value)
                }
                
            }
            else if displayAll.text == "0" && calculated==false{
                displayAll.text = displayLabel.text
            }else if calculated==false{
                displayAll.text = displayAll.text! + displayLabel.text!
            }
            prevValue = Double(displayLabel.text!)!
            
            if firstoperator{
                firstoperator = false;
            }
            //check whick operator is pressed
            //add pressed operator to label
            if sender.tag == 12{   //Division
                
                displayAll.text = displayAll.text! + "/"
                
            }else if sender.tag == 13{ //Multiply
                
                displayAll.text = displayAll.text! + "*"
                
            }else if sender.tag == 14{ //Subtract
                
                displayAll.text = displayAll.text! + "-"
                
            }else if sender.tag == 15{ //Addition
                
                displayAll.text = displayAll.text! + "+"
                
            }
            //store operation button tag and set calculating is true
            operation = sender.tag
            Calculating = true;
            
        }else if sender.tag == 16{ // = is pressed
            
            if calculated == false{
                
                // add current number to full equation and preform calculation based on operator
                displayAll.text = displayAll.text! + displayLabel.text!
                if operation == 12{
                    displayLabel.text = String(prevValue/value)
                }else if operation == 13{
                    displayLabel.text = String(prevValue*value)
                }else if operation == 14{
                    displayLabel.text = String(prevValue-value)
                }else if operation == 15{
                    displayLabel.text = String(prevValue+value)
                }
                
                calculated = true;
                firstoperator = false
                ExplainButton.isEnabled = true
                ExplainButton.isHidden = false
            }
            
                        
        }else if sender.tag == 11{ //clear button is pressed
            //reset all variables and set label text to 0
            value = 0
            displayLabel.text = "0"
            displayAll.text = "0"
            prevValue = 0
            operation = 0
            firstoperator = true;
            calculated = false;
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cancelbutton.isHidden = true
        ExplainButton.isEnabled = false
        ExplainButton.isHidden = true
        LearnMorebtn.isHidden = true
        LearnMorebtn.isEnabled = false
        ReturnfromWebV.isHidden = true
        
        view.layer.addSublayer(overlayLayer)
    }

}

extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else{
            return
        }
        imagePickerControllerDidCancel(picker)
        
        //set height to image height
        let ratio = image.size.width/image.size.height
        let newH = ImageView.frame.width/ratio
        imageH = newH
        
        //present ImageView and hide other elements on screen
        ImageView.image = image
        ImageView.isHidden = false
        cancelbutton.isEnabled = true
        cancelbutton.isHidden = false
        everything.isHidden = true
        recognizeText(image: image)
        
    }
}
	
extension CGRect {
    func scaleUp(scaleUp: CGFloat) -> CGRect {
       let biggerRect = self.insetBy(
         dx: -self.size.width * scaleUp,
         dy: -self.size.height * scaleUp
       )

       return biggerRect
     }}
