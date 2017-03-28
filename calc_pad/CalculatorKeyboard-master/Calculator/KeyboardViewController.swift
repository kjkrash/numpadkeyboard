//
//  KeyboardViewController.swift
//  Numpad Keyboard
//

import UIKit
import Material //Find other 3rd-party dependencies here -> cocoapods.org

class KeyboardViewController: UIInputViewController {
    ////////////////////////////////////////////
    //////////// VARIABLE AND OUTLET ///////////
    ////////////   INITIALIZATION   ////////////
    ////////////////////////////////////////////
    
    var shiftBool = false
    var turnOff = false
    @IBOutlet var topRegion: UIView!
    @IBOutlet var leftRegion: UIView!
    @IBOutlet var rightRegion: UIView!
    @IBOutlet var nextKeyboardButton: IconButton!
    @IBOutlet var numberPadSwitcher: UIButton!
    @IBOutlet var dismissButton: IconButton!
    @IBOutlet var displayBackspace: IconButton!{
        didSet{
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.shouldClearPreviousWordInTextField))
            displayBackspace.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet var mainBackspace: RaisedButton!
    @IBOutlet var newlineButton: RaisedButton!
    @IBOutlet var sendButton: RaisedButton!
    @IBOutlet var spaceButton: RoundButton!{
        didSet{
            spaceButton.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            
        }
    }
    
