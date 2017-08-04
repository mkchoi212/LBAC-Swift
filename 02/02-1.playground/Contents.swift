import Foundation

/*:
 # LBaC 
 # Part II: Expression Parsing
 ## Single Digits
 
 We will parse and translate mathematical expressions in this Playground.
 What we eventually want is to output serires of aseembler-language statements
 that perform certain actions.
 
 In the beginning, we are keeping it simple and starting with a **single digit.**
 Try any single-digit number in `LOOK`'s `input` in `initialize()` and look at its output.
 
 Congratulations! You just wrote a working translator 🎉🎉🎉
 */

let TAB: Character = "\t"

struct Buffer {
    var idx: Int
    var cur: Character?
    let input: String
}

extension Buffer {
    init() {
        idx = 0
        input = readLine()!
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

func match(_ c: Character) {
    if LOOK.cur == c {
       LOOK.getChar()
    } else {
        expected("\(c)")
    }
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

func getName() -> Character {
    let c = LOOK.cur
    if !isAlpha(c) {
        expected("Name")
    }
    let upper = String(c!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

func getNum() -> Character {
    let num = LOOK.cur
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return num!
}

func term() {
    emitLine(msg: "MOVE #\(getNum()),D0")
}


/// Parse and translate a math expression
func expression() {
    emitLine(msg: "MOVE #\(getNum()),D0")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()
