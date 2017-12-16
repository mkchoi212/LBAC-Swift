import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 5: C

 The big problem with C is that first two parts of the declaration for data and functions can be the same
 
 ```c
 int this_is_a_var ...
 int this_is_a_func ...
 ```
 
 Because of this property, we can't use our existing recursive-descent parser on it. But we can transform it into one that is suitable.
 */

let TAB : Character = "\t"
let LF = "\n"
let whiteChars: [Character] = [" ", TAB]

struct Buffer {
    var idx : Int
    var cur : Character?
    let input: String
}

extension Buffer {
    init() {
        idx = 0
        input = ""
        getChar()
    }
    
    mutating func getChar() {
        let i = input.index(input.startIndex, offsetBy: idx)
        
        if i == input.endIndex {
            cur = nil
        } else {
            cur = input[i]
            idx += 1
        }
    }
}

func error(msg: String) {
    print("Error: \(msg).")
}

func abort(msg: String) {
    error(msg: msg)
    exit(EXIT_FAILURE)
}

func expected(_ s: String) {
    abort(msg: "\(s) expected")
}

func emit(msg: String) {
    print("\(TAB) \(msg)", separator: "", terminator: "")
}

func emitLine(msg: String) {
    print("\(TAB) \(msg)")
}

func postLabel(_ label: String) {
    print("\(label):", terminator:"")
}

func isAlpha(_ c: Character?) -> Bool {
    if let c = c, "a"..."z" ~= c || "A"..."Z" ~= c {
        return true
    } else {
        return false
    }
}

func isDigit(_ c: Character?) -> Bool {
    if let c = c, "0"..."9" ~= c {
        return true
    } else {
        return false
    }
}

func isAlnum(_ c: Character?) -> Bool {
    return isAlpha(c) || isDigit(c)
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

func getName() -> Character {
    if !isAlpha(LOOK.cur) {
        expected("Name")
    }
    let upper = String(LOOK.cur!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

func getNum() -> Character {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

func getClass() {
    LOOK.getChar()
}

func getType() {
    LOOK.getChar()
}

func topDecl() {
    LOOK.getChar()
}

/*:
 The trick we will use is this...
 > We will build a parsing routine for class and type definitions and have them store away their findings, **all without knowing wheter a function or a data declaration is being processed.**
 
 Notice that all three functions are dummy functions that call `getChar()`
 */
func prog() {
    // The book's while loop runs until `cur == ^Z`
    // but since we are in Playground, we will have to satisfy with nil-checking
    while LOOK.cur != nil {
      getClass()
      getType()
      topDecl()
    }
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ic.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