    @IBOutlet var display: UILabel! {
        didSet{
            display.isUserInteractionEnabled = true
            display.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.shouldInsertText)))
        }
    }
    @IBOutlet var syms_1: RaisedButton!
    @IBOutlet var syms_2: RaisedButton!
    @IBOutlet var syms_3: RaisedButton!
    @IBOutlet var shift: RaisedButton!
    
    @IBOutlet var predict1: RoundButton!
    @IBOutlet var predict2: RoundButton!
    @IBOutlet var predict3: RoundButton!
    @IBOutlet var predict4: RoundButton!
    
    @IBOutlet var predict5: UIButton!
    @IBOutlet var predict6: UIButton!
    @IBOutlet var predict7: UIButton!
    @IBOutlet var predict8: UIButton!
    @IBOutlet var predict9: UIButton!
    @IBOutlet var predict10: UIButton!
    @IBOutlet var predict11: UIButton!
    @IBOutlet var predict12: UIButton!
    @IBOutlet var predict13: UIButton!
    @IBOutlet var predict14: UIButton!
    @IBOutlet var predict15: UIButton!
    @IBOutlet var predict16: UIButton!
    @IBOutlet var predict17: UIButton!
    @IBOutlet var predict18: UIButton!
    @IBOutlet var predict19: UIButton!
    @IBOutlet var predict20: UIButton!
    
    @IBOutlet weak var char1: UIButton!
    @IBOutlet weak var char2: UIButton!
    @IBOutlet weak var char3: UIButton!
    @IBOutlet weak var char4: UIButton!
    
    
    @IBOutlet var one: RoundButton!{
        didSet{
            one.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            one.titleLabel!.font =  UIFont(name: "one", size: 18)
        }
    }
    @IBOutlet var two: RoundButton!{
        didSet{
            two.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            two.titleLabel!.font =  UIFont(name: "two", size: 18)
            
        }
    }
    @IBOutlet var three: RoundButton!{
        didSet{
            three.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            three.titleLabel!.font =  UIFont(name: "three", size: 18)
        }
    }
    @IBOutlet var four: RoundButton!{
        didSet{
            four.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            four.titleLabel!.font =  UIFont(name: "four", size: 18)
        }
    }
    @IBOutlet var five: RoundButton!{
        didSet{
            five.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            five.titleLabel!.font =  UIFont(name: "five", size: 18)
        }
    }
    @IBOutlet var extensionView: UIView!
    @IBOutlet var six: RoundButton!{
        didSet{
            six.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            six.titleLabel!.font =  UIFont(name: "six", size: 18)
            
        }
    }
    @IBOutlet var seven: RoundButton!{
        didSet{
            seven.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            seven.titleLabel!.font =  UIFont(name: "seven", size: 18)
            
        }
    }
    @IBOutlet var eight: RoundButton!{
        didSet{
            eight.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            eight.titleLabel!.font =  UIFont(name: "eight", size: 18)
            
        }
    }
    @IBOutlet var nine: RoundButton!{
        didSet{
            nine.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            nine.titleLabel!.font =  UIFont(name: "nine", size: 18)
            
        }
    }
    
    var keyboardView: UIView!
    var shouldClearDisplayBeforeInserting: Bool = true
    var keyscontrol = KeysControl()
    var motherViewsHaveConstrainted: Bool = false
    var suggestions: [String] = [] {
        didSet{
            predict1.setTitle(suggestions[0], for: .normal)
            predict2.setTitle(suggestions[1], for: .normal)
            predict3.setTitle(suggestions[2], for: .normal)
            predict4.setTitle(suggestions[3], for: .normal)
            predict5.setTitle(suggestions[4], for: .normal)
            predict6.setTitle(suggestions[5], for: .normal)
            predict7.setTitle(suggestions[6], for: .normal)
            predict8.setTitle(suggestions[7], for: .normal)
            predict9.setTitle(suggestions[8], for: .normal)
            predict10.setTitle(suggestions[9], for: .normal)
            predict11.setTitle(suggestions[10], for: .normal)
            predict12.setTitle(suggestions[11], for: .normal)
            predict13.setTitle(suggestions[12], for: .normal)
            predict14.setTitle(suggestions[13], for: .normal)
            predict15.setTitle(suggestions[14], for: .normal)
            predict16.setTitle(suggestions[15], for: .normal)
            predict17.setTitle(suggestions[16], for: .normal)
            predict18.setTitle(suggestions[17], for: .normal)
            predict19.setTitle(suggestions[18], for: .normal)
            predict20.setTitle(suggestions[19], for: .normal)
        }
    }
    
    ////////////////////////////////////////////
    ///////////// KEYBOARD AND VIEW ////////////
    /////////////     LIFE CYCLES   ////////////
    ////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        updateViewConstraints()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.numberOfTouchesRequired = 1
        longPress.allowableMovement = 0.1
        mainBackspace.addGestureRecognizer(longPress)
    }
    
    func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        textDocumentProxy.deleteBackward()
        //src: http://stackoverflow.com/questions/25633189/ios-8-custom-keyboard-hold-button-to-delete

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let expandedHeight:CGFloat = 270
        let heightConstraint = NSLayoutConstraint(item:self.view,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 0.0,
                                                  constant: expandedHeight)
        self.view.addConstraint(heightConstraint)
    }
    
    override func updateViewConstraints() {
        if motherViewsHaveConstrainted {
            leftRegion.layout(syms_1)
                .left(Padding().sidePanels.leftRegion.forButton(withIndex: 1).left)
                .top(Padding().sidePanels.leftRegion.forButton(withIndex: 1).top)
                .height(Padding.SidePanels.LeftRegion.buttonDimensions.height)
                .width(Padding.SidePanels.LeftRegion.buttonDimensions.width)
            leftRegion.layout(syms_2)
                .left(Padding().sidePanels.leftRegion.forButton(withIndex: 2).left)
                .top(Padding().sidePanels.leftRegion.forButton(withIndex: 2).top)
                .height(Padding.SidePanels.LeftRegion.buttonDimensions.height)
                .width(Padding.SidePanels.LeftRegion.buttonDimensions.width)
            leftRegion.layout(syms_3)
                .left(Padding().sidePanels.leftRegion.forButton(withIndex: 3).left)
                .top(Padding().sidePanels.leftRegion.forButton(withIndex: 3).top)
                .height(Padding.SidePanels.LeftRegion.buttonDimensions.height)
                .width(Padding.SidePanels.LeftRegion.buttonDimensions.width)
            leftRegion.layout(shift)
                .left(Padding().sidePanels.leftRegion.forButton(withIndex: 4).left)
                .top(Padding().sidePanels.leftRegion.forButton(withIndex: 4).top)
                .height(Padding.SidePanels.LeftRegion.buttonDimensions.height)
                .width(Padding.SidePanels.LeftRegion.buttonDimensions.width)
            rightRegion.layout(mainBackspace)
                .left(Padding().sidePanels.rightRegion.forButton(withIndex: 1).left)
                .top(Padding().sidePanels.rightRegion.forButton(withIndex: 1).top)
                .height(Padding.SidePanels.RightRegion.buttonDimensions.height)
                .width(Padding.SidePanels.RightRegion.buttonDimensions.width)
            rightRegion.layout(newlineButton)
                .left(Padding().sidePanels.rightRegion.forButton(withIndex: 2).left)
                .top(Padding().sidePanels.rightRegion.forButton(withIndex: 2).top)
                .height(Padding.SidePanels.RightRegion.buttonDimensions.height)
                .width(Padding.SidePanels.RightRegion.buttonDimensions.width)
            rightRegion.layout(sendButton)
                .left(Padding().sidePanels.rightRegion.forButton(withIndex: 3).left)
                .top(Padding().sidePanels.rightRegion.forButton(withIndex: 3).top)
                .height(Padding.SidePanels.RightRegion.returnButtonDimensions.height)
                .width(Padding.SidePanels.RightRegion.returnButtonDimensions.width)
            topRegion.layout(char1)
                .left(Padding().sidePanels.topRegion.charLayouts(index: 1).left)
                .top(Padding().sidePanels.topRegion.charLayouts(index: 1).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.charDimensions.width)
                .height(Padding.SidePanels.TopRegion.charDimensions.height)
            topRegion.layout(char2)
                .left(Padding().sidePanels.topRegion.charLayouts(index: 2).left)
                .top(Padding().sidePanels.topRegion.charLayouts(index: 2).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.charDimensions.width)
                .height(Padding.SidePanels.TopRegion.charDimensions.height)
            topRegion.layout(char3)
                .left(Padding().sidePanels.topRegion.charLayouts(index: 3).left)
                .top(Padding().sidePanels.topRegion.charLayouts(index: 3).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.charDimensions.width)
                .height(Padding.SidePanels.TopRegion.charDimensions.height)
            topRegion.layout(char4)
                .left(Padding().sidePanels.topRegion.charLayouts(index: 4).left)
                .top(Padding().sidePanels.topRegion.charLayouts(index: 4).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.charDimensions.width)
                .height(Padding.SidePanels.TopRegion.charDimensions.height)
            topRegion.layout(dismissButton)
                .left(Padding().sidePanels.topRegion.buttonsLayouts(index: 1).left)
                .top(Padding().sidePanels.topRegion.buttonsLayouts(index: 1).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.buttonsDimensions.width)
                .height(Padding.SidePanels.TopRegion.buttonsDimensions.height)
            topRegion.layout(displayBackspace)
                .left(Padding().sidePanels.topRegion.buttonsLayouts(index: 2).left)
                .top(Padding().sidePanels.topRegion.buttonsLayouts(index: 2).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.buttonsDimensions.width)
                .height(Padding.SidePanels.TopRegion.buttonsDimensions.height)
            topRegion.layout(predict1)
                .left()
                .top(Padding().sidePanels.topRegion.predictLayouts(index: 4).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            topRegion.layout(predict2)
                .left(Padding().sidePanels.topRegion.predictLayouts(index: 5).left)
                .top(Padding().sidePanels.topRegion.predictLayouts(index: 5).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            topRegion.layout(predict3)
                .left(Padding().sidePanels.topRegion.predictLayouts(index: 6).left)
                .top(Padding().sidePanels.topRegion.predictLayouts(index: 6).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            topRegion.layout(predict4)
                .left(Padding().sidePanels.topRegion.predictLayouts(index: 7).left)
                .top(Padding().sidePanels.topRegion.predictLayouts(index: 7).top)
                .bottom()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict5)
                .left()
                .top()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict6)
                .left(Padding.SidePanels.TopRegion.predictDimensions.width)
                .top()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict7)
                .left(2*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict8)
                .left(3*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top()
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict9)
                .left()
                .top(Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict10)
                .left(Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict11)
                .left(2*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict12)
                .left(3*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict13)
                .left()
                .top(2*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict14)
                .left(Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(2*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict15)
                .left(2*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(2*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict16)
                .left(3*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(2*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict17)
                .left()
                .top(3*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict18)
                .left(Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(3*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict19)
                .left(2*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(3*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            extensionView.layout(predict20)
                .left(3*Padding.SidePanels.TopRegion.predictDimensions.width)
                .top(3*Padding.SidePanels.TopRegion.predictDimensions.height)
                .width(Padding.SidePanels.TopRegion.predictDimensions.width)
                .height(Padding.SidePanels.TopRegion.predictDimensions.height)
            super.updateViewConstraints()
        }else{
            keyboardView.layout(one)
                .left(Padding().numberPads.forNumber(num: 1).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 1).top)
            keyboardView.layout(two)
                .left(Padding().numberPads.forNumber(num: 2).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 2).top)
            keyboardView.layout(three)
                .left(Padding().numberPads.forNumber(num: 3).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 3).top)
            keyboardView.layout(four)
                .left(Padding().numberPads.forNumber(num: 4).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 4).top)
            keyboardView.layout(five)
                .left(Padding().numberPads.forNumber(num: 5).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 5).top)
            keyboardView.layout(six)
                .left(Padding().numberPads.forNumber(num: 6).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 6).top)
            keyboardView.layout(seven)
                .left(Padding().numberPads.forNumber(num: 7).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 7).top)
            keyboardView.layout(eight)
                .left(Padding().numberPads.forNumber(num: 8).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 8).top)
            keyboardView.layout(nine)
                .left(Padding().numberPads.forNumber(num: 9).left)
                .width(Padding.NumberPads.buttonWidth)
                .height(Padding.NumberPads.buttonHeight)
                .top(Padding().numberPads.forNumber(num: 9).top)
            keyboardView.layout(spaceButton)
                .left(Padding().spaceRegion.space.left)
                .width(Padding.SpaceRegion.spaceWidth)
                .top(Padding().spaceRegion.space.top)
                .height(Padding.SpaceRegion.globalDimentions.height)
            keyboardView.layout(nextKeyboardButton)
                .left(Padding().spaceRegion.global.left)
                .width(Padding.SpaceRegion.globalDimentions.width)
                .top(Padding().spaceRegion.global.top)
                .height(Padding.SpaceRegion.globalDimentions.height)
            keyboardView.layout(numberPadSwitcher)
                .left(Padding().spaceRegion.switchKey.left)
                .width(Padding.SpaceRegion.switchKeyDimentions.width)
                .top(Padding().spaceRegion.switchKey.top)
                .height(Padding.SpaceRegion.globalDimentions.height)
            keyboardView.layout(topRegion)
                .left(Padding().sidePanels.forRegions(reg: .top).left)
                .right()
                .top(Padding().sidePanels.forRegions(reg: .top).top)
                .height(Padding.SidePanels.topRegionHeight)
            keyboardView.layout(leftRegion)
                .left(Padding().sidePanels.forRegions(reg: .left).left)
                .width(Padding.SidePanels.leftRegionWidth)
                .top(Padding().sidePanels.forRegions(reg: .left).top)
                .bottom()
            keyboardView.layout(rightRegion)
                .left(Padding().sidePanels.forRegions(reg: .right).left)
                .right()
                .top(Padding().sidePanels.forRegions(reg: .right).top)
                .bottom()
            keyboardView.layout(extensionView)
                .left()
                .width(UIScreen.main.bounds.width)
                .top(Padding.SidePanels.topRegionHeight)
                .bottom()
            extensionView.isHidden = true
            motherViewsHaveConstrainted = true
            super.updateViewConstraints()
            updateViewConstraints()
        }
    }
    
    func loadInterface() {
        let calculatorNib = UINib(nibName: "NinekeyKeyboard", bundle: nil)
        keyboardView = calculatorNib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.addSubview(keyboardView)
        view.backgroundColor = keyboardView.backgroundColor
        
        // This will make the button call advanceToNextInputMode() when tapped
        nextKeyboardButton.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
        nextKeyboardButton.setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
    }
}

