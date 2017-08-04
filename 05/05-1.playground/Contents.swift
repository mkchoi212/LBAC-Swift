import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## So far..
 
 So far, we've been just dealing with mathematical expressions.
 And since real langauges have branches and loops and subroutines and more,
 you may be feeling that we are far away from being able to write a complete language.
 
 But according to the author, it's far easier than writing expression parsers! So, 🤷‍♂️

 ## The Plan
 We will start from the bare cradle once again and build up from there.
 We will also keep the concept of single-character tokens; this means using
 `i` for `IF` and `w` for `WHILE` 🙃
 
 We won't deal with assignment statements because we proved we can implement them
 and we don't need them to hold us down. So instead, we will use an anonymous
 function `other` that will take place for any non-control statements and act
 as a place-holder for them.
 
 Also, we are back in compilation mode.
 
 ## The Implementation
 First thing is first; we need the ability to deal with more than one statmenet since a single-line for-loop / if-statement is going to be limited.

 ```
 <program> ::= <block> END
 <block> ::= [ <statement> ]*
 ```
 
 This BNF says that a program is defined as a block, followed by an `END`. A block, in turn, consists of
 an array of `statements`. What signals the end of a block? Any construct that isn't an `other` statement;
 for now, a `END` statement.
*/

let TAB : Character = "\t"


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

/*:
 ## The "other" function
 */
func other() {
    emitLine(msg: "\(getName())")
}

/*:
 `<block> ::= [ <statement> ]*`
 */
func block() {
    while let cur = LOOK.cur, !(["e"].contains(cur)) {
        other()
    }
}

/*:
 `<program> ::= <block> END`
 > Note `e` stands for `END` for now
 */
func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ae")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
