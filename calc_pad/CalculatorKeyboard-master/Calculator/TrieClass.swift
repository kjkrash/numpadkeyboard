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
    internal var children: [Int : TrieNode] // Digits map to TrieNodes
    internal var wordWeights: [WordWeight]  // Weights of each word in the node
    internal var leaf: Bool                 // True if this node is a leaf
    
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
    internal var minFreq: Int                   // stores min frequency of all words (for reduction, if necessary)
    internal var maxFreq: Int                   // stores max frequency of all words (for reduction, if necessary)
    internal var wordList: [String]             // stores all words (looped through to perform reduction, if necessary)
    internal var dictionaryFilename : String
    
    internal let dictURL: URL
    internal let dictPath: String
    let dictTitle: String
    let dictFileType: String
    internal let suggestionDepth: Int
    
    // A class that constructs a list of deeper suggestions
    internal class DeeperSuggestions {
        // How deep the Trie will be searched for longer words.
        // deeperSuggestions will have at most this many inner lists
        internal let suggestionDepth : Int
        
        // References a TrieNode in this Trie (classes are by ref)
        internal let prefixNode : TrieNode
        
        // Each inner list is a list of suggestions of the same length.
        // Every inner list is of a word length greater than the previous list.
        internal var deeperSuggestions = [[WordWeight]]()
        
        // The deeper suggestions will stored in their final form here.
        internal var suggestions: [String] = []
        
        // Upon initialization, DeeperSuggestions creates a list of suggestions
        // of words from 1 char longer than the key sequence to suggestionDepth
        // in length.
        // Input: suggestionDepth - the maximum length of chars longer (than the
        //                          key sequence) to search.
        //        prefixNode - the TrieNode from which to begin the deeper probe.
        init(_ suggestionDepth: Int, prefixNode: TrieNode!) {
            self.suggestionDepth = suggestionDepth
            self.prefixNode = prefixNode
            for _ in 0..<suggestionDepth {
                self.deeperSuggestions.append([])
            }
            
            self.setDeeperSuggestions()
        }
        
        // Returns the finalized deeper suggestions list.
        func get() -> [String] {
            return self.suggestions
        }
        
        // Adds deeper suggestions to deeperSuggestions, sorts them, and adds them
        // all to the final suggestions list.
        internal func setDeeperSuggestions() {
            self.traverse(self.prefixNode, currentDepth: 0)
            self.sort()
            self.flattenSuggestions()
        }
        
        // To be used only by setDeeperSuggestions(). Finds all deeperSuggestions
        // up to the depth limit.
        internal func traverse(_ currentNode: TrieNode, currentDepth: Int) {
            if (currentDepth > 0 && currentDepth < self.suggestionDepth) {
                for wordWeight in currentNode.wordWeights {
                    self.deeperSuggestions[currentDepth-1].append(wordWeight)
                }
            }
            
            if currentDepth == self.suggestionDepth || currentNode.children.count == 0 {
                return
            }
            
            for (key, _) in currentNode.children {
                self.traverse(currentNode.children[key]!, currentDepth: currentDepth + 1)
            }
        }
        
        // Sorts each level of deeperSuggestions in descending order of weight
        internal func sort() {
            for (level, suggestions) in self.deeperSuggestions.enumerated() {
                if suggestions.count > 0 {
                    // Sort the suggestions at this level in descending order
                    self.deeperSuggestions[level] =
                        suggestions.sorted(by: {$0.weight > $1.weight})
                }
            }
        }
        
        // Flattens deeperSuggestions lists into self.suggestions
        // Make sure to call self.sort() first
        internal func flattenSuggestions() {
            for suggestions in self.deeperSuggestions {
                for wordWeight in suggestions {
                    self.suggestions.append(wordWeight.word)
                }
            }
        }
    } // DeeperSuggestions
    
    init(dictionaryFilename : String, suggestionDepth: Int = SUGGESTION_DEPTH_DEFAULT) {
        self.root = TrieNode()
        self.minFreq = Int.max
        self.maxFreq = Int.min
        self.wordList = [String]()
        
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
        
        // loadTrie() does 2 things:
        // --
        // 1. loads trie into memory
        // 2. finds minimum/maximum frequencies for reducing (if necessary), and stores all words
        self.loadTrie()
        
        // reduce weights of words if we pass a specified threshold
//        if self.maxFreq > Int.max * (3/4) {
//            // this prevents overflows from occurring from long-term use
//            // reduces word weights by the lowest amount (needs changing if not using freq. weight scheme)
//            for i in 0..<wordList.count {
//                self.reduceWeight(word: wordList[i], weight: -1 * self.minFreq)
//            }
//            
//            // clear up memory usage
//            self.wordList = [String]()
//        } else {
//            // shouldn't be necessary, but resetting for safety
//            self.wordList = [String]()
//            self.minFreq = Int.max
//            self.maxFreq = Int.min
//        }
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
                
                // find the minimum/maximum weights of all words present in the file
                if weight! < self.minFreq {
                    self.minFreq = weight!
                }
                
                if weight! > self.maxFreq {
                    self.maxFreq = weight!
                }
                
                // store words for updates (if necessary)
                self.wordList.append(word)
            }
        } catch {
            print("Dictionary failed to load")
            return
        }
    }
    
    // reduces the frequencies in dictionary to prevent overflow
    // does not trigger unless the max count passes a certain threshold
    // if threshold is passed, then decrease all by the min count
    internal func reduceWeight(word: String, weight: Int) {
        _ = self.updateWeight(word: word, weight: weight)
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
                let deeperSuggestions = DeeperSuggestions(suggestionDepth, prefixNode: prefixNode).get()
                suggestions += deeperSuggestions
            }
        }
        
        return suggestions
    }
    
    internal func wordExists(_ word : String, keySequence: [Int]) -> Bool {
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
    func updateWeight(word: String, weight: Int) -> Int {
        var newWeight = -1
        NSLog("word: " + word)
        let keySequence = getKeySequence(word: word)
        let prefixNode = getPrefixLeaf(keySequence).0
        
        if wordExists(word, keySequence: keySequence) {
            for wordWeight in prefixNode!.wordWeights {
                if wordWeight.word == word {
                    newWeight = wordWeight.weight + weight
                    wordWeight.weight = newWeight
                    updateWeightInFile(word, weight: weight)
                    break
                }
            }
        }
        else {
            newWeight = WEIGHT_DEFAULT
            insert(word)
            insertWordInFile(word)
        }
        
        return newWeight
    }
    
    // Assumes presence of word in dictionary file. Thus, should only be called
    // after the word has been found in the Trie.
    internal func insertWordInFile(_ word: String) {
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
    }
    
    // FIXME: VERY inefficient.
    internal func updateWeightInFile(_ word: String, weight: Int) {
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
                        dictStrArr[i-1] = String(Int(dictStrArr[i-1])! + weight)
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
