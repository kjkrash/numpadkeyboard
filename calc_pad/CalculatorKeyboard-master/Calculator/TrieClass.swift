import Foundation

typealias Weight = Int

internal let WEIGHT_DEFAULT: Weight = 1

let SUGGESTION_DEPTH_DEFAULT = 3
let SUGGESTION_DEPTH_MAX = 10
let SUGGESTION_DEPTH_MIN = 0

// Every word is associated with a mutable weight.
internal class WordWeight {
    internal let word: String
    internal var weight: Weight
    
    // If weight is not specified, it is given the default value.
    // Convenient for inserting novel words from the user.
    init(_ word: String, weight: Weight = WEIGHT_DEFAULT) {
        self.word = word
        self.weight = weight
    }
    
    func weightUp() {
        self.weight += 1
    }
}

internal class TrieNode {
    
    // Digits map to TrieNodes
    internal var children: [Int : TrieNode]
    
    internal var wordWeights: [WordWeight]
    
    // True if this node is a leaf
    internal var leaf: Bool
    
    init() {
        self.children = [:]
        self.wordWeights = [WordWeight]()
        self.leaf = false
    }
    
    func addWordWeight(_ word: String, weight: Weight = WEIGHT_DEFAULT) {
        wordWeights.append(WordWeight(word, weight: weight))
        wordWeights = wordWeights.sorted(by: {$0.weight > $1.weight})
    }
    
    // checks if node is a leaf (end of word)
    func isLeaf() -> Bool {
        return self.leaf
    }
    
    // Does NOT check if child exists. ONLY call after hasChild()
    // gets the next node based on key
    func getBranch(key: Int) -> TrieNode {
        return self.children[key]!
    }
    
    // True if this node has a branch at this key
    func hasChild(key: Int) -> Bool {
        return self.children[key] != nil
    }
    
    // Adds a branch from this node to key
    func putNode(key: Int, nodeToInsert : TrieNode) {
        self.children[key] = nodeToInsert
    }
    
    // makes node a leaf
    func setAsLeaf() {
        self.leaf = true
    }
}

public class Trie {
    
    // The reverse mapping from letters to key numbers
    internal let lettersToDigits = ["a" : 2, "b" : 2, "c" : 2,
                                    "d" : 3, "e" : 3, "f" : 3,
                                    "g" : 4, "h" : 4, "i" : 4,
                                    "j" : 5, "k" : 5, "l" : 5,
                                    "m" : 6, "n" : 6, "o" : 6,
                                    "p" : 7, "q" : 7, "r" : 7, "s" : 7,
                                    "t" : 8, "u" : 8, "v" : 8,
                                    "w" : 9, "x" : 9, "y" : 9, "z" : 9]
    
    internal var root: TrieNode
    internal var dictionaryFilename : String
    internal let dictURL: URL
    internal let dictPath: String
    let dictTitle: String
    let dictFileType: String
    internal let suggestionDepth: Int
    
    // A work-around to allow deeperSuggestions to be passed by reference
    internal class DeeperSuggestion {
        var deeperSuggestions = [[WordWeight]]()
        
        init(suggestionDepth: Int) {
            for _ in 0..<suggestionDepth {
                self.deeperSuggestions.append([])
            }
        }
    }
    
    init(dictionaryFilename : String, suggestionDepth: Int = SUGGESTION_DEPTH_DEFAULT) {
        self.root = TrieNode()
        
        // Process filename
        self.dictionaryFilename = dictionaryFilename
        var dotIndex = -1
        for (i, c) in self.dictionaryFilename.characters.enumerated() {
            if c == "." {
                dotIndex = i
                break
            }
        }
        if dotIndex == -1 {
            print("Invalid dictionary name: " + self.dictionaryFilename)
        }
        self.dictTitle = self.dictionaryFilename.substring(to: dotIndex)
        self.dictFileType = self.dictionaryFilename.substring(from: dotIndex + 1)
        self.dictPath = Bundle.main.path(forResource: self.dictTitle, ofType: self.dictFileType)!
        self.dictURL = URL(fileURLWithPath: self.dictPath)
        
        if suggestionDepth < SUGGESTION_DEPTH_MIN {
            self.suggestionDepth = SUGGESTION_DEPTH_MIN
            print("The suggestion depth is too low. Setting to \(SUGGESTION_DEPTH_MIN)...")
        } else if suggestionDepth > SUGGESTION_DEPTH_MAX {
            self.suggestionDepth = SUGGESTION_DEPTH_MAX
            print("The suggestion depth passed is too high. Setting to \(SUGGESTION_DEPTH_MAX)...")
        } else {
            self.suggestionDepth = suggestionDepth
        }
        
        self.loadTrie()
    }
    