extension KeyboardViewController {
    ////////////////////////////////////////////
    //////////// CONTROL OF THE KEYS ///////////
    ////////////////////////////////////////////
    
    // When one of the 9 central keys is pressed, proceedNineKeyOperations is called.
    // If the mode is "numbers", it will call the regular keyscontrol.toggle 
    // function. This function will add the number to the text field.
    //
    // If the mode is "alphabets", it will call keyscontrol.t9Toggle. This 
    // function uses the t9Driver class to getSuggestions of words. Once that 
    // function returns, this function will iterate through that array and 
    //change the titles of the predict buttons on the keyboard to the suggestions.
    // TO DO: 0 doesn't work for some reason?
    @IBAction func proceedNineKeyOperations(_ operation: RoundButton){
        if(operation.mode == "numbers"){
            let proxy = textDocumentProxy as UITextDocumentProxy
            let input: String? = operation.currentTitle
            NSLog(String(describing: operation.currentTitle))
            NSLog(input!)
            
            if input != nil {
                proxy.insertText(input!)
            }
            return
        }
        
        // If shiftState is on, toggle off (should only stay on for one click).
        var shiftState = false
        if(operation.shiftMode == "on"){
            toggleShift(shift)
            shiftState = true
        }
        
        var suggestionsToRender = keyscontrol.t9Toggle(mode: operation.mode, tag: operation.tag, shiftState: shiftState)
        
        // Displays letters on key that was pressed
        showCurrentKeyMapping(operation)
        
        // For suggestions not returned, fill expanded suggestions array with empty strings.
        let max = 20
        if suggestionsToRender.count < max {
            for _ in 0..<max - suggestionsToRender.count {
                suggestionsToRender.append("")
            }
        }
        
        // Set suggestions (see "didSet" above)
        self.suggestions = suggestionsToRender
        
        // Fill in the 4 prediction buttons
        if suggestionsToRender[0] != "" {
            predict1.setTitle(suggestionsToRender[0], for: .normal)
            predict1.setTitleColor(Color.black, for: .normal)
            let proxy = textDocumentProxy as UITextDocumentProxy
            
            // Continually replace rendered text thus far with first suggestion.
            if(suggestionsToRender[0].length == keyscontrol.storedKeySequence.length){
                var num = keyscontrol.storedKeySequence.length
                var s = proxy.documentContextBeforeInput
                if(s?[(s?.length)!-1] != " "){
                    while(num > 1 && s?[(s?.length)!-1] != " "){
                        proxy.deleteBackward()
                        num -= 1
                        s = proxy.documentContextBeforeInput //re capture so we don't go over
                    }
                }
                proxy.insertText(suggestionsToRender[0])
            } else {
                //This case causes bugs - could be eliminated by having a weighting algorithm
                //guarantee there's always going to be a suggestion of that length...
                //Unless we should always just show what's first idk?

                //Temp solution: If the length of the first suggestion 
                // (which is what is going to render as user types)
                // is longer than what they've typed so far, truncate it.
                var num = keyscontrol.storedKeySequence.length
                var s = proxy.documentContextBeforeInput
                if(s?[(s?.length)!-1] != " "){
                    while(num > 1 && s?[(s?.length)!-1] != " " ){
                        proxy.deleteBackward()
                        num -= 1
                        s = proxy.documentContextBeforeInput //re capture so we don't go over
                    }
                }
                var shiftedWord = suggestionsToRender[0]
                var moreThan = suggestionsToRender[0].length - keyscontrol.storedKeySequence.length
                while(moreThan > 0 && shiftedWord.length > 0){
                    moreThan -= 1
                    shiftedWord.characters.removeLast()
                }
                proxy.insertText(shiftedWord)
            }
        }
        
        // Render remaining suggestions
        if suggestionsToRender[1] != "" {
            
            predict2.setTitle(suggestionsToRender[1], for: .normal)
            predict2.setTitleColor(Color.black, for: .normal)
        }
        if suggestionsToRender[2] != "" {
            predict3.setTitle(suggestionsToRender[2], for: .normal)
            predict3.setTitleColor(Color.black, for: .normal)
        }
        if suggestionsToRender[3] != "" {
            predict4.setTitle(suggestionsToRender[3], for: .normal)
            predict4.setTitleColor(Color.black, for: .normal)
        }
    }
    
