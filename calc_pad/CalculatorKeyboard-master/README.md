# CalculatorKeyboard
CalculatorKeyboard

T9 Algorithm:

	A T9 Trie looks like this:
		http://assets.kennislink.nl/system/files/000/058/401/large/Trie9.jpg?1274265131
	At each node is a list of words that have been formed with sequence of key presses.
	For example, in the first level of the Trie, at node 2, the only word known that can
	be formed by pressing only the key 2 is 'a'.

Example walkthrough:

	User enters a key:
		2
	The program makes an empty list of predicted words.
		predictions = []
	The program follows this key path in the Trie.
		Root Node (Words = []) -> 2 (Words = ['a'])
	The program adds ['a'] to predictions.
		predictions = ['a']
	The program then searches <suggestionDepth> number of levels further in the Trie to
	find more word predictions. Suppose suggestionDepth = 2. Then the program will search
	2 more levels from every branch from node 2 at level 1. The Trie is traversed depth-first.
		Root Node -> 2 -> 2
		Root Node -> 2 -> 2 -> 2
		Root Node -> 2 -> 2 -> 3
		...
		Root Node -> 2 -> 2 -> 9
		
		Root Node -> 2 -> 3
		Root Node -> 2 -> 3 -> 2
		Root Node -> 2 -> 3 -> 3
		...
		Root Node -> 2 -> 3 -> 9
		
		and so on...
		
		Root Node -> 2 -> 9 -> 9
	For every node at each level, the corresponding word list is added to the predictions list.
		predictions = ['a', 'as', 'at', 'are',... 'bat', ...]
	The prediction list is ordered first by the length of the word (with shorter words coming first),
	and then by weight.
		So if predictions = ['com', 'commuter', 'computer'], then 'com' would always come first, and
		then 'computer' would come next because it would probably have more weight than 'commuter'.