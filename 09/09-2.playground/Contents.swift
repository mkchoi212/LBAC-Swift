import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 2: Fleshing it Out
 To flesh out the compiler, we only need to make the features of the language, one by one. We will first start with empty procedures and add details to them incrementally.
 
 Let's start by processing the `doBlock`.
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

func declarations() {
    
}


func statements() {
    
}

/*:
 ## The doBlock
 doBlock just folows what a block should look like. Declarations followed by statements.
 
 The insertion of label via `postLabel` has to do with the operation of SK*DOS. Unlike most OS's, SK*DOS allows the entry point to the main program to be anywhere in the program. All you have to do is give that point a name.
 
 `postLabel` does this by putting that name just before the first `statement`.
 
 > `declarations` and `statements` are dummy functions for now. We will make them in the next part
 */
func doBlock(name: Character) {
    declarations()
    postLabel(String(name))
    statements()
}

func prolog() {
    emitLine(msg: "WARMST EQU $A01E")
}

func epilog(_ name: Character) {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END \(name)")
}

/*:
 > Note that prog now handles `doBlock`
 */
func prog() {
    match("p")
    let name = getName()
    prolog()
    doBlock(name: name)
    match(".")
    epilog(name)
}
 
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "px.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
