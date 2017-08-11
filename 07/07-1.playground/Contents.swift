import Foundation
/*:
 # LBaC
 # Part VII: Lexical Scanning
 ## Introduction
 
 > The `tutor7.txt` file has more information regarding the theory behind lexers and various alternatives.
 I highly recommend you to go read the sections until `Some Experiments in Scanning` if you have time
 
 **TL;DR**
 
 Why do we need this new thing called "Lexer" when we did just fine without it when we
 had to deal with multi-character tokens in the past?
 **The ONLY reason has to do with keywords**.
 
 Syntax for a keyword has the same form as any other identifier in a
 program. Take this for example. Variable `IFILE` and the keyword `IF` look identical until we get to
 the thrid character. The times when we were able to make a decision based on the first character is long
 gone. We need to know the ENTIRE WORD before we begin to process it. That's why we need a scanner.
 
 > Lexical scanning is the process of scanning the  stream  of input characters and separating it  into
 strings  called tokens
 
 Basically, the lexical scanner deals with things at the character level and passes them along tothe
 parser proper as indivisible tokens.
 
 ## Experimentation
 Starting from the bare cradle, we will try to scan for basic variables and numbers.
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

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

/*:
 ## Updated `getName`
 Now parses tokens and returns a `String` instead of a `Character`
 */
func getName() -> String {
    var token = ""
    if let c = LOOK.cur, !isAlpha(c) {
        expected("Name")
    }
    
    while let c = LOOK.cur, isAlnum(c) {
        token += String(c).uppercased()
        LOOK.getChar()
    }
    return token
}

/*:
 ## Updated `getNum`
 Now parsing tokens as well
 */
func getNum() -> String {
    var token = ""
    if let c = LOOK.cur, !isDigit(c) {
        expected("Integer")
    }
    
    while let c = LOOK.cur, isDigit(c) {
        token += String(c)
        LOOK.getChar()
    }
    return token
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3123")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
/*:
 Verify that the new `get___()` is working and is returning "tokens"
 
 Try it with various inputs!
 */
print(getNum())