    /// Show current pushed key's alphabet representations in top panel
    func showCurrentKeyMapping(_ operation: RoundButton) {
        var currentKeyMapping: [String] = []
        if let modeMapping = KeysMap.NineKeys.mapping["alphabets"] {
            if let mappingDict = modeMapping[String(operation.tag)] {
                currentKeyMapping = mappingDict
                if currentKeyMapping.count < 4 {
                    for i in 0...3 {
                        if !currentKeyMapping.indices.contains(i) {
                            currentKeyMapping.append("")
                        }
                    }
                }
                char1.setTitle(currentKeyMapping[0], for: .normal)
                char1.setTitleColor(Color.black, for: .normal)
                char2.setTitle(currentKeyMapping[1], for: .normal)
                char2.setTitleColor(Color.black, for: .normal)
                char3.setTitle(currentKeyMapping[2], for: .normal)
                char3.setTitleColor(Color.black, for: .normal)
                char4.setTitle(currentKeyMapping[3], for: .normal)
                char4.setTitleColor(Color.black, for: .normal)
            }
        }
    }

    /// When press backspace, show previous key mapping of whatever key was pressed
    func showPreviousKeyMapping() {
        if let previousLastChar = keyscontrol.storedKeySequence.characters.last {
            print("previousLastChar -> \(previousLastChar)")
            var currentKeyMapping: [String] = []
            if let modeMapping = KeysMap.NineKeys.mapping["alphabets"] {
                if let mappingDict = modeMapping[String(describing: previousLastChar)] {
                    currentKeyMapping = mappingDict
                    if currentKeyMapping.count < 4 {
                        for i in 0...3 {
                            if !currentKeyMapping.indices.contains(i) {
                                currentKeyMapping.append("")
                            }
                        }
                    }
                    char1.setTitle(currentKeyMapping[0], for: .normal)
                    char2.setTitle(currentKeyMapping[1], for: .normal)
                    char3.setTitle(currentKeyMapping[2], for: .normal)
                    char4.setTitle(currentKeyMapping[3], for: .normal)
                }
            }
        }else{
            char1.setTitle("", for: .normal)
            char2.setTitle("", for: .normal)
            char3.setTitle("", for: .normal)
            char4.setTitle("", for: .normal)
        }
    }
    
