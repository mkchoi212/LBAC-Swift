import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## Interpreting...

 Continuing from what we did previously in 4-1...
 
 We are going to implement `term()` and allow multi-digit inputs once again!
 */

let TAB : Character = "\t"
let addOp: [Character] = ["+", "-"]
let mulOp: [Character] = ["*", "/"]

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
 ## Let's allow multi-digit inputs!
 */
func getNum() -> Int {
    var value = 0
    
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    
    while isDigit(LOOK.cur) {
        value = (10 * value) + Int(String(LOOK.cur!))!
        LOOK.getChar()
    }
    
    return value
}

func term() -> Int {
    var value = getNum()

    while let cur = LOOK.cur, mulOp.contains(cur) {
        switch cur {
        case "*":
            match("*")
            value *= getNum()
        case "/":
            match("/")
            value /= getNum()
        default:
            expected("* or /")
        }
    }
    
    return value
}

/*:
 ## Implementing term
 Every single call to `getNum()` has been switched
 to `term()`, just like we did when we built the compiler.
 
 > Keep in mind that we are doing integer division, `1/3` will be `0`.
 */
func expression() -> Int {
    var value: Int
    
    if let cur = LOOK.cur, addOp.contains(cur) {
        value = 0
    } else {
        value = term()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        switch cur {
        case "+":
            match("+")
            value += term()
        case "-":
            match("-")
            value -= term()
        default:
            expected("+ or -")
        }
    }
    
    return value
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "60/3")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print("\(expression())")