    func loadTrie() {
        do {
            let contents = try String(contentsOf: dictURL)
            // split contents by newline and put each line into a list
            let lines = contents.components(separatedBy: "\n")
            let size = lines.count
            for i in 0..<size {

                
                // fetch weight and word from string array
                var lineArray = lines[i].components(separatedBy: "\t")
                if lines[i].characters.count < 1 {
                    break
                }
                let weight = Weight(lineArray[0])
                let word = lineArray[1]
                
                // add into trie
                self.insert(word, weight: weight!)
            }
        } catch {
            print("Dictionary failed to load")
            return
        }
    }
    
    internal func insert(_ word: String, weight: Int = WEIGHT_DEFAULT) {
        var node = self.root
        var key = 0
        for c in word.characters {
            key = lettersToDigits[String(c)]!
            if !node.hasChild(key: key) {
                node.putNode(key: key, nodeToInsert: TrieNode())
            }
            node = node.getBranch(key: key)
        }
        node.setAsLeaf()
        node.addWordWeight(word, weight: weight)
    }
    
    // Returns node where prefix ends.
    // If prefix not in Trie, node is nil and Bool is false.
    internal func getPrefixLeaf(_ keySequence : [Int]) -> (TrieNode?, Bool) {
        var node: TrieNode? = self.root
        var prefixExists = true
        
        for (i, key) in keySequence.enumerated() {
            if node!.hasChild(key: key) {
                node = node!.getBranch(key: key)
            }
            else {
                // At this point, we have reached a node that ends the path in
                // the Trie. If this key is the last in the keySequence, then
                // we know that the prefix <keySequence> exists.
                if i == keySequence.count - 1 {
                    prefixExists = true
                }
                else {
                    prefixExists = false
                    node = nil
                    return (node, prefixExists)
                }
            }
        }
        return (node!, prefixExists)
    }
    
    // If the path keySequence exists, returns the node.
    // Otherwise, nil
    internal func getPrefixNode(_ keySequence : [Int]) -> TrieNode? {
        let (node, prefixExists) = self.getPrefixLeaf(keySequence)
        if prefixExists {
            return node
        }
        else {
            return nil
        }
    }
    
    func getSuggestions(keySequence : [Int]) -> [String] {
        var suggestions = [String]()
        let prefixNode: TrieNode? = self.getPrefixNode(keySequence)
        
        if prefixNode != nil {
            for wordWeight in prefixNode!.wordWeights {
                suggestions.append(wordWeight.word)
            }
            
            if suggestionDepth > 1 {
                let deeperSuggestions = DeeperSuggestion(suggestionDepth: suggestionDepth)
                // deeperSuggestions is a classs, so it is passed by reference
                // After the call to getDeeperSuggestions, deeperSuggestions
                // will be a list of lists of words, each list being full of
                // words of one character longer in length
                self.getDeeperSuggestions(root: prefixNode!,
                                          maxDepth:
                    suggestionDepth,
                                          deeperSuggestions: deeperSuggestions)
                
                for level in deeperSuggestions.deeperSuggestions {
                    for wordWeight in level {
                        suggestions.append(wordWeight.word)
                    }
                }
            }
        }
        
        return suggestions
    }
    
    internal func getDeeperSuggestions(root : TrieNode, maxDepth : Int,
                                       deeperSuggestions: DeeperSuggestion) {
        self.traverse(root: root, depth: 0, maxDepth: maxDepth, deepSuggestions: deeperSuggestions)
        for (level, suggestions) in deeperSuggestions.deeperSuggestions.enumerated() {
            if suggestions.count > 0 {
                deeperSuggestions.deeperSuggestions[level] =
                    suggestions.sorted(by: {$0.weight > $1.weight})
            }
        }
    }
    