    /// When user specified accurate alphabet character in top panel
    @IBAction func didSelectCurrentChar(_ charButton: UIButton) {
        // OPTIONAL FILTERING OF SUGGESTION: MUST DECIDE WHAT METHOD WE WANT TO USE
        //if let title = charButton.currentTitle {
        //    suggestions = filterSuggestions(withCurrentChar: title)
        //}
        let proxy = textDocumentProxy as UITextDocumentProxy

        proxy.insertText(charButton.currentTitle!)
        // TODO: ^this causes bugs because of how text renders immediately, but
        // will be fixed eventually
    }
    

    // TODO: don't remember exactly what this is for right now...
    // Most of this is covered in inputSymbols - so maybe delete this function.
    @IBAction func punctuationKeys(_ operation: RoundButton){
        if(operation.mode == "numbers"){
            let proxy = textDocumentProxy as UITextDocumentProxy
            
            let input: String? = operation.currentTitle
            
            if input != nil {
                proxy.insertText(input!)
                return
            }
            return
        }
        
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        predict1.setTitle("@", for: .normal)
        predict1.setTitleColor(Color.black, for: .normal)
        predict2.setTitle("/", for: .normal)
        predict2.setTitleColor(Color.black, for: .normal)
        predict3.setTitle("!", for: .normal)
        predict3.setTitleColor(Color.black, for: .normal)
        predict4.setTitle(".", for: .normal)
        predict4.setTitleColor(Color.black, for: .normal)
        predict5.setTitle(",", for: .normal)
        predict5.setTitleColor(Color.black, for: .normal)
        predict6.setTitle(";", for: .normal)
        predict6.setTitleColor(Color.black, for: .normal)
        predict7.setTitle(":", for: .normal)
        predict7.setTitleColor(Color.black, for: .normal)
        predict8.setTitle("^", for: .normal)
        predict8.setTitleColor(Color.black, for: .normal)
        predict9.setTitle("(", for: .normal)
        predict9.setTitleColor(Color.black, for: .normal)
        predict10.setTitle(")", for: .normal)
        predict10.setTitleColor(Color.black, for: .normal)
        predict11.setTitle("'", for: .normal)
        predict11.setTitleColor(Color.black, for: .normal)
        predict12.setTitle("{", for: .normal)
        predict12.setTitleColor(Color.black, for: .normal)
        predict13.setTitle("}", for: .normal)
        predict13.setTitleColor(Color.black, for: .normal)
        predict14.setTitle("#", for: .normal)
        predict14.setTitleColor(Color.black, for: .normal)
        predict15.setTitle("*", for: .normal)
        predict15.setTitleColor(Color.black, for: .normal)
        predict16.setTitle("&", for: .normal)
        predict16.setTitleColor(Color.black, for: .normal)
        predict17.setTitle("%", for: .normal)
        predict17.setTitleColor(Color.black, for: .normal)
        predict18.setTitle("$", for: .normal)
        predict18.setTitleColor(Color.black, for: .normal)
        predict19.setTitle("~", for: .normal)
        predict19.setTitleColor(Color.black, for: .normal)
        predict20.setTitle("|", for: .normal)
        predict20.setTitleColor(Color.black, for: .normal)
    }
    
