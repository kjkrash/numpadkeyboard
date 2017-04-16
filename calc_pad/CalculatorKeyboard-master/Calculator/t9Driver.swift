import Foundation



enum SuggestionStatus {
	case EXIST
	case NONE
	case PENDING
}

class T9 {
	
	internal var suggestionStatus: SuggestionStatus
	
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
	
	// The set of acceptable chars for a word
	internal let charSet: CharacterSet
    
    init(dictionaryFilename: String,
         resetFilename: String,
         suggestionDepth: Int,
         numResults: Int,
         numCacheResults: Int,
         cacheSize: Int) {
        assert(numResults > numCacheResults)
        self.trie = Trie(dictionaryFilename: dictionaryFilename, suggestionDepth: suggestionDepth)
        self.cache = Cache(sizeLimit: cacheSize, suggestionDepth: suggestionDepth)
		self.suggestionStatus = SuggestionStatus.PENDING
        self.numResults = numResults
        self.numCacheResults = numCacheResults
        self.numTrieResults = numResults - numCacheResults
		self.charSet = CharacterSet.letters
    }
	
	func getSuggestionStatus() -> SuggestionStatus! {
		return self.suggestionStatus
	}
	
	func backspace() {
		if self.suggestionStatus == SuggestionStatus.NONE {
			self.suggestionStatus = SuggestionStatus.EXIST
		}
	}
	
    func getSuggestions(keySequence: [Int], shiftSequence: [Bool]) -> [String] {
		
		// Proceed to get suggestions only if there were already suggestions
		// for the last key seq or we are waiting for a new word to begin
		// (status: PENDING)
		if self.suggestionStatus == SuggestionStatus.NONE {
			return []
		}
		
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
            
            // The number of words to use from trieSuggestions =
            // the number of Trie words asked for in the initializer plus
            // however many words it takes to make up for the deficit in cache
            // results.
            var numTrieResultsToFetch = self.numTrieResults + (self.numCacheResults - cacheSuggestions.count)
            if numTrieResultsToFetch > trieSuggestions.count {
                numTrieResultsToFetch = trieSuggestions.count
            }
            suggestions += trieSuggestions[0..<numTrieResultsToFetch]
            suggestions += cacheSuggestions
        } else if cacheSuggestions.count >= self.numCacheResults {
            // only cache fills suggestion quota
            var numCacheResultsToFetch = self.numCacheResults + (self.numTrieResults - trieSuggestions.count)
            if numCacheResultsToFetch > cacheSuggestions.count {
                numCacheResultsToFetch = cacheSuggestions.count
            }
            suggestions += trieSuggestions
            suggestions += cacheSuggestions[0..<numCacheResultsToFetch]
        } else {
            // Neither fill quota
            suggestions += trieSuggestions
            suggestions += cacheSuggestions
        }
		
		if suggestions.count == 0 {
			self.suggestionStatus = SuggestionStatus.NONE
			return suggestions
		} else {
			self.suggestionStatus = SuggestionStatus.EXIST
		}
		
		func removeDuplicates() {
			// remove duplicates from overlap between cache and getSuggestions() using a map
			// to keep track of seen values
			var dupeDetector = [String: Bool]()
			
			var i = 0
			while i < suggestions.count {
				// check if key exists
				let keyExists = dupeDetector[suggestions[i]] != nil
				
				// if so, remove the duplicate and decrement counter to account for off by one
				// else, mark as seen
				if keyExists {
					suggestions.remove(at: i)
				}
				else {
					dupeDetector[suggestions[i]] = true
					i += 1
				}
			}
		}
		
		removeDuplicates()
		
		func applyCaps() {
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
		}
		
		applyCaps()
		
        return suggestions
    }
	
	// Returns true if the word is successfully remembered
    func rememberChoice(word: String) -> Bool {
		
		if word.length == 0 {
			return false
		}
		
		// Verify that the word contains only letters
		for i in 0..<word.length {
			if !self.charSet.contains(UnicodeScalar(word[i])!) {
				return false
			}
		}
		
        // If the chosen word was one of the suggestions, update its weight in
        // the Trie. If it is not in the trie, updateWeight will insert it.
		// Thus, this function should be called after every word, new or old.
		
		if self.suggestionStatus == SuggestionStatus.NONE {
			self.suggestionStatus = SuggestionStatus.PENDING
			return false
		}
		
        NSLog("rememberChoice(\(word))")
        _ = trie.updateWeight(word: word)
		
		return true
    }
}
