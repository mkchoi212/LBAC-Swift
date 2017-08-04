import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## Loop Statement
 
 So far, we did an `IF` and a `WHILE`. Now, we are going to add an INFINITE LOOP!
 What's the point of this? Well, not much for now but we'll later add a `BREAK`
 so we can control it.
 
 The syntax is
 ```
 LOOP <block> ENDLOOP
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
 > Updated with `p` for `doLoop()`
 */
func block() {
    while let cur = LOOK.cur, !(["e", "l"].contains(cur)) {
        switch cur {
        case "i":
            doIf()
        case "w":
            doWhile()
        case "p":
            doLoop()
        default:
            other()
        }
    }
}

func condition() {
    emitLine(msg: "<condition>")
}

/*:
 > Since `l` is taken, we will use `p`
 ```
 LOOP           { L = newLabel()
                  postLabel(L) }
 <block>
 ENDLOOP        { emit(BRA L)  }
 ```
 */
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
    var LOOK = Buffer(idx: 0, cur: nil, input: "apze")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
