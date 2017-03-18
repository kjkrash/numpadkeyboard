import Foundation

// Every word is associated with a mutable weight.
internal class WordWeight {
    let word: String
    var weight: Int
    init(word: String, weight: Int) {
        self.word = word
        self.weight = weight
    }
}

internal class TrieNode {
    
    // Digits map to TrieNodes
    var children: [Int : TrieNode]
    
    var wordWeights: [WordWeight]
    
    // True if this node is a leaf
    var leaf: Bool
    
    init() {
        self.children = [:]
        self.wordWeights = [WordWeight]()
        self.leaf = false
    }
    
    // checks if node is a leaf (end of word)
    func isLeaf() -> Bool {
        return self.leaf
    }
    
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
    let lettersToDigits = ["a" : 2, "b" : 2, "c" : 2,
                           "d" : 3, "e" : 3, "f" : 3,
                           "g" : 4, "h" : 4, "i" : 4,
                           "j" : 5, "k" : 5, "l" : 5,
                           "m" : 6, "n" : 6, "o" : 6,
                           "p" : 7, "q" : 7, "r" : 7, "s" : 7,
                           "t" : 8, "u" : 8, "v" : 8,
                           "w" : 9, "x" : 9, "y" : 9, "z" : 9]
    
    var root: TrieNode
    var dictionaryFilename : String
    var dictionarySize : Int
    let dictURL: URL
    let dictPath: String
    // e.g. "dict"
    let dictTitle: String
    // e.g. "txt
    let dictFileType: String
    
    // A work-around to allow deeperSuggestions to be passed by reference
    internal class DeeperSuggestion {
        var deeperSuggestions = [[WordWeight]]()
        
        init(suggestionDepth: Int) {
            for _ in 0..<suggestionDepth {
                self.deeperSuggestions.append([])
            }
        }
    }
    
    init(dictionaryFilename : String) {
        self.root = TrieNode()
        self.dictionaryFilename = dictionaryFilename
        self.dictionarySize = 0
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
    }
    
    func loadTrie() {
        do {
            let contents = try String(contentsOf: dictURL)
            // split contents by newline and put each line into a list
            let lines = contents.components(separatedBy: "\n")
            let size = lines.count
            for i in 0..<size {
                // increment dictionary size
                self.dictionarySize += 1
                
                // fetch weight and word from string array
                var lineArray = lines[i].components(separatedBy: "\t")
                if lines[i].characters.count < 1 {
                    break
                }
                let weight = Int(lineArray[0])
                let word = lineArray[1]
                
                // add into trie
                self.insert(word: word, weight: weight!)
            }
        } catch {
            print("Dictionary failed to load")
            return
        }
        
        
        
        /*
         
         NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MyFile" ofType:@"txt"];
         NSData *myData = [NSData dataWithContentsOfFile:filePath];
         if (myData) {
         // do something useful
         }
         
         // Do something with the test data...
         
         // Read in and store as raw data bytes
         NSString *file2 = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
         NSData *data = [NSData dataWithContentsOfFile:file2];
         
         let fileManager = FileManager.default
         
         // This string is the expected path of the dictionary file
         let dictionaryPath: String
         if fileManager.currentDirectoryPath == "/" {
         dictionaryPath = self.dictionaryFilename
         }
         else {
         dictionaryPath = fileManager.currentDirectoryPath + "/" +
         self.dictionaryFilename
         }
         
         // FIXME: Need better error management.
         if !fileManager.fileExists(atPath: dictionaryPath) {
         print("No dictionary named " + self.dictionaryFilename + " exists "
         + "at " + dictionaryPath + ".")
         print("Current directory is " + fileManager.currentDirectoryPath + ".")
         do {
         let contents = try fileManager.contentsOfDirectory(atPath: dictionaryPath)
         for c in contents {
         print(c)
         }
         } catch {
         print("Cannot print contents")
         }
         
         return
         }
         
         // Check if the file is readable
         if !fileManager.isReadableFile(atPath: dictionaryPath) {
         print("File named " + self.dictionaryFilename + " is not readable.")
         return
         }
         
         // get the file to read from
         let fileHandle: FileHandle? = FileHandle(forReadingAtPath:
         dictionaryPath)
         
         // if file exists and is readable then read from it
         if fileHandle == nil {
         print("File open failed.")
         return
         }
         
         else {
         // convert string pathname to url type
         let url = URL(fileURLWithPath: dictionaryPath)
         
         // fetch contents from the file
         let contents = try! String(contentsOf: url)
         
         // split contents by newline and put each line into a list
         let lines = contents.components(separatedBy: .newlines)
         
         for line in lines {
         // increment dictionary size
         self.dictionarySize += 1
         
         // fetch weight and word from string array
         var lineArray = line.components(separatedBy: "\t")
         if line.characters.count < 1 {
         break
         }
         let weight = Int(lineArray[0])
         let word = lineArray[1]
         
         // add into trie
         self.insert(word: word, weight: weight!)
         }
         }
         */
    }
    
    internal func insert(word : String, weight : Int) {
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
        node.wordWeights.append(WordWeight(word: word, weight: weight))
        
        // Sorts wordWeights by weights, biggest to smallest weight
        node.wordWeights = node.wordWeights.sorted(by: {$0.weight > $1.weight})
    }
    
    // Returns node where prefix ends.
    // If prefix not in Trie, node is nil and Bool is false.
    internal func getPrefixLeaf(keySequence : [Int]) -> (TrieNode?, Bool) {
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
    func getPrefixNode(keySequence : [Int]) -> TrieNode? {
        let (node, prefixExists) = self.getPrefixLeaf(keySequence: keySequence)
        if prefixExists {
            return node
        }
        else {
            return nil
        }
    }
    
    func getSuggestions(keySequence : [Int], suggestionDepth : Int) -> [String] {
        var suggestions = [String]()
        let prefixNode: TrieNode? = self.getPrefixNode(keySequence: keySequence)
        
        if prefixNode != nil {
            for wordWeight in prefixNode!.wordWeights {
                suggestions.append(wordWeight.word)
            }
            
            if suggestionDepth > 1 {
                var deeperSuggestions = DeeperSuggestion(suggestionDepth: suggestionDepth)
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
        let (node, _) = self.getPrefixLeaf(keySequence: keySequence)
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
        let prefixNode = getPrefixLeaf(keySequence: keySequence).0
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
            insert(word: word, weight: newWeight)
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
        self.dictionarySize += 1
        
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
