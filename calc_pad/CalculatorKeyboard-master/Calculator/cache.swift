internal class CacheNode: TrieNode {
    let parentNode: CacheNode?
    init(parentNode: CacheNode?) {
        self.parentNode = parentNode
    }
    override func getBranch(key: Int) -> CacheNode {
        return self.children[key]! as! CacheNode
    }
}

internal class CacheTrie {
    
    let root: CacheNode
    
    internal class DeeperSuggestion {
        var deeperSuggestions = [[WordWeight]]()
        
        init(suggestionDepth: Int) {
            for _ in 0..<suggestionDepth {
                self.deeperSuggestions.append([])
            }
        }
    }
    
    init() {
        self.root = CacheNode(parentNode: nil)
    }
    
    internal func insert(word: String, weight: Int) {
        var parentNode = CacheNode(parentNode: nil)
        var node = self.root
        var key = 0
        for c in word.characters {
            key = lettersToDigits[String(c)]!
            if !node.hasChild(key: key) {
                node.putNode(key: key, nodeToInsert: CacheNode(parentNode: parentNode))
            }
            parentNode = node
            node = node.getBranch(key: key)
        }
        node.setAsLeaf()
        node.wordWeights.append(WordWeight(word: word, weight: weight))
        node.wordWeights = node.wordWeights.sorted(by: {$0.weight > $1.weight})
    }
    
    internal func getSuggestions(keySequence : [Int], suggestionDepth : Int) -> [String] {
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
    
    internal func getPrefixLeaf(keySequence : [Int]) -> (CacheNode?, Bool) {
        var node: CacheNode? = self.root
        var prefixExists = true
        
        for (i, key) in keySequence.enumerated() {
            if node!.hasChild(key: key) {
                node = node!.getBranch(key: key)
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
    
    internal func getPrefixNode(keySequence : [Int]) -> CacheNode? {
        let (node, prefixExists) = self.getPrefixLeaf(keySequence: keySequence)
        if prefixExists {
            return node
        }
        else {
            return nil
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
}

public class Cache {
    let sizeLimit: Int
    var cacheList: [String]
    var cacheTrie = CacheTrie()
    init(sizeLimit: Int) {
        self.sizeLimit = sizeLimit
        self.cacheList = []
    }
    
    func getSuggestions(keySequence: [Int], suggestionDepth: Int) -> [String] {
        return self.cacheTrie.getSuggestions(keySequence: keySequence,
                                             suggestionDepth: suggestionDepth)
    }
    
    func update(chosenWord: String, weight: Int, keySequence: [Int]) {
        var oldIndex = -1
        for (i, word) in cacheList.enumerated() {
            if word == chosenWord {
                oldIndex = i
                break
            }
        }
        // if chosenWord is in the cache, move it to front,
        // and update weight in cacheTrie
        if oldIndex != -1 {
            let lastWord = self.cacheList[oldIndex]
            self.cacheList.remove(at: oldIndex)
            self.cacheList.insert(lastWord, at: 0)
            self.updateWeight(word: chosenWord)
        }
        else {
            self.insert(word: chosenWord, weight: weight)
        }
    }
    
    internal func updateWeight(word: String) {
        let keySequence = getKeySequence(word: word)
        let prefixNode = cacheTrie.getPrefixLeaf(keySequence: keySequence).0
        if cacheTrie.wordExists(word: word, keySequence: keySequence) {
            for wordWeight in prefixNode!.wordWeights {
                if wordWeight.word == word {
                    wordWeight.weight += 1
                    break
                }
            }
        }
    }
    
    // Only call from update() so that we've already checked
    // to see if chosenWord is in the cache
    internal func insert(word: String, weight: Int) {
        // if @ capacity
        if self.cacheList.count == self.sizeLimit {
            self.pruneOldest()
        }
        // put most recent word at beginning
        if self.cacheList.count > 0 {
            self.cacheList[0] = word
        }
        self.cacheTrie.insert(word: word, weight: weight)
    }
    
    internal func pruneOldest() {
        self.pruneWord(wordToPrune: cacheList[cacheList.count - 1])
    }
    
    internal func pruneWord(wordToPrune: String) {
        let keySequnce = getKeySequence(word: wordToPrune)
        var nodeToPrune = self.cacheTrie.getPrefixNode(keySequence: keySequnce)
        // If wordToPrune is a prefix with other children, just remove this one word from the word list of nodeToPrune
        if (nodeToPrune?.children.count)! > 0 {
            var wordIndex = 0
            for (i, wordWeight) in (nodeToPrune?.wordWeights.enumerated())! {
                if wordWeight.word == wordToPrune {
                    wordIndex = i
                }
            }
            nodeToPrune?.wordWeights.remove(at: wordIndex)
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