    internal func traverse(root : TrieNode, depth : Int, maxDepth : Int,
                           deepSuggestions : DeeperSuggestion) {
        if (depth < maxDepth && depth > 0) {
            for wordWeight in root.wordWeights {
                deepSuggestions.deeperSuggestions[depth-1].append(wordWeight)
            }
        }
        
        if depth == maxDepth || root.children.count == 0 {
            return
        }
        
        for (key, _) in root.children {
            self.traverse(root: root.children[key]!, depth: depth+1,
                          maxDepth: maxDepth, deepSuggestions: deepSuggestions)
        }
    }
    
    internal func wordExists(word : String, keySequence: [Int]) -> Bool {
        let (node, _) = self.getPrefixLeaf(keySequence)
        if node != nil {
            if node!.isLeaf() {
                for wordWeight in node!.wordWeights {
                    if wordWeight.word == word {
                        return true
                    }
                }
                return false
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    // returns the updated weight
    // If word does not exist in Trie, it is added with base weight
    func updateWeight(word: String) -> Int {
        var newWeight = -1
        let keySequence = getKeySequence(word: word)
        let prefixNode = getPrefixLeaf(keySequence).0
        if wordExists(word: word, keySequence: keySequence) {
            for wordWeight in prefixNode!.wordWeights {
                if wordWeight.word == word {
                    newWeight = wordWeight.weight + 1
                    wordWeight.weight = newWeight
                    updateWeightInFile(word: word)
                    break
                }
            }
        }
        else {
            newWeight = 1
            insert(word, weight: newWeight)
            insertWordInFile(word: word)
        }
        return newWeight
    }
    
    // Assumes presence of word in dictionary file. Thus, should only be called
    // after the word has been found in the Trie.
    internal func insertWordInFile(word: String) {
        do {
            //let data = try Data(contentsOf: self.dictURL)
            let fileHandle = try FileHandle(forUpdating: self.dictURL)
            let data = ("1" + "\t" + word as String).data(using: String.Encoding.utf8)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data!)
            fileHandle.closeFile()
        } catch {
            print("ERROR from insertWordInFile")
            return
        }

        
        /*
         self.dictionarySize += 1
         
         let fileManager = FileManager.default
         
         // get path to dictionary for inserting new word
         let dictionaryPath: String
         if fileManager.currentDirectoryPath == "/" {
         dictionaryPath = self.dictionaryFilename
         }
         else {
         dictionaryPath = fileManager.currentDirectoryPath + "/" +
         self.dictionaryFilename
         }
         
         
         // check if the file is writable
         if fileManager.isWritableFile(atPath: dictionaryPath) {
         let fileHandle: FileHandle? =
         FileHandle(forUpdatingAtPath: dictionaryPath)
         
         if fileHandle == nil {
         print("file could not be opened")
         }
         else {
         // data will just be the word and frequency of 1 since it is a new word
         let data = ("1" + "\t" + word as String).data(using: String.Encoding.utf8)
         
         // since this is a new word, we want to find the EOF and append the word/freq pair there
         fileHandle?.seekToEndOfFile()
         
         // write the data to the file and close file after operation is complete
         fileHandle?.write(data!)
         fileHandle?.closeFile()
         }
         }*/
    }
    
    // FIXME: VERY inefficient.
    internal func updateWeightInFile(word: String) {
        let urlOfDict = URL(fileURLWithPath: self.dictionaryFilename)
        do {
            let dictStr = try
                String(contentsOf: urlOfDict, encoding: String.Encoding.utf8)
            let separators = CharacterSet(charactersIn: "\t\n")
            var dictStrArr = dictStr.components(separatedBy: separators)
            var updatedDictStr = ""
            var wordFound = false
            for i in stride(from: 1, to:dictStrArr.count, by: 2) {
                if !wordFound {
                    if dictStrArr[i] == word {
                        // Add one to weight
                        dictStrArr[i-1] = String(Int(dictStrArr[i-1])! + 1)
                        wordFound = true
                    }
                }
                updatedDictStr += dictStrArr[i-1] + "\t" + dictStrArr[i] + "\n"
            }
            try updatedDictStr.write(to: urlOfDict, atomically: false,
                                     encoding: String.Encoding.utf8)
        }
        catch {
            print("fail")
        }
    }
}
