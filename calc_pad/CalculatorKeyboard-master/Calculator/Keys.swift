import Foundation

// The reverse mapping from letters to key numbers
let lettersToDigits = ["a" : 2, "b" : 2, "c" : 2,
                       "d" : 3, "e" : 3, "f" : 3,
                       "g" : 4, "h" : 4, "i" : 4,
                       "j" : 5, "k" : 5, "l" : 5,
                       "m" : 6, "n" : 6, "o" : 6,
                       "p" : 7, "q" : 7, "r" : 7, "s" : 7,
                       "t" : 8, "u" : 8, "v" : 8,
                       "w" : 9, "x" : 9, "y" : 9, "z" : 9]

func getKeySequence(word: String) -> [Int] {
    var keySequence = [Int]()
    for char in word.characters {
        assert(lettersToDigits[String(char)] != nil )
        keySequence.append(lettersToDigits[String(char)]!)
    }
    return keySequence
}

//Information stored for each key
struct KeysMap {
    struct NineKeys {
        static let mapping = [
            "alphabets": [
                "1":["@","/","."],
                "2":["a","b","c"],
                "3":["d","e","f"],
                "4":["g","h","i"],
                "5":["j","k","l"],
                "6":["m","n","o"],
                "7":["p","q","r","s"],
                "8":["t","u","v"],
                "9":["w","x","y","z"],
                "10":[" "]
            ],
            "numbers": [
                "1":["1"],
                "2":["2"],
                "3":["3"],
                "4":["4"],
                "5":["5"],
                "6":["6"],
                "7":["7"],
                "8":["8"],
                "9":["9"],
                "10":["0"]
            ]
        ]
    }
}

//Control how 9 keys will input, {CONTROL DATA}
class KeysControl: NSObject {
    var pointerAddress = 0
    var previousTag = -1
    var currentInput = ""
    var storedInputs: String
    var lastKeyControlTime: Date
    var t9Communicator: T9
    var storedKeySequence: String
    var storedBoolSequence: [Bool]
    var numberJustPressed: String
    var inputsDelay: TimeInterval {
        get{
            return Date().timeIntervalSince(lastKeyControlTime)
        }
    }
    override init() {
        lastKeyControlTime = Date()
        storedInputs = ""
        storedKeySequence = ""
        storedBoolSequence = [Bool]()
        numberJustPressed = ""
        t9Communicator = T9(dictionaryFilename: "dict.txt", resetFilename: "dict.txt", suggestionDepth: 4, numResults: 4, numCacheResults: 0, cacheSize: 0)
        super.init()
    }
    
    // This function calls the t9Driver to getSuggestions. It keeps a working string of the keySequence
    // thus far and adds the number most recently pressed.
    // IGNORE the NSLog statements (they're just for printing)
    func t9Toggle(mode: String, tag: Int, shiftState: Bool) -> Array<String> {
        var suggestions = [String]()
        numberJustPressed = String(tag)
        print(numberJustPressed)
        NSLog(numberJustPressed)
        storedKeySequence += numberJustPressed
        NSLog(storedKeySequence)
        lastKeyControlTime = Date()
        storedBoolSequence.append(shiftState)
        var intKS = [Int]()
        for ch in storedKeySequence.characters {
            intKS.append(Int(String(ch))!)
        }
        suggestions = t9Communicator.getSuggestions(keySequence: intKS, shiftSequence: storedBoolSequence)
        NSLog("Suggestions size in Keys.swift is: ")
        NSLog(String(suggestions.count))
        return suggestions
    }
    
    // If the backspace is pressed, we need new suggestions of shorter depth.
    // This will remove the last sequence in the working storedKeySequence and also call
    // getSuggestions to get a new list.
    // NOTE: This gets messed up with number mode so it's something we need to fix.
    func t9Backspace() -> Array<String> {
        var suggestions = [String]()
        if storedKeySequence.characters.count > 0 {
            NSLog(storedKeySequence)
            storedKeySequence.characters.removeLast()
            lastKeyControlTime = Date()
            NSLog(storedKeySequence)
            storedBoolSequence.removeLast()
            var intKS = [Int]()
            for ch in storedKeySequence.characters {
                intKS.append(Int(String(ch))!)
            }
            return t9Communicator.getSuggestions(keySequence: intKS, shiftSequence: storedBoolSequence)
        } else {
            //idk this doesn't work with number mode as of now
        }
        //NSLog("num keysequence == 0 so returning")
        return suggestions
    }
    
    func wordSelected(word: String){
        t9Communicator.rememberChoice(word: word)
    }
    
    func toggle(mode: String, tag: Int) -> String {
        //        if tag == previousTag {
        //            if inputsDelay >= 0.8 {
        //                pointerAddress = 0
        //                previousTag = tag
        //                storedInputs = storedInputs + currentInput
        //                currentInput = Keys.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
        //                lastKeyControlTime = Date()
        //                return storedInputs + Keys.NineKeys.mapping[mode]![String(tag)]![0]
        //            }else{
        //                pointerAddress += 1
        //                if !(Keys.NineKeys.mapping[mode]?[String(tag)]?.indices.contains(pointerAddress))! {
        //                    pointerAddress = 0
        //                }
        //                currentInput = Keys.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
        //                lastKeyControlTime = Date()
        //                return storedInputs + currentInput
        //            }
        //        }else{
        pointerAddress = 0
        previousTag = tag
        storedInputs = storedInputs + currentInput
        currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
        lastKeyControlTime = Date()
        return storedInputs + KeysMap.NineKeys.mapping[mode]![String(tag)]![0]
        //}
    }
    
    
    func backspace() -> String {
        if storedInputs.characters.count > 0 {
            storedInputs.characters.removeLast()
            currentInput = ""
            pointerAddress = 0
            previousTag = -1
            lastKeyControlTime = Date()
            return storedInputs
        }
        return ""
    }
    func removeLastWord() {
        if let lastWordRange = storedInputs.range(of: " ") {
            currentInput = ""
            storedInputs.removeSubrange(lastWordRange.lowerBound..<storedInputs.endIndex)
            pointerAddress = 0
            previousTag = -1
            lastKeyControlTime = Date()
        }else{
            clear()
        }
    }
    func clear() {
        currentInput = ""
        storedInputs = ""
        storedKeySequence = ""
        pointerAddress = 0
        previousTag = -1
        lastKeyControlTime = Date()
    }
}
