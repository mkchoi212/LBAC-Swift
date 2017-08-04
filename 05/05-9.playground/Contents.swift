import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## Do Statement
 
 The for-loop we made previously could've been simpler, right?
 The reason for the massive amount of code in `doFor` was to have
 the loop counter accessible as a variable within the loop.
 
 If we just need a counting loop that goes through something `x` number of times,
 but don't need access to the counter itself, we could have something much simpler.
 
 680000 has a "decrement and branch nonzero" that is perfect for this.
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

/*:
 > `d` is for `doDo()`
 */
func block() {
    while let cur = LOOK.cur, !(["e", "l", "u"].contains(cur)) {
        switch cur {
        case "i":
            doIf()
        case "w":
            doWhile()
        case "p":
            doLoop()
        case "r":
            doRepeat()
        case "f":
            doFor()
        case "d":
            doDo()
        default:
            other()
        }
    }
}

func condition() {
    emitLine(msg: "<condition>")
}

func expression() {
    emitLine(msg: "<expr>")
}

/*:
 ```
 DO
 <expr>         { Emit(SUBQ #1,D0);
                  L = newLabel()
                  postLabel(L)
                  emit(MOVE D0,-(SP) }
 <block>
 ENDDO          { emit(MOVE (SP)+,D0;
                  emit(DBRA D0,L) }
 ```
 This is much simpler than the classic for-loop.
 */
func doDo() {
    match("d")
    let L1 = newLabel()
    expression()
    emitLine(msg: "SUBQ #1,D0")
    postLabel(L1)
    emitLine(msg: "MOVE D0,-(SP)")
    block()
    emitLine(msg: "MOVE (SP)+,D0")
    emitLine(msg: "DBRA D0,\(L1)")
}

func doFor() {
    match("f")
    let L1 = newLabel()
    let L2 = newLabel()
    
    let name = getName()
    match("=")
    expression()
    emitLine(msg: "SUBQ #1,D0")
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE D0,(A0")
    expression()
    emitLine(msg: "MOVE D0,-(SP)")
    postLabel(L1)
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE (A0),D0")
    emitLine(msg: "ADDQ #1,D0")
    emitLine(msg: "MOVE D0,(A0)")
    emitLine(msg: "CMP (SP),D0")
    emitLine(msg: "BGT \(L2)")
    block()
    match("e")
    emitLine(msg: "BRA \(L1)")
    postLabel(L2)
    emitLine(msg: "ADDQ #2,SP")
}

func doRepeat() {
    match("r")
    let label = newLabel()
    postLabel(label)
    block()
    match("u")
    condition()
    emitLine(msg: "BEQ \(label)")
}

func doLoop() {
    match("p")
    let label = newLabel()
    postLabel(label)
    block()
    match("e")
    emitLine(msg: "BRA \(label)")
}

func doWhile() {
    var L1, L2: String
    match("w")
    L1 = newLabel()
    L2 = newLabel()
    postLabel(L1)
    condition()
    emitLine(msg: "BEQ \(L2)")
    block()
    match("e")
    emitLine(msg: "BRA \(L1)")
    postLabel(L2)
}

func doIf() {
    var L1, L2: String
    
    match("i")
    condition()
    L1 = newLabel()
    L2 = L1
    emitLine(msg: "BEQ \(L1)")
    block()
    
    if let cur = LOOK.cur, cur == "l" {
        match("l")
        L2 = newLabel()
        emitLine(msg: "BRA \(L2)")
        postLabel(L1)
        block()
    }
    
    match("e")
    postLabel(L2)
}

func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "afi=bece")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
