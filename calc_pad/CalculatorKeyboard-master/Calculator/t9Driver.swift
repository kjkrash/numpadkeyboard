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
    // Filename of the dictionary that will be updated over time
    var dictionaryFilename: String
    
    // Filename of the original dictionary. For resetting the altered dictionary
    // to its original content. For testing purposes.
    let resetFilename: String
    
    // The number of levels deeper to probe in the Trie. The larger the number,
    // the longer the words that will be suggested.
    let suggestionDepth: Int
    
    // The total number of suggestions to be returned from T9.
    let numResults: Int
    
    // The number of suggestions to be returned from the cache.
    let numCacheResults: Int
    
    // numResults - numCacheResults = number of results from the main Trie
    let numTrieResults: Int
    
    // The prefix tree structure
    var trie: Trie
    
    // Caches recent results
    var cache: Cache

    init(dictionaryFilename: String,
         resetFilename: String,
         suggestionDepth: Int,
         numResults: Int,
         numCacheResults: Int,
         cacheSize: Int) {
        assert(numResults > numCacheResults)
        self.dictionaryFilename = dictionaryFilename
        self.trie = Trie(dictionaryFilename: dictionaryFilename)
        self.cache = Cache(sizeLimit: cacheSize)
        self.numResults = numResults
        self.numCacheResults = numCacheResults
        self.numTrieResults = numResults - numCacheResults
        self.suggestionDepth = suggestionDepth
        self.resetFilename = resetFilename
        self.trie.loadTrie()
    }
    
    func getSuggestions(keySequence: [Int], shiftSequence: [Bool]) -> [String] {
        var suggestions = trie.getSuggestions(keySequence: keySequence,
                                          suggestionDepth: Int(suggestionDepth))
        
        if suggestions.count > self.numTrieResults {
            // Chop off excess Trie results
            let count = suggestions.count
            for _ in 0 ..< count - self.numTrieResults {
                    suggestions.removeLast()
            }	
        }
        
        suggestions.append(contentsOf: cache.getSuggestions(keySequence: keySequence,
                                        suggestionDepth: self.suggestionDepth))
        
        if suggestions.count > self.numResults {
            let count = suggestions.count
            for _ in 0 ..< count - self.numResults {
                    suggestions.removeLast()
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
