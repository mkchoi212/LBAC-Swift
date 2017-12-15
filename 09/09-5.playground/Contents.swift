import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 5: Small C
 C is a completely different monster.

 C has less structure than Pascal and at the top level, everything is a *static declaration*, either of data or of a function.
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

func preProcess() {
    match("#")
}

func intDecl() {
    match("i")
}

func charDecl() {
    match("c")
}

/*:
 ## Small C
 We are interested in the full C but we will first briefly look at the top-level structure of Small C to get of taste of what is to come.
 
 In Small C, **functions can only have default type int**, which is not explicitly declared.
 
 This makes the input easy to parse. First token is either `int` or `char`, or the name of the function.
 */
func prog() {
    while let cur = LOOK.cur {
        switch cur {
        case "#":
            preProcess()
        case "i":
            intDecl()
        case "c":
            charDecl()
        default:
            break
        }
    }
}

/*:
 With full C, things aren't even this easy.
 
 Problem is that in full C, functions can also have types. **So when the compiler sees a keyword `int`, it still doesn't know whether to expect a data declaration or a function definition.**
 
 We will explore more into how to do this in the *next part*.
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ic.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
