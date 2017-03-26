import Foundation

// Defining the weights used for words as Ints
typealias Weight = Int

// The constraints for the values of a key (the key for a TrieNode's children).
// 0 >= key <= 9
let KEY_MIN = 0
let KEY_MAX = 9
internal let WEIGHT_DEFAULT: Weight = 1
let SUGGESTION_DEPTH_DEFAULT = 3
let SUGGESTION_DEPTH_MAX = 10
let SUGGESTION_DEPTH_MIN = 0

// Every word is associated with a mutable weight.
internal class WordWeight {
    let word: String
    var weight: Weight
    
    init(_ word: String, weight: Weight) {
        self.word = word
        self.weight = weight
    }
    
    // Initializes word with default weight
    convenience init(_ word: String) {
        self.init(word, weight: WEIGHT_DEFAULT)
    }
    
    func update() {
        
    }
}

internal class TrieNode {
    
    // Digits map to TrieNodes
    internal var children: [Int : TrieNode]
    
    // weight of each word in the node
    internal var wordWeights: [WordWeight]
    
    // True if this node is a leaf
    var leaf: Bool
    
    init() {
        self.children = [:]
        self.wordWeights = [WordWeight]()
        self.leaf = false
    }
    
    // Output: True, is node is leaf.
    func isLeaf() -> Bool {
        return self.leaf
    }
    
    // Input: Key value for children
    // Output: Optional child TrieNode (nil, if does not exist)
    func getBranch(_ key: Int) -> TrieNode? {
        if keyIsValid(key) {
            return children[key]
        }
        return nil
    }
    
    // Input: Key value for children
    // Output: True if this node has a branch at this key. Else, false
    func hasChild(_ key: Int) -> Bool {
        return self.children[key] != nil
    }
    
    // Input: Key value where to insert, the TrieNode to add
    // Output: True, if succeeded. Else, false.
    // Adds a branch from this node to key
    func putNode(_ key: Int, nodeToInsert: TrieNode) -> Bool {
        if keyIsValid(key) {
            self.children[key] = nodeToInsert
            return true
        } else {
            return false
        }
    }
    
    // Sets node as leaf
    func setAsLeaf() {
        self.leaf = true
    }
    
    // Input: Key value to check if valid (within constraints and exists)
    // Output: True if valid
    internal func keyIsValid(_ key: Int) -> Bool {
        return key >= KEY_MIN && key <= KEY_MAX && children[key] != nil
    }
}

public class Trie {
    // root of the entire trie data structure
    internal var root: TrieNode
    
    // 1. lowest frequency of all words in the dictionary
    // 2. used for resetting frequencies to prevent overflow
    // 3. all frequencies will be reduced by minFreq - 1 to make sure words still
    //    exist in dictionary, but scales values down so no overflow occurs
    internal var minFreq: Int
    
    // TODO: still necessary given the next set of dict params??
    internal let dictionaryFilename : String
    
    // suggestion depth that will be used to search for words in the trie data structure
    internal let suggestionDepth: Int
    
    // Filepath to dictionary file
    internal let dictURL: URL
    internal let dictPath: String
    internal let dictTitle: String
    internal let dictFileType: String
    
