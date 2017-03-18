//
//  ViewController.swift
//  CalculatorKeyboard
//
//  Created by Shaun O'Reilly on 11/11/2015.
//  Copyright © 2015 Visual Recruit Pty Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // Control how scroll view tutorial will display
    @IBOutlet var tutorial: UIScrollView! {
        //didSet: trigger code in bracket after tutorial is initialized in interface building
        didSet{
            tutorial.contentSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 420*5)
            tutorial.layer.borderColor = UIColor.lightGray.cgColor
            tutorial.layer.borderWidth = 1.0
            tutorial.layer.cornerRadius = 10.0
            
            let tutorialImages = [
                UIImageView(image: UIImage(named: "tutorial_1")),
                UIImageView(image: UIImage(named: "tutorial_2")),
                UIImageView(image: UIImage(named: "tutorial_3")),
                UIImageView(image: UIImage(named: "tutorial_4")),
                UIImageView(image: UIImage(named: "tutorial_5"))
            ]
            
            let baseY: CGFloat = 0.0
            
            var views: [UIView] = []
            var tutorialTexts = ["1. Go to Settings", "2. Navigate to General", "3. Navigate to Keyboard", "4. Navigate to Keyboards", "5. Click Add New Keyboard and add \"CalculatorKeyboard\" in the list"]
            // Config images positions
            for i in 0..<tutorialImages.count {
                tutorialImages[i].contentMode = .scaleAspectFit
                tutorialImages[i].clipsToBounds = true
                tutorialImages[i].layer.cornerRadius = 10.0
                tutorialImages[i].layer.borderWidth = 1.0
                tutorialImages[i].layer.borderColor = UIColor.lightGray.cgColor
                if i == 0 {
                    tutorialImages[i].frame = CGRect(x: 0, y: baseY + 60.0, width: UIScreen.main.bounds.width - 40.0, height: 360)
                    continue
                }
                tutorialImages[i].frame = CGRect(x: 0, y: baseY + 60.0 + CGFloat(i) * (tutorialImages[i-1].frame.height + 60.0), width: UIScreen.main.bounds.width - 40.0, height: 360)
            }
            
            // Add tutorial text among images
            for i in 0..<tutorialImages.count {
                views.append(tutorialImages[i])
                let textView = UILabel(frame: CGRect(x: 10, y: tutorialImages[i].frame.origin.y - 60.0, width: UIScreen.main.bounds.width - 60.0, height: 60.0))
                textView.numberOfLines = 0
                textView.font = UIFont.systemFont(ofSize: 14.0)
                textView.text = tutorialTexts[i]
                views.append(textView)
            }
            
            // Add images and tutorial text into scroll view
            for viewToAdd in views {
                tutorial.addSubview(viewToAdd)
            }
        }
    }
    //Main textfield
    @IBOutlet var input: UITextField! {
        didSet{
            input.delegate = self
        }
    }
    //Add gesture to main view so tapping screen will dismiss keyboard
    var gesture: UIGestureRecognizer!
    func dismissKeyboard(){
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.gestureRecognizers?.removeLast()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        (gesture as! UILongPressGestureRecognizer).minimumPressDuration = 0
        view.addGestureRecognizer(gesture)
    }
}

