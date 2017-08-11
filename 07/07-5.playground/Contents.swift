import Foundation
/*:
 # LBaC
 # Part VII: Lexical Scanning
 ## Lists, Commas and Command Lines
 
 Most programs and OS's have rigid rules about how you must seperate items in a list.
 Some programs require spaces as delimiters and some require commas; and some require both!
 
 This is inexcusable since we can easily write a parser that can handle both spaces and commas
 in a flexible way.
 
 The biggest lesson here is this; even if you never wrote a line of compiler code in your life,
 there are places in every program where you can use concepts of parsing.
 */

let LF: Character  = "\n"
let TAB: Character = "\t"
let whiteChars: [Character] = [" ", TAB, LF]

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

func isOperator(_ c: Character) -> Bool {
    return ["+", "-", "*", "/", "<", ">", ":", "="].contains(c)
}

func isAlpha(_ c: Character) -> Bool {
    if "a"..."z" ~= c || "A"..."Z" ~= c {
        return true
    } else {
        return false
    }
}

func isDigit(_ c: Character) -> Bool {
    if "0"..."9" ~= c {
        return true
    } else {
        return false
    }
}

func isAlnum(_ c: Character) -> Bool {
    return isAlpha(c) || isDigit(c)
}

func isWhite(_ c: Character) -> Bool {
    return whiteChars.contains(c)
}

func skipWhite() {
    while let c = LOOK.cur, isWhite(c) {
        LOOK.getChar()
    }
}

/*:
 ## Skip over a comma
 This function will skip over any number of spaces with zero or more commas
 embedded within a string.
 */
func skipComma() {
    skipWhite()
    
    if let c = LOOK.cur, c == "," {
        LOOK.getChar()
        skipWhite()
    }
}

func fin() {
    if let cur = LOOK.cur, cur == "\n" {
        LOOK.getChar()
    }
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

func getName() -> String {
    var token = ""
    if let c = LOOK.cur, !isAlpha(c) {
        expected("Name")
    }
    
    while let c = LOOK.cur, isAlnum(c) {
        token += String(c).uppercased()
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func getNum() -> String {
    var token = ""
    if let c = LOOK.cur, !isDigit(c) {
        expected("Integer")
    }
    
    while let c = LOOK.cur, isDigit(c) {
        token += String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func getOp() -> String{
    var token = ""
    if let c = LOOK.cur, !isOperator(c) {
        expected("Operator")
    }
    
    while let c = LOOK.cur, isOperator(c) {
        token += String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func scan() -> String {
    var token = ""
    guard let c = LOOK.cur else { fatalError("EOF") }
    
    while let c = LOOK.cur, c == LF {
        fin()
    }
    
    if isAlpha(c) {
        token = getName()
    } else if isDigit(c){
        token = getNum()
    } else if isOperator(c) {
        token = getOp()
    } else {
        token = String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

/*:
 > Notice the user friendliness 😄
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "coffee <= tea\ncoffe + milk  ,, sugar = latte.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()

var token: String
repeat {
    token = scan()
    print(token)
} while(token != ".")