    // The reverse mapping from letters to key numbers
    internal let lettersToDigits = ["a" : 2, "b" : 2, "c" : 2,
                                    "d" : 3, "e" : 3, "f" : 3,
                                    "g" : 4, "h" : 4, "i" : 4,
                                    "j" : 5, "k" : 5, "l" : 5,
                                    "m" : 6, "n" : 6, "o" : 6,
                                    "p" : 7, "q" : 7, "r" : 7, "s" : 7,
                                    "t" : 8, "u" : 8, "v" : 8,
                                    "w" : 9, "x" : 9, "y" : 9, "z" : 9]
    
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
                } else {
                    // If there are no suggestions at this level, delete this
                    // empty list.
                    self.deeperSuggestions.remove(at: level)
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
        // initialize default values
        self.root = TrieNode()
        self.minFreq = Int.max  // set to Int.max because we want to reduce as we see lesser values
                                // NOTE: this should never drop below 1
        self.dictionaryFilename = dictionaryFilename
        
        var dotIndex: Int?
        
        for (i, c) in self.dictionaryFilename.characters.enumerated() {
            if c == "." {
                dotIndex = i
                break
            }
        }
        
        assert((dotIndex != nil), "No file extension on \(dictionaryFilename)")
        
        self.dictTitle = self.dictionaryFilename.substring(to: dotIndex!)
        self.dictFileType = self.dictionaryFilename.substring(from: dotIndex! + 1)
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
        
        // 2 purposes:
        // ----------
        // 1. load the trie into memory
        // 2. find the minimum weight for preventing overflow
        self.loadTrie()
    }
    
    // Builds the Trie from the dictionary file
    internal func loadTrie() {
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
                
                // find the minimum weight of all words present in the file
                if weight! < self.minFreq {
                    self.minFreq = weight!
                }
            }
        } catch {
            print("Dictionary failed to load")
            return
        }
    }
    
    // Inserts words into the trie with a manually specified weight
    // Input: word - the string to add
    //        weight - the custom defined weight to associate with the word.
    //        Here, weight has a default value (nil). This way, insert can be
    //        called as insert(word). Use case: adding a new word from the user.
    //        The new word from the user is given the default starting weight,
    //        which is handled by the WordWeight class. Otherwise, the function
    //        is called as insert(word, weight: X). Use case: loading words from
    //        the dictionary (in which there are predefined weights).
    internal func insert(_ word : String, weight : Weight? = nil) {
        var node = self.root
        var key = 0
        
        for c in word.characters {
            key = lettersToDigits[String(c)]!
            if !node.hasChild(key) {
                _ = node.putNode(key, nodeToInsert: TrieNode())
            }
            node = node.getBranch(key)!
        }
        
        node.setAsLeaf()
        node.wordWeights.append(WordWeight(word, weight: weight!))
        
        // Sorts wordWeights by weights, biggest to smallest weight
        node.wordWeights = node.wordWeights.sorted(by: {$0.weight > $1.weight})
    }
    
    // Input:  the key sequence of the word.
    // Output: Returns node where prefix ends, i.e., where the word ought to be.
    //         If prefix not in Trie, node is nil and Bool is false.
    internal func getPrefixLeaf(_ keySequence : [Int]) -> (Node: TrieNode?, PrefixExists: Bool) {
        var node: TrieNode? = self.root
        var prefixExists = true
        
        for (i, key) in keySequence.enumerated() {
            if node!.hasChild(key) {
                node = node!.getBranch(key)
            } else {
                // At this point, we have reached a node that ends the path in
                // the Trie. If this key is the last in the keySequence, then
                // we know that the prefix <keySequence> exists.
                if i == keySequence.count - 1 {
                    prefixExists = true
                } else {
                    prefixExists = false
                    node = nil
                    return (node, prefixExists)
                }
            }
        }
        return (node!, prefixExists)
    }
    
    // Input:  the key sequence of the word.
    // Output: If the path keySequence exists, returns the node.
    //         Otherwise, nil
    internal func getPrefixNode(keySequence : [Int]) -> TrieNode? {
        let (node, prefixExists) = self.getPrefixLeaf(keySequence)
        
        if prefixExists {
            return node
        } else {
            return nil
        }
    }
    
    // Input: The key sequence of the word
    // Output: List of suggestions, including deeper suggestions if applicable.
    func getSuggestions(keySequence: [Int]) -> [String] {
        var suggestions = [String]()
        let prefixNode: TrieNode? = self.getPrefixNode(keySequence: keySequence)
        
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
    
    // Input: word - the string in question; keySequence - path of the word
    // Output: True is word exists. False otherwise
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
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // returns the updated weight
    // If word does not exist in Trie, it is added with base weight
    func updateWeight(word: String) -> Weight {
        var newWeight = -1
        let keySequence = getKeySequence(word: word)
        let prefixNode = getPrefixLeaf(keySequence).Node
        
        if wordExists(word, keySequence: keySequence) {
            for wordWeight in prefixNode!.wordWeights {
                if wordWeight.word == word {
                    newWeight = wordWeight.weight + 1
                    wordWeight.weight = newWeight
                    updateWeightInFile(word: word)
                    break
                }
            }
        } else {
            newWeight = WEIGHT_DEFAULT
            insert(word)
            insertWordInFile(word: word)
        }
        
        return newWeight
    }
    
    // Assumes presence of word in dictionary file. Thus, should only be called
    // after the word has been found in the Trie.
    // Input: word to insert into dictionary file
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
    }
    
    // FIXME: VERY inefficient.
    // Should only call after verifying word exists in Trie.
    // Input: the word to update in the file
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