    // Weight word selected in algorithm, replace what's in field with selected word.
    @IBAction func predictionSelect(_ operation: RoundButton){
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        let input: String? = operation.currentTitle
        var s = proxy.documentContextBeforeInput
        
        if input != nil && predict1.currentTitle != "" && predict1.currentTitle != "@" {
            keyscontrol.wordSelected(word: input!) // update in trie
            var num = keyscontrol.storedKeySequence.length
            
            // Replace what's currently in text field of word being typed
            if(s?[(s?.length)!-1] != " "){
                while(num > 0 && s?[(s?.length)!-1] != " "){
                    proxy.deleteBackward()
                    num -= 1
                    s = proxy.documentContextBeforeInput //re capture so we don't go over
                }
            }
            proxy.insertText(input! + " ") // insert word
            
        } else {
            // Call inputSymbols
            if predict1.currentTitle == "@"{
                inputSymbols(operation)
            }
        }
        
        // Clear stored information in keys controller
        keyscontrol.clear()
        
        // Reset prediction button
        predict1.setTitle("", for: .normal)
        predict2.setTitle("", for: .normal)
        predict3.setTitle("", for: .normal)
        predict4.setTitle("", for: .normal)
    }
    
    // When space is pressed, the user effectively selects the first suggestion button's suggestion.
    // The input text field will then display that word (and a space), and the working keySequence
    // will be cleared. The function will also call t9Driver's updateWeights function with the correct
    // word and keySequence.
    @IBAction func spaceSelect(_ operation: RoundButton){
        // If it's in numbers mode, it should just render a "0".
        if (operation.mode == "numbers"){
            proceedNineKeyOperations(operation)
            return
        }
        
        let proxy = textDocumentProxy as UITextDocumentProxy
        if predict1.currentTitle != "" && predict1.currentTitle != "@" {
            keyscontrol.wordSelected(word: predict1.currentTitle!)
            // Calls predictionSelect to do most of the work.
            predictionSelect(predict1)
            keyscontrol.clear()
            predict1.setTitle("", for: .normal)
            predict2.setTitle("", for: .normal)
            predict3.setTitle("", for: .normal)
            predict4.setTitle("", for: .normal)
        } else if predict1.currentTitle == "@" {
            proxy.insertText("@")
        } else {
            proxy.insertText(" ")
        }
    }
    
