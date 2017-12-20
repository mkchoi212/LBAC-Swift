import Foundation
/*:
 # LBaC
 # Part X: Introducing "TINY"
 ## Part 8: Executable Statements II
 
 It's time implement the code generator for the assignment statement. But so far, we've just had bunch of `emitLine(...)` here and there. It's straightforward but is not the most structured method to do things.

 Now, we will make our compiler **"CPU independent"**. The new approach will allow you to retarget the compiler to a new CPU by just rewriting these **"code generator"** functions.
 */

var ST : [Character : Bool] = [:]
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

func emitLine(msg: String, _ tabEnabled : Bool = true) {
    let padding = tabEnabled ? "\t " : ""
    print("\(padding)\(msg)")
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

func getNum() -> Int {
    var num = 0
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    while let cur = LOOK.cur, isDigit(cur) {
        num = num * 10 + Int(String(cur))!
        LOOK.getChar()
    }

    return num
}

/*:
 ## The Assembler
 Now, if you want to retarget the compiler to a new CPU, you just have to rewrite these code generator procedures.
 */
enum Assembler {
    case Clear, Negate, Push
    case PopAdd, PopSub, PopMul, PopDiv
    case LoadConst(Int), LoadVar(Character)
    case Store(Character)
    case Header, Prolog, Epilog
    
    static func generate(_ cmd: Assembler) {
        var code: String!
        switch cmd {
        case .Clear:
            code = "CLR D0"
        case .Negate:
            code = "MOVE D0, -(SP)"
        case .Push:
            code = "ADD (SP)+, D0"
        case .PopAdd:
            code = "ADD (SP)+,D0"
        case .PopSub:
            code = "SUB (SP)+, D0\nNEG D0"
        case .PopMul:
            code = "MULS (SP)+, D0"
        case .PopDiv:
            code = """
                   MOVE (SP)+, D7
                   EXT.L D7
                   DIVS D0, D7
                   MOVE D7, D0"
                   """
        case .LoadConst(let n):
            code = "MOVE #\(n), D0"
        case .LoadVar(let n):
            if !isInTable(n) { undefined(n) }
            else { code = "MOVE \(n)(PC), D0}" }
        case .Header:
            code = "WARMST\tEQU $A01E"
        case .Prolog:
            postLabel("MAIN")
            return
        case .Epilog:
            code = "DC WARMST\nEND MAIN"
        case .Store(let n):
            if !isInTable(n) { undefined(n) }
            else { code = "LEA \(n)(PC),A0\nMOVE D0, (A0)" }
        }
        emitLine(msg: code)
    }
    
    static func undefined(_ n: Character) {
        abort(msg: "Undefined Idenifier \(n)")
    }
}

func assignment() {
    LOOK.getChar()
}

func block() {
    while LOOK.cur != "e" {
        assignment()
    }
}

func main() {
    match("b")
    Assembler.generate(.Prolog)
    block()
    match("e")
    Assembler.generate(.Epilog)
}

func alloc(_ n: Character) {
    if isInTable(n) {
      abort(msg: "Duplicate variable name \(n)")
    }
    ST[n] = true
  
    var isPositive = true

    emit(msg: "\(n):\tDC ")
    if LOOK.cur == "=" {
      match("=")
      if LOOK.cur == "-" {
        isPositive = false
        match("-")
        emit(msg: "-")
      }
      emitLine(msg: "\(getNum())", isPositive)
    } else {
      emitLine(msg: "0")
    }
}

func decl() {
    match("v")
    alloc(getName())
    while LOOK.cur == "," {
      LOOK.getChar()
      alloc(getName())
    }
}

func topDecl() {
    while let cur = LOOK.cur, cur != "b" {
      switch cur {
      case "v":
        decl()
      default:
        abort(msg: "Unrecognized keyword \(cur)")
      }
    }
}

func prog() {
    match("p")
    Assembler.generate(.Header)
    topDecl()
    main()
    match(".")
}

func isInTable(_ n: Character) -> Bool {
    guard let res = ST[n] else { return false }
    return res
}

func initializeSymbolTable() {
    let allVars = (97...122).map({Character(UnicodeScalar($0))})
    allVars.map { name in
      ST[name] = false
    }
}

func initialize() -> Buffer {
    initializeSymbolTable()
    var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b=123,c=-456be.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
