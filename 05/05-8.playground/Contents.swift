import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## For Loop
 
 Very handy and simple; it's just a loop. But it's hard to implement in assembly.
 So, once we get the assembly code figured out, the translation shouldn't be too hard.
 
 ```
 FOR <ident> = <expr1> TO <expr2> <block> ENDFOR
 ```
 We are going to consider this being equivalent to
 
 ```
 <ident> = <expr1>
 TEMP = <expr2>
 WHILE <ident> <= TEMP
 <block>
 ENDWHILE
 ```
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
 > `f` is for `doFor()`
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
        default:
            other()
        }
    }
}

func condition() {
    emitLine(msg: "<condition>")
}

/*:
 > Dummy expression function
 */
func expression() {
    emitLine(msg: "<expr>")
}

/*:
 How the ,for-loop works in assembly
 ```
 <ident>             get name of loop counter
 <expr1>             get initial value
 LEA <ident>(PC),A0  address the loop counter
 SUBQ #1,D0          predecrement it
 MOVE D0,(A0)        save it
 <expr1>             get upper limit
 MOVE D0,-(SP)       save it on stack
 
 L1:  LEA <ident>(PC),A0  address loop counter
 MOVE (A0),D0        fetch it to D0
 ADDQ #1,D0          bump the counter
 MOVE D0,(A0)        save new value
 CMP (SP),D0         check for range
 BLE L2              skip out if D0 > (SP)
 <block>
 BRA L1              loop for next pass
 L2:  ADDQ #2,SP     clean up the stack
 ```
 The function itself should be easier to reason about.
 */

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