    // below is fn declaration for manual entry mode
    //    @IBAction func proceedNineKeyOperations(_ operation: RoundButton) {
    //        display.text = keyscontrol.toggle(mode: operation.mode, tag: operation.tag)
    //    }
    
    
    // Called when user presses shift - TODO: VERY SLOW FOR SOME REASON
    @IBAction func toggleShift(_ toggleKey: RaisedButton) {
        toggleKey.switchColor()
        one.shift()
        two.shift()
        three.shift()
        four.shift()
        five.shift()
        six.shift()
        seven.shift()
        eight.shift()
        nine.shift()
    }
    
    // Number-Alphabet switcher
    @IBAction func toggleKeypad(_ toggleKey: UIButton) {
        one.switchMode()
        two.switchMode()
        three.switchMode()
        four.switchMode()
        five.switchMode()
        six.switchMode()
        seven.switchMode()
        eight.switchMode()
        nine.switchMode()
        spaceButton.switchMode()
        syms_1.setTitle("+", for: .normal)
        syms_1.setTitleColor(Color.black, for: .normal)
        syms_2.setTitle("-", for: .normal)
        syms_2.setTitleColor(Color.black, for: .normal)
        syms_3.setTitle("*", for: .normal)
        syms_3.setTitleColor(Color.black, for: .normal)
        predict1.setTitle("/", for: .normal)
        predict1.setTitleColor(Color.black, for: .normal)
        predict2.setTitle("%", for: .normal)
        predict2.setTitleColor(Color.black, for: .normal)
        predict3.setTitle("=", for: .normal)
        predict3.setTitleColor(Color.black, for: .normal)
        predict4.setTitle("^", for: .normal)
        predict4.setTitleColor(Color.black, for: .normal)

    }
    
    //Backspace in active textfield
    @IBAction func shouldDeleteText(/*_ backspaceKey: RaisedButton*/){
        // Pass textfield controller back to keyboard so keyboard can control active textfield in any apps
        (textDocumentProxy as UIKeyInput).deleteBackward()
    }
    
