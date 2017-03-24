import Foundation
import UIKit

// Customized button
class RaisedButton: UIButton {
    var shiftM:String = "off"
    func switchColor(){
        switch shiftM {
        case "off":
            setBackgroundColor(color: UIColor.black, forState: .normal)
            setTitle("⇪", for:.normal)
            shiftM = "on"
        case "on":
            setBackgroundColor(color: UIColor.blue, forState: .normal)
            setTitle("⇧", for:.normal)
            shiftM = "off"
        default:
            break
        }
    }
}

class RoundButton: UIButton {
    @IBInspectable var _cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = _cornerRadius
        }
    }
    
    @IBInspectable var _borderColor: UIColor = UIColor.darkGray {
        didSet {
            layer.borderWidth = 1.0
            layer.masksToBounds = true
            layer.borderColor = _borderColor.cgColor
        }
    }
    var mode:String = "alphabets"
    func switchMode() {
        switch mode {
        case "alphabets":
            if tag == 10 {
                setTitle("0", for: .normal)
            }else{
                setTitle(String(tag), for: .normal)
            }
            mode = "numbers"
        case "numbers":
            switch tag {
            case 1:
                setTitle("@/.", for: .normal)
            case 2:
                setTitle("abc", for: .normal)
            case 3:
                setTitle("def", for: .normal)
            case 4:
                setTitle("ghi", for: .normal)
            case 5:
                setTitle("jkl", for: .normal)
            case 6:
                setTitle("mno", for: .normal)
            case 7:
                setTitle("pqrs", for: .normal)
            case 8:
                setTitle("tuv", for: .normal)
            case 9:
                setTitle("wxyz", for: .normal)
            case 10:
                setTitle("", for: .normal)
            default:
                break
            }
            mode = "alphabets"
        default:
            break
        }
    }
    
    var shiftMode:String = "off"
    func shift() {
        switch shiftMode {
        case "off":
            switch tag {
            case 1:
                setTitle("!@/", for: .normal)
            case 2:
                setTitle("ABC", for: .normal)
            case 3:
                setTitle("DEF", for: .normal)
            case 4:
                setTitle("GHI", for: .normal)
            case 5:
                setTitle("JKL", for: .normal)
            case 6:
                setTitle("MNO", for: .normal)
            case 7:
                setTitle("PQRS", for: .normal)
            case 8:
                setTitle("TUV", for: .normal)
            case 9:
                setTitle("WXYZ", for: .normal)
            default:
                break
            }
            shiftMode = "on"
        case "on":
            switch tag {
            case 1:
                setTitle("!@/", for: .normal)
            case 2:
                setTitle("abc", for: .normal)
            case 3:
                setTitle("def", for: .normal)
            case 4:
                setTitle("ghi", for: .normal)
            case 5:
                setTitle("jkl", for: .normal)
            case 6:
                setTitle("mno", for: .normal)
            case 7:
                setTitle("pqrs", for: .normal)
            case 8:
                setTitle("tuv", for: .normal)
            case 9:
                setTitle("wxyz", for: .normal)
            default:
                break
            }
            shiftMode = "off"
        default:
            break
        }
    }
    
    
    func renderSuggestions(sugg: String){
        setTitle(sugg, for: .normal)
    }
}

//Custom label
class RoundLabel: UILabel {
    @IBInspectable var _cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = _cornerRadius
        }
    }
}
