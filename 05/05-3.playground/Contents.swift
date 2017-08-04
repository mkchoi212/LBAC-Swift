import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## IF Statement
 
 We'll  be  dealing with transfer of control, which at the assembler-language level means
 conditional and/or  unconditional branches.
 For  example,  the simple `IF` statement
 
 ```
 IF <condition> A ENDIF B ....
 ```
 must get translated into
 
 ```
     Branch if NOT condition to L
     A
 L:  B
     ...
 ```

 If you compare the `IF` statement with the assembler code, you can see that certain actions
 are associated with keywords
 
 - `IF`
     - Get condition and make code for it. Create unique label and emit branch if false
 - `ENDIF`
     - Emit the label
 */

let TAB : Character = "\t"
var LCNT: Int = 0

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

func newLabel() -> String {
    let label = "L\(String(LCNT))"
    LCNT += 1
    return label
}

func postLabel(_ label: String) {
    print("\(label):", terminator:"")
}

func other() {
    emitLine(msg: "\(getName())")
}

func block() {
    while let cur = LOOK.cur, !(["e"].contains(cur)) {
        switch cur {
        case "i":
            doIf()
        default:
            other()
        }
    }
}

/*:
 This function serves to parse and translate any boolean
 condition we give it within our if-statement.
 > This is just a dummy version we will use for now
 */
func condition() {
    emitLine(msg: "<condition>")
}

/*:
 ## Recognize if-statements
 On the 68000
 - `BEQ` (branch if false)
 - `BNE` (branch if true)
 
 > For now, we will be branching around the code that will be
 executed when the condition is true.
 */
func doIf() {
    match("i")
    let label = newLabel()
    condition()
    emitLine(msg: "BEQ \(label)")
    block()
    match("e")
    postLabel(label)
}

func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "aibece")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
