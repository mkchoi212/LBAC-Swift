import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 4: Statements
 Implementing `statements()`
 
 ### Something to 🤔 about
 We have been adding functions but the output of the program hasn't changed. And it's the way it's supposed to be.
 
 This high in the levels - *remember we are doing high to low now* - we don't need to emit code. Recognizers' job is to just recognize. They accept lines, catch bad ones and channel good ones to the right place.
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

func labels() {
    match("l")
}

func types() {
    match("t")
}

func constants() {
    match("c")
}

func variables() {
    match("v")
}

func doProcedure() {
    match("p")
}

func doFunction() {
    match("f")
}

func declarations() {
    let decTypes : Set<Character> = Set(["l", "c", "t", "v", "p", "f"])
    while let cur = LOOK.cur, decTypes.contains(cur) {
        switch cur {
        case "l":
            labels()
        case "c":
            constants()
        case "t":
            types()
        case "v":
            variables()
        case "p":
            doProcedure()
        case "f":
            doFunction()
        default:
            break
        }
    }
}

/*:
 ## statements
 Grammatically, statements can begin with any identifier except `END`. It can also be represented like this
 ```
 BEGIN
    <statement>;
 END
 ```
 First stub for of statement can be written as below.
 */
func statements() {
    // `b` stands for `BEGIN`
    match("b")
    while let cur = LOOK.cur, cur != "e" {
        LOOK.getChar()
    }
    // `e` stands for `END`
    match("e")
}

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

func prog() {
    match("p")
    let name = getName()
    prolog()
    doBlock(name: name)
    match(".")
    epilog(name)
}

/*:
 ### BEGIN and END
 The compiler will now accept any number of declarations that are followed by the `BEGIN` block.
 
 IOW, the simplest form of input is
 ```
 pxbe.
 ```
 Try it and various other combinations!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pxbwhatsupe.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()

/*:
 ## End of Part 4
 
 At this point, we would have to expand `statements()` in order to make the compiler somewhat useful. The expansion would include things like `if/case/while/for` statements.
 
 But notice that we have already gone through this process of parsing assignment and control structures in previous chapters. **This is where the top level meets our previous bottom-up approach.** Constructs will be little different now but the differences are very minor.
 
 > So, **we will now stop trying to write a Pascal compiler.** Instead, we will now spend time making a **C Compiler**. Say whuuuutttt?
 */
