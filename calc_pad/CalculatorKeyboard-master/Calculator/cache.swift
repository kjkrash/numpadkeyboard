internal let CACHE_DEFAULT_SIZE_LIMIT = 25
internal let CACHE_MIN_SIZE = 10
internal let CACHE_MAX_SIZE = 100

//internal class CacheNode: TrieNode {
//    let parentNode: CacheNode?
//    init(parentNode: CacheNode?) {
//        self.parentNode = parentNode
//    }
//    override func getBranch(_ key: Int) -> CacheNode {
//        return self.children[key]! as! CacheNode
//    }
//}

// Very similar to TrieNode except the words are stored without weights (just strings)
// Reason: Cache should be small enough so that sorting through possible suggestions
// is unnecessary. The recall of the cache should come from its small size (relative to
// the main Trie).
internal class CacheNode {
    
    let parentNode: CacheNode?
    internal var children: [Int: CacheNode]
    internal var words: [String]
    var leaf: Bool
    
    init(parentNode: CacheNode?) {
        self.parentNode = parentNode
        self.children = [:]
        self.words = []
        self.leaf = false
    }
    
    // Output: True, is node is leaf.
    func isLeaf() -> Bool {
        return self.leaf
    }
    
    func getBranch(_ key: Int) -> CacheNode? {
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
    func putNode(_ key: Int, nodeToInsert: CacheNode) -> Bool {
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

// Very similar to Trie. However, the CacheTrie does not use weights (for reasons
// explained above the CacheNode class). Therefore, must keep CacheTrie compact.
// Pruning is used to get rid of branches that were used longest ago.
internal class CacheTrie {
    
    let root: CacheNode
    let suggestionDepth: Int
    
    // A class that constructs a list of deeper suggestions
    internal class DeeperSuggestions {
        // How deep the Trie will be searched for longer words.
        // deeperSuggestions will have at most this many inner lists
        internal let suggestionDepth : Int
        
        // References a TrieNode in this Trie (classes are by ref)
        internal let prefixNode : CacheNode
        
        // Each inner list is a list of suggestions of the same length.
        // Every inner list is of a word length greater than the previous list.
        internal var deeperSuggestions = [[String]]()
        
        // The deeper suggestions will stored in their final form here.
        internal var suggestions: [String] = []
        
        // Upon initialization, DeeperSuggestions creates a list of suggestions
        // of words from 1 char longer than the key sequence to suggestionDepth
        // in length.
        // Input: suggestionDepth - the maximum length of chars longer (than the
        //                          key sequence) to search.
        //        prefixNode - the TrieNode from which to begin the deeper probe.
        init(_ suggestionDepth: Int, prefixNode: CacheNode!) {
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
        internal func traverse(_ currentNode: CacheNode, currentDepth: Int) {
            if (currentDepth > 0 && currentDepth < self.suggestionDepth) {
                for word in currentNode.words {
                    self.deeperSuggestions[currentDepth-1].append(word)
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
                if suggestions.count == 0 {
                    self.deeperSuggestions.remove(at: level)
                }
            }
        }
        
        // Flattens deeperSuggestions lists into self.suggestions
        // Make sure to call self.sort() first
        internal func flattenSuggestions() {
            for suggestions in self.deeperSuggestions {
                for word in suggestions {
                    self.suggestions.append(word)
                }
            }
        }
    } // DeeperSuggestions
    
    init(suggestionDepth: Int = SUGGESTION_DEPTH_DEFAULT) {
        self.root = CacheNode(parentNode: nil)
        if suggestionDepth < SUGGESTION_DEPTH_MIN {
            self.suggestionDepth = SUGGESTION_DEPTH_MIN
            print("The suggestion depth is too low. Setting to \(SUGGESTION_DEPTH_MIN)...")
        } else if suggestionDepth > SUGGESTION_DEPTH_MAX {
            self.suggestionDepth = SUGGESTION_DEPTH_MAX
            print("The suggestion depth passed is too high. Setting to \(SUGGESTION_DEPTH_MAX)...")
        } else {
            self.suggestionDepth = suggestionDepth
        }
    }
    
    // Input: word to insert into the CacheTrie
    internal func insert(_ word: String) {
        var parentNode = CacheNode(parentNode: nil)
        var node = self.root
        var key = 0
        for c in word.characters {
            key = lettersToDigits[String(c)]!
            if !node.hasChild(key) {
                _ = node.putNode(key, nodeToInsert: CacheNode(parentNode: parentNode))
            }
            parentNode = node
            node = node.getBranch(key)!
        }
        node.setAsLeaf()
        node.words.append(word)
    }
    
    
    internal func getSuggestions(_ keySequence : [Int]) -> [String] {
        var suggestions = [String]()
        let prefixNode: CacheNode? = self.getPrefixNode(keySequence)
        
        if prefixNode != nil {
            for word in prefixNode!.words {
                suggestions.append(word)
            }
            
            if suggestionDepth > 1 {
                let deeperSuggestions = DeeperSuggestions(suggestionDepth, prefixNode: prefixNode).get()
                suggestions += deeperSuggestions
            }
        }
        
        return suggestions
    }
    
    internal func getPrefixLeaf(_ keySequence : [Int]) -> (CacheNode?, Bool) {
        var node: CacheNode? = self.root
        var prefixExists = true
        
        for (i, key) in keySequence.enumerated() {
            if node!.hasChild(key) {
                node = node!.getBranch(key)
            }
            else {
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
        return (node, prefixExists)
    }
    
    internal func getPrefixNode(_ keySequence : [Int]) -> CacheNode? {
        let (node, prefixExists) = self.getPrefixLeaf(keySequence)
        if prefixExists {
            return node
        }
        else {
            return nil
        }
    }
    
    internal func wordExists(_ word : String, keySequence: [Int]) -> Bool {
        let (node, _) = self.getPrefixLeaf(keySequence)
        if node != nil {
            if node!.isLeaf() {
                for w in node!.words {
                    if w == word {
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
}

public class Cache {
    internal let sizeLimit: Int
    internal var cacheTrie: CacheTrie
    
    // A list of the words in the cacheTrie. The first word is the most recently
    // used. The last word is the least recently used. If the cacheList goes over
    // the size limit, we find the oldest word in the trie and delete it (which
    // may cause the branch to prune).
    internal var cacheList: [String]
    
    init(sizeLimit: Int = CACHE_DEFAULT_SIZE_LIMIT, suggestionDepth: Int = SUGGESTION_DEPTH_DEFAULT) {
        
        if sizeLimit < CACHE_MIN_SIZE {
            self.sizeLimit = CACHE_MIN_SIZE
            print("The cache size limit is too low. Setting to \(CACHE_MIN_SIZE)...")
        } else if sizeLimit > CACHE_MAX_SIZE {
            self.sizeLimit = CACHE_MAX_SIZE
            print("The cache size limit is too damnn high. Setting to \(CACHE_MAX_SIZE)...")
        } else {
            self.sizeLimit = sizeLimit
        }
        
        self.cacheTrie = CacheTrie(suggestionDepth: suggestionDepth)
        self.cacheList = []
    }
    
    // Input: The key sequence to probe in the cache trie
    // Output: List of cached strings
    func getSuggestions(_ keySequence: [Int]) -> [String] {
        return self.cacheTrie.getSuggestions(keySequence)
    }
    
    // If the chosen word was in the cache,
    func update(chosenWord: String) {
        let keySequence = getKeySequence(word: chosenWord)
        
        var oldIndex = -1
        for (i, word) in cacheList.enumerated() {
            if word == chosenWord {
                oldIndex = i
                break
            }
        }
        // if chosenWord is in the cache, move it to front
        if oldIndex != -1 {
            let lastWord = self.cacheList[oldIndex]
            self.cacheList.remove(at: oldIndex)
            self.cacheList.insert(lastWord, at: 0)
        }
        else {
            self.insert(chosenWord)
        }
    }
    
    // Only call from update() so that we've already checked
    // to see if chosenWord is in the cache
    internal func insert(_ word: String) {
        // if @ capacity
        if self.cacheList.count == self.sizeLimit {
            self.pruneOldest()
        }
        // put most recent word at beginning
        if self.cacheList.count > 0 {
            self.cacheList[0] = word
        }
        self.cacheTrie.insert(word)
    }
    
    internal func pruneOldest() {
        self.pruneWord(wordToPrune: cacheList[cacheList.count - 1])
    }
    
    internal func pruneWord(wordToPrune: String) {
        let keySequnce = getKeySequence(word: wordToPrune)
        var nodeToPrune = self.cacheTrie.getPrefixNode(keySequnce)
        // If wordToPrune is a prefix with other children, just remove this one word from the word list of nodeToPrune
        if (nodeToPrune?.children.count)! > 0 {
            var wordIndex = 0
            for (i, w) in (nodeToPrune?.words.enumerated())! {
                if w == wordToPrune {
                    wordIndex = i
                }
            }
            nodeToPrune?.words.remove(at: wordIndex)
            return
        }
        else {
            while nodeToPrune?.parentNode?.children.count == 1 {
                nodeToPrune = nodeToPrune?.parentNode
            }
            nodeToPrune = nil
        }
    }
}
