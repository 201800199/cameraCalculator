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

class ViewController: UIViewController {

    var value:Double = 0;
    var prevValue:Double = 0;
    var Calculating:Bool = false;
    var operation = 0;
    var first:Bool = true;
    var calculated:Bool = false;

    var imageH:CGFloat = 0
    let overlayLayer = CALayer();
    
    var  recognizedWords:[String] = [String]()
    var recognizedRegion:String = String()
    
    let validCharacters: Set = .init("0123456789-+*/()^.")
    
    
    @IBOutlet weak var displayAll: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var everything: UIStackView!
    @IBOutlet weak var cancelbutton: UIButton!
    @IBOutlet weak var ExplainButton: UIButton!
    //@IBOutlet weak var IVHconstraint: NSLayoutConstraint!
    
    
    @IBAction func ReturnfromPic(_ sender: Any) {
        hideImageV()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let text1 = displayAll.text else {return}
        guard let text2 = displayLabel.text else {return}
        let target = segue.destination as! ExplainViewController
        target.equation = text1 + " = " + text2
    }
    
    @IBAction func unwindToVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    func hideImageV(){
        ImageView.isHidden = true
        everything.isHidden = false
        cancelbutton.isEnabled = false
        cancelbutton.isHidden = true
        ImageView.subviews.forEach{ $0.removeFromSuperview()}
        ImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    @IBAction func CameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        picker.delegate = self
    }
    
    func recognizeText(image:UIImage?){
        
        guard let cgimage = image?.cgImage else{return}
        
        
        let handler = VNImageRequestHandler(cgImage: cgimage, options: [:])
        
        let rRequest = VNRecognizeTextRequest{ rRequest , error in
            
            guard let rObservations = rRequest.results as? [VNRecognizedTextObservation],
                  error == nil else {return}
            
            for observation in rObservations {
                guard let text = observation.topCandidates(1).first?.string else{ return }
                //rText.append(text)
                if self.validCharacters.isSuperset(of: text){
                    let nRect = self.normalise(observation: observation)
                    self.drawRect(overlayLayer: self.overlayLayer, nRect: nRect, bValue: text)
                }
            }
            //print(rText)
            
        }
        
        do{
            try handler.perform([rRequest])
        }catch{
            print(error)
        }
        
    }
    
    func normalise(observation: VNRecognizedTextObservation)->CGRect{
        
        return CGRect(
            x: observation.boundingBox.origin.x,
            y: 1 - observation.boundingBox.origin.y - observation.boundingBox.height ,
            width : observation.boundingBox.width,
            height: observation.boundingBox.height
        )
        
    }
    
    func drawRect(overlayLayer: CALayer, nRect: CGRect, bValue:String) {
        let x = nRect.origin.x * ImageView.layer.frame.size.width
        let y = nRect.origin.y * imageH + (0.4 * (view.layer.frame.height-imageH))
        let width = nRect.width * ImageView.layer.frame.size.width
        let height = nRect.height * ImageView.layer.frame.size.height


          let outline = CALayer()
          outline.frame = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.1)
          outline.borderWidth = 2.0
          outline.borderColor = UIColor.red.cgColor
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        //button.setTitle("button1", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        button.accessibilityLabel = bValue

        ImageView.layer.addSublayer(outline)
        
        ImageView.addSubview(button)
        //print(ImageView.layer.sublayers?.count)
        ImageView.isUserInteractionEnabled = true
    }
    
    @objc func buttonClicked(sender:UIButton!){
        print(sender.accessibilityLabel!)
        guard let buttonVal = sender.accessibilityLabel else {return}
        let expression = Expression(buttonVal)
        let result = try? expression.evaluate()
        guard let answer = result else{return}
        displayLabel.text = String(answer)
        displayAll.text = buttonVal
        hideImageV()
        ExplainButton.isHidden = false
        ExplainButton.isEnabled = true
    }
    
    @IBAction func Numbers(_ sender: UIButton) {
        
        if(ExplainButton.isEnabled == true){
            ExplainButton.isHidden = true
            ExplainButton.isEnabled = false
        }
        if calculated == true{
            value = 0
            displayLabel.text = "0"
            displayAll.text = "0"
            prevValue = 0
            operation = 0
            first = true;
            calculated = false;
        }
        if Calculating == true{
            displayLabel.text = String(sender.tag - 1)
            value = Double(displayLabel.text!)!
            Calculating = false
            
        }else{
            if (displayLabel.text == "0" && sender.tag != 18 && sender.tag != 17){
                displayLabel.text = String(sender.tag - 1)
            }else if sender.tag == 18{
                //delete last character
                if displayLabel.text != "0"{
                    displayLabel.text = String(displayLabel.text!.dropLast())
                    if displayLabel.text == ""{
                        displayLabel.text = "0"
                    }
                }
            }else if sender.tag == 17{
                // add decimal point
                displayLabel.text = displayLabel.text! + "."
            }else{
                displayLabel.text = displayLabel.text! + String(sender.tag - 1)
            }
            
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
        if displayLabel.text != "" && sender.tag != 11 && sender.tag != 16{
            if calculated{
                calculated = false
            }
            else if first == false {
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
            
            if first{
                first = false;
            }
            if sender.tag == 12{   //Division
                
                displayAll.text = displayAll.text! + "/"
                
            }else if sender.tag == 13{ //Multiply
                
                displayAll.text = displayAll.text! + "*"
                
            }else if sender.tag == 14{ //Subtract
                
                displayAll.text = displayAll.text! + "-"
                
            }else if sender.tag == 15{ //Addition
                
                displayAll.text = displayAll.text! + "+"
                
            }
            operation = sender.tag
            Calculating = true;
        }else if sender.tag == 16{
            // calculate
            
            if calculated == false{
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
                first = false
                ExplainButton.isEnabled = true
                ExplainButton.isHidden = false
            }
            
                
            
            //first = true;
                        
        }else if sender.tag == 11{
            // clear
            value = 0
            displayLabel.text = "0"
            displayAll.text = "0"
            prevValue = 0
            operation = 0
            first = true;
            calculated = false;
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cancelbutton.isHidden = true
        ExplainButton.isEnabled = false
        ExplainButton.isHidden = true
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
        //IVHconstraint.constant = newH
        //ImageView.layer.frame.height = newH
        print(newH)
        
        ImageView.image = image
        ImageView.isHidden = false
        cancelbutton.isEnabled = true
        cancelbutton.isHidden = false
        everything.isHidden = true
        recognizeText(image: image)
        print("image acquired")
        
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
