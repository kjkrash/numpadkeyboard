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
    var lowerWord = word.lowercased()
    for char in lowerWord.characters {
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
    var keep: Bool
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
        keep = false
        t9Communicator = T9(dictionaryFilename: "dict.txt", resetFilename: "dict.txt", suggestionDepth: 8, numResults: 20, numCacheResults: 10, cacheSize: 50)
        super.init()
    }
    
    // This function calls the t9Driver to getSuggestions. It keeps a working string of the keySequence
    // thus far and adds the number most recently pressed.
    // IGNORE the NSLog statements (they're just for printing)
    func t9Toggle(mode: String, tag: Int, shiftState: Bool) -> [String] {
        var suggestions = [String]()
        numberJustPressed = String(tag)
		NSLog("Pressed\t\(numberJustPressed)")
		if t9Communicator.getSuggestionStatus() == SuggestionStatus.NONE {
			NSLog("Returning[]: Key Sequence\t\(storedKeySequence)")
			return []
		}
        storedKeySequence += numberJustPressed
        NSLog("Key Sequence\t\(storedKeySequence)")
        lastKeyControlTime = Date()
        storedBoolSequence.append(shiftState)
        
        NSLog(String(describing: storedBoolSequence))
        var intKS = [Int]()
        NSLog("num characters" + String(storedKeySequence.length))
        for ch in storedKeySequence.characters {
            intKS.append(Int(String(ch))!)
        }
        suggestions = t9Communicator.getSuggestions(keySequence: intKS, shiftSequence: storedBoolSequence)
        if t9Communicator.getSuggestionStatus() == SuggestionStatus.NONE {
            NSLog("Returning[] and removing last: Key Sequence\t\(storedKeySequence)")
            storedKeySequence.characters.removeLast()
            storedBoolSequence.removeLast()
            return []
        }
        NSLog("Number suggestions:\t\(suggestions.count)")
        return suggestions
    }
    
    // If the backspace is pressed, we need new suggestions of shorter depth.
    // This will remove the last sequence in the working storedKeySequence and also call
    // getSuggestions to get a new list.
    // NOTE: This gets messed up with number mode so it's something we need to fix.
    func t9Backspace() -> Array<String> {
        var suggestions = [String]()
        
        if storedKeySequence.characters.count > 0 {
            NSLog("Stored keyseq is: \(storedKeySequence)")
            NSLog("Num char in stored keyseq: \(String(storedKeySequence.characters.count))")
            NSLog("Stored boolseq is: \(storedBoolSequence)")
            NSLog("Num stored boolseq is: \(String(storedBoolSequence.count))")
            
            // remove last key in sequence
            storedKeySequence.characters.removeLast()
            lastKeyControlTime = Date()
            NSLog("keyseq after remove: \(storedKeySequence)")
            
            // remove shift marker for last key
            storedBoolSequence.removeLast()
            NSLog("boolseq after remove: \(storedBoolSequence)")
            
            var intKS = [Int]()
            
            for ch in storedKeySequence.characters {
                NSLog("reached 1")
                intKS.append(Int(String(ch))!)
                NSLog("reached 2")
            }
            
            NSLog("reached 3")
            t9Communicator.backspace()
            
            return t9Communicator.getSuggestions(keySequence: intKS, shiftSequence: storedBoolSequence)
        } else {
            //idk this doesn't work with number mode as of now
        }
        //NSLog("num keysequence == 0 so returning")
        return suggestions
    }
    
    func wordSelected(word: String){
		
		t9Communicator.rememberChoice(word: word.lowercased())
    }
    
    func toggle(mode: String, tag: Int, shiftMode: Bool) -> String {
        if tag == previousTag {
            if inputsDelay >= 0.8 {
                keep = shiftMode
                pointerAddress = 0
                previousTag = tag
                storedInputs = storedInputs + currentInput
                if shiftMode == true {
                    currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress].uppercased()
                } else {
                    currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
                }
                
                lastKeyControlTime = Date()
                if shiftMode == true {
                    return storedInputs + KeysMap.NineKeys.mapping[mode]![String(tag)]![0].uppercased()
                } else {
                    return storedInputs + KeysMap.NineKeys.mapping[mode]![String(tag)]![0]
                }
            }else{
                pointerAddress += 1
                if !(KeysMap.NineKeys.mapping[mode]?[String(tag)]?.indices.contains(pointerAddress))! {
                    pointerAddress = 0
                }
    
                if keep == true {
                    currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress].uppercased()
                } else {
                    currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
                }

                lastKeyControlTime = Date()
                return storedInputs + currentInput
            }
        }else{
            keep = shiftMode
            pointerAddress = 0
            previousTag = tag
            storedInputs = storedInputs + currentInput
            if shiftMode == true {
                currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress].uppercased()
            } else {
                currentInput = KeysMap.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
            }
            lastKeyControlTime = Date()
            if shiftMode == true {
                return storedInputs + KeysMap.NineKeys.mapping[mode]![String(tag)]![0].uppercased()
            } else {
                return storedInputs + KeysMap.NineKeys.mapping[mode]![String(tag)]![0]
            }
        }
    }
    
    
    func backspace() -> String {
        if storedInputs.characters.count > 0 && currentInput != "" {
            NSLog("sI.c.count > 0 and currI isn't empty\nstored inputs: " + storedInputs)
            currentInput = ""
            pointerAddress = 0
            previousTag = -1
            lastKeyControlTime = Date()
            return storedInputs
        } else if storedInputs.characters.count > 0 {
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
        storedBoolSequence = [Bool]()
        pointerAddress = 0
        previousTag = -1
        lastKeyControlTime = Date()
    }
}
