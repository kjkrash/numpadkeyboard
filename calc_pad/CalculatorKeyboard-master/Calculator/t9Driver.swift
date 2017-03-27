import Foundation

// http://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

class T9 {
    
    // The total number of suggestions to be returned from T9.
    internal let numResults: Int
    
    // The number of suggestions to be returned from the cache.
    internal let numCacheResults: Int
    
    // numResults - numCacheResults = number of results from the main Trie
    internal let numTrieResults: Int
    
    // The prefix tree structure
    internal var trie: Trie
    
    // Caches recent results
    internal var cache: Cache
    
    internal var suggestionDepth: Int
    
    init(dictionaryFilename: String,
         resetFilename: String,
         suggestionDepth: Int,
         numResults: Int,
         numCacheResults: Int,
         cacheSize: Int) {
        assert(numResults > numCacheResults)
        self.trie = Trie(dictionaryFilename: dictionaryFilename)
        self.cache = Cache(sizeLimit: cacheSize)
        self.numResults = numResults
        self.numCacheResults = numCacheResults
        self.numTrieResults = numResults - numCacheResults
        self.suggestionDepth = suggestionDepth
        self.trie.loadTrie()
    }
    
    func getSuggestions(keySequence: [Int], shiftSequence: [Bool]) -> [String] {
        var suggestions = trie.getSuggestions(keySequence: keySequence, suggestionDepth: self.suggestionDepth)
        
        if suggestions.count > self.numTrieResults {
            // Chop off excess Trie results
            let count = suggestions.count
            for _ in 0 ..< count - self.numTrieResults {
                suggestions.removeLast()
            }
        }
        
        // merge trie suggestions with cached suggestions
        suggestions.append(contentsOf: cache.getSuggestions(keySequence: keySequence, suggestionDepth: suggestionDepth))
        
        // truncate excess results
        if suggestions.count > self.numResults {
            let count = suggestions.count
            for _ in 0 ..< count - self.numResults {
                suggestions.removeLast()
            }
        }
        
        // remove duplicates from overlap between cache and getSuggestions() using a map
        // to keep track of seen values
        var dupeDetector = [String: Bool]()
        
        // traverse list
        for var i in 0..<suggestions.count {
            // check if key exists
            let keyExists = dupeDetector[suggestions[i]] != nil
            
            // if so, remove the duplicate and decrement counter to account for off by one
            // else, mark as seen
            if keyExists {
                suggestions.remove(at: i)
                i -= 1
            }
            else {
                dupeDetector[suggestions[i]] = true
            }
        }
        
        return suggestions
    }
    
    func rememberChoice(word: String) {
        // If the chosen word was one of the suggestions, update its weight in
        // the Trie
        _ = trie.updateWeight(word: word)
    }
}
