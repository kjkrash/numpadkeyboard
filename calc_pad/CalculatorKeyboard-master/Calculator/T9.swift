//
//  T9.swift
//  CalculatorKeyboard
//
//  Created by Kiera Krashesky on 2/14/17.
//  Copyright © 2017 Visual Recruit Pty Ltd. All rights reserved.
//
// REF FOR PERMUTATION FUNCTION: http://stackoverflow.com/questions/34968470/calculate-all-permutations-of-a-string-in-swift


import Foundation

struct T9Mappings {
    struct NineKeys {
        static let mapping = [
            "alphabets": [
                "1":["@","/","."],
                "2":["a","b","c"],
                "3":["d","e","f"],
                "4":["g","h","i"],
                "5":["j","k","l"],
                "6":["m","n","o"],
                "7":["p","q","r","s"],
                "8":["t","u","v"],
                "9":["w","x","y","z"],
                "10":[" "]
            ],
            "numbers": [
                "1":["1"],
                "2":["2"],
                "3":["3"],
                "4":["4"],
                "5":["5"],
                "6":["6"],
                "7":["7"],
                "8":["8"],
                "9":["9"],
                "10":["0"]
            ]
        ]
    }
}

class T9_old: NSObject {
    var lastKeyControlTime: Date
    var storedInputs: String
    var dictTrie:Trie
    override init() {
        lastKeyControlTime = Date()
        storedInputs = ""
        dictTrie = Trie(dictionaryFilename: "dictionary.txt")
        super.init()
    }
    func genPerms(n:Int, a:inout Array<Character>) {
        var possibilites = [String]()
        permutations(n: n, &a, b: &possibilites)
    }
    
    func permutations(n:Int, _ a:inout Array<Character>, b:inout Array<String>) {
        if n == 1 {b.insert(String(a), at:0)}
        for i in 0..<n-1 {
            permutations(n: n-1,&a,b: &b)
            swap(&a[n-1], &a[(n%2 == 1) ? 0 : i])
        }
        permutations(n: n-1,&a,b: &b)
    }
    
    //    var pointerAddress = 0
    //    var previousTag = -1
    //    var previousInputs = ""
    //    var storedInputs: String
    //    var lastKeyControlTime: Date
    //    var inputsDelay: TimeInterval {
    //        get{
    //            return Date().timeIntervalSince(lastKeyControlTime)
    //        }
    //    }
    //    override init() {
    //        lastKeyControlTime = Date()
    //        storedInputs = "Input will appear here..."
    //        super.init()
    //    }
    //    func toggle(mode: String, tag: Int) -> String {
    //        if tag == previousTag {
    //            if inputsDelay >= 0.8 {
    //                pointerAddress = 0
    //                previousTag = tag
    //                storedInputs = storedInputs + previousInputs
    //                previousInputs = Keys.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
    //                lastKeyControlTime = Date()
    //                return storedInputs + Keys.NineKeys.mapping[mode]![String(tag)]![0]
    //            }else{
    //                pointerAddress += 1
    //                if !(Keys.NineKeys.mapping[mode]?[String(tag)]?.indices.contains(pointerAddress))! {
    //                    pointerAddress = 0
    //                }
    //                previousInputs = Keys.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
    //                lastKeyControlTime = Date()
    //                return storedInputs + previousInputs
    //            }
    //        }else{
    //            pointerAddress = 0
    //            previousTag = tag
    //            storedInputs = storedInputs + previousInputs
    //            previousInputs = Keys.NineKeys.mapping[mode]![String(tag)]![pointerAddress]
    //            lastKeyControlTime = Date()
    //            return storedInputs + Keys.NineKeys.mapping[mode]![String(tag)]![0]
    //        }
    //    }
    //    func backspace() -> String {
    //        if storedInputs.characters.count > 0 {
    //            storedInputs.characters.removeLast()
    //            previousInputs = ""
    //            pointerAddress = 0
    //            previousTag = -1
    //            lastKeyControlTime = Date()
    //            return storedInputs
    //        }
    //        return ""
    //    }
    //    func clear() {
    //        previousInputs = ""
    //        storedInputs = ""
    //        pointerAddress = 0
    //        previousTag = -1
    //        lastKeyControlTime = Date()
    //    }
}
