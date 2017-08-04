import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## Introduction
 
 We are going to go through the process one more time to build interpeters.
 Look at the the statement `x = 2 * y + 3`. 
 
 > In  our  compiler  so far, every  action  involves emitting object code, 
 to be executed later at execution time.  In an interpreter, every action
 involves  something  to be done immediately.
 
 In otherwords, the structure of the parser does not change. It's only
 the actions that change. So, if you can write a compiler for a language,
 you can also write an interpreter for it!
 
 The BIG difference is that because our end goal is different, procedures
 that do the recognizing is different. When recognizing procedures, interpreters
 return **FUNCTIONS** that return numeric values.
 
 ## Lazy Translation
 It's an idea that you don't just emit code at every action. Instead, you dont'
 emit anything **unless you really have to.**
 
 `x = x + 3 - 2 - (5 - 4)` will be reduced to `x = x + 0` during compiler time. Then
 to `x = x`, which requires no action at all. We won't be doing this here though 😜
 ,
 Just be aware  that  you  can get some code optimization by combining the
 techniques of compiling and  interpreting.
 
 ## So...
 To start, let's start with a BARE CRADLE and build it up from ground up.
 This time we are going to go faster though 🏃‍♂️🏃‍♂️🏃‍♂️
 */

let TAB : Character = "\t"
let addOp: [Character] = ["+", "-"]

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

/*:
 ## Returning Ints
 Since we are now actually doing the arithmetic, this
 will need to return an Int now
 */
func getNum() -> Int {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    
    let num = Int(String(LOOK.cur!))!
    LOOK.getChar()
    return num
}

/*:
 ## Changes in expression
 Right away, there is no `add` and `subtract` functions.
 The structure we have here is simple with a local `value`
 var keeping track of things.
 
 But this probably won't work for lazy evaluation.
 */
func expression() -> Int {
    var value: Int
    
    if let cur = LOOK.cur, addOp.contains(cur) {
        value = 0
    } else {
        value = getNum()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        switch cur {
        case "+":
            match("+")
            value += getNum()
        case "-":
            match("-")
            value -= getNum()
        default:
            expected("+ or -")
        }
    }
    
    return value
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3+2")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print("\(expression())")