    //Dismiss keyboard
    @IBAction func shouldDismissKeyboard() {
        if extensionView.isHidden {
            extensionView.isHidden = false
        }else{
            extensionView.isHidden = true
        }
    }
    //Insert text in active textfield
    func shouldInsertText() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(input)
        }
        
        display.text = ""
        keyscontrol.clear()
    }
    
    // Backspace in display
    // This means that we now need to render suggestions one depth less. Thus, it calls
    // the keyscontrol.t9Backspace function. That function will get new suggestions which
    // will be returned here and rendered on the suggestion buttons.
    @IBAction func shouldDeleteTextInDisplay() {
        //        if (display?.text)! == "" && (predict1.currentTitle?.length)! <= 1 {
        //            keyscontrol.clear()
        //            predict1.setTitle("", for: .normal)
        //            predict2.setTitle("", for: .normal)
        //            predict3.setTitle("", for: .normal)
        //            predict4.setTitle("", for: .normal)
        //            return
        //        }
        
        let proxy = textDocumentProxy as UITextDocumentProxy
        if keyscontrol.storedKeySequence.length == 0 {
            if(proxy.hasText){
                shouldDeleteText()
            }
            return
        }
        
        shouldDeleteText()
        
        var suggestionsUpdate = [String]()
        suggestionsUpdate = keyscontrol.t9Backspace()
        
        // Reset predictions
        predict1.setTitle(suggestionsUpdate[0], for: .normal)
        predict1.setTitleColor(Color.black, for: .normal)
        predict2.setTitle(suggestionsUpdate[1], for: .normal)
        predict2.setTitleColor(Color.black, for: .normal)
        predict3.setTitle(suggestionsUpdate[2], for: .normal)
        predict3.setTitleColor(Color.black, for: .normal)
        predict4.setTitle(suggestionsUpdate[3], for: .normal)
        predict4.setTitleColor(Color.black, for: .normal)
        
        for i in 0...19 {
            if !suggestionsUpdate.indices.contains(i) {
                suggestionsUpdate.append("")
            }
        }
        suggestions = suggestionsUpdate
    }
    
    // TODO: NOT USED AS OF NOW, FIGURE OUT MANUAL MODE THINGS FIRST 
    // Filters suggestions by letter pressed.
    func filterSuggestions(withCurrentChar char: String) -> [String] {
        var filteredSuggestions = suggestions.filter { suggestion in
            print("String(describing: suggestion.lowercased().characters.last) -> \(String(describing: suggestion.lowercased().characters.last)) \r\n char -> \(char)")
            if let suggestionLastChar = suggestion.lowercased().characters.last {
                return String(describing: suggestionLastChar) == char
            }else{
                return false
            }
        }
        for i in 0...19 {
            if !filteredSuggestions.indices.contains(i) {
                filteredSuggestions.append("")
            }
        }
        return filteredSuggestions
    }

    // TODO: I DONT THINK THIS IS USED RIGHT NOW
    func shouldClearPreviousWordInTextField() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
    }
    
    //Insert symbols - TODO: probably can replace this by calling predictionSelect
    @IBAction func inputSymbols(_ sender: AnyObject) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        let input: String? = predict1.currentTitle
        var s = proxy.documentContextBeforeInput
        
        if input != nil && predict1.currentTitle != "" && predict1.currentTitle != "@" {
            keyscontrol.wordSelected(word: input!)
            var num = keyscontrol.storedKeySequence.length
            if(s?[(s?.length)!-1] != " "){
                while(num > 0 && s?[(s?.length)!-1] != " "){
                    proxy.deleteBackward()
                    num -= 1
                    s = proxy.documentContextBeforeInput //re capture so we don't go over
                }
            }
            proxy.insertText(input! + sender.currentTitle!!)
        }
        else if keyscontrol.storedKeySequence.length > 1 {
            NSLog(String(keyscontrol.storedKeySequence))
            //keyscontrol.storedKeySequence.characters.removeLast()
            var intKS = [Int]()
            for ch in keyscontrol.storedKeySequence.characters {
                intKS.append(Int(String(ch))!)
            }
            
            var word = keyscontrol.t9Communicator.getSuggestions(keySequence: intKS, shiftSequence: keyscontrol.storedBoolSequence)[0]
            keyscontrol.wordSelected(word: word)
            var num = keyscontrol.storedKeySequence.length
            if(s?[(s?.length)!-1] != " "){
                while(num > 0 && s?[(s?.length)!-1] != " "){
                    proxy.deleteBackward()
                    num -= 1
                    s = proxy.documentContextBeforeInput //re capture so we don't go over
                }
            }
            proxy.insertText(word + sender.currentTitle!!)
        } else {
            proxy.deleteBackward()
            proxy.insertText(sender.currentTitle!!) //prob don't want added space
            return
        }
        
        keyscontrol.clear()
        
        predict1.setTitle("", for: .normal)
        predict2.setTitle("", for: .normal)
        predict3.setTitle("", for: .normal)
        predict4.setTitle("", for: .normal)
    }
    
    //Send key
    @IBAction func returnKeyPressed() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(input + " ")
            keyscontrol.wordSelected(word: input)
            //NOTE: this will add a space by default, or else it gets complicated and confusing
            // update weights because a word has effectively been chosen
        }
        
        display.text = ""
        keyscontrol.clear()
    }
}

extension KeyboardViewController {
    //MARK:  Delegates
    //Control textfield behavior
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: UIControlState())
    }
}
