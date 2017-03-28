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
    
    init(dictionaryFilename: String,
         resetFilename: String,
         suggestionDepth: Int,
         numResults: Int,
         numCacheResults: Int,
         cacheSize: Int) {
        assert(numResults > numCacheResults)
        self.trie = Trie(dictionaryFilename: dictionaryFilename, suggestionDepth: suggestionDepth)
        self.cache = Cache(sizeLimit: cacheSize, suggestionDepth: suggestionDepth)
        self.numResults = numResults
        self.numCacheResults = numCacheResults
        self.numTrieResults = numResults - numCacheResults
    }
    
    func getSuggestions(keySequence: [Int], shiftSequence: [Bool]) -> [String] {
        var trieSuggestions = trie.getSuggestions(keySequence: keySequence)
        var cacheSuggestions: [String] = []
        var suggestions: [String] = []
        if self.numCacheResults > 0 {
            cacheSuggestions = cache.getSuggestions(keySequence: keySequence)
        }
        
        // Both fill suggestion quota
        if trieSuggestions.count >= self.numTrieResults &&
            cacheSuggestions.count >= self.numCacheResults {
            suggestions += trieSuggestions[0..<self.numTrieResults]
            suggestions += cacheSuggestions[0..<self.numCacheResults]
        } else if trieSuggestions.count >= self.numTrieResults {
            // only Trie fills suggestion quota
            let numTrieResultsToFetch = self.numTrieResults + (self.numCacheResults - cacheSuggestions.count)
            let numT = trieSuggestions.count - self.numTrieResults
            suggestions += trieSuggestions[0..<self.numTrieResults + numT]
            suggestions += cacheSuggestions
        } else if cacheSuggestions.count >= self.numCacheResults {
            // only cache fills suggestion quota
            let numCacheResultsToFetch = self.numCacheResults + (self.numTrieResults - trieSuggestions.count)
            suggestions += trieSuggestions
            suggestions += cacheSuggestions[0..<numCacheResultsToFetch]
        } else {
            // Neither fill quota
            suggestions += trieSuggestions
            suggestions += cacheSuggestions
        }
        /*
        var suggestions = trie.getSuggestions(keySequence: keySequence)
        
        if suggestions.count > self.numTrieResults {
            // Chop off excess Trie results
            let count = suggestions.count
            for _ in 0 ..< count - self.numTrieResults {
                suggestions.removeLast()
            }
        }
        
        // merge trie suggestions with cached suggestions
        if self.numCacheResults > 0 {
            suggestions.append(contentsOf: cache.getSuggestions(keySequence: keySequence))
        }
        
        // truncate excess results
        if suggestions.count > self.numResults {
            let count = suggestions.count
            for _ in 0 ..< count - self.numResults {
                suggestions.removeLast()
            }
        }
        */
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
        
        // Apply capitalization
        // FIXME: very inefficient. cant figure out how to directly modify char in str
        
        var shiftExists = false
        for shiftStatus in shiftSequence {
            if shiftStatus {
                shiftExists = true
                break
            }
        }
        
        if shiftExists {
            for (i, word) in suggestions.enumerated() {
                var j = 0
                var wordWithCaps: String = ""
                while j < shiftSequence.count && j < word.length {
                    if shiftSequence[j] {
                        wordWithCaps.append(word[j].uppercased())
                    } else {
                        wordWithCaps.append(word[j])
                    }
                    j += 1
                }
                if shiftSequence.count < word.length {
                    for k in j..<word.length {
                        wordWithCaps.append(word[k])
                    }
                }
                suggestions[i] = wordWithCaps
            }
        }
        return suggestions
    }
    
    func rememberChoice(word: String) {
        // If the chosen word was one of the suggestions, update its weight in
        // the Trie
        NSLog("remember choice")
        _ = trie.updateWeight(word: word, weight: 1)
    }
}
