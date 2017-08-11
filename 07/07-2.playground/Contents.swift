import Foundation
/*:
 # LBaC
 # Part VII: Lexical Scanning
 ## White Space
 We will add a little bit of white space support before we go any further.
 
 Also, we will recognize a carriage return (newline) as a terminating character for now.
 */

let LF = "\n"
let TAB : Character = "\t"
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

/*:
 `isWhite` and `skipWhite` has been directly copied from `03-4.playground`
 
 > Notice that they have been added to the end of `getName` and `getNum`
 */
func isWhite(_ c: Character) -> Bool {
    return whiteChars.contains(c)
}

func skipWhite() {
    while let c = LOOK.cur, isWhite(c) {
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

/*:
 ## Lexical scanner wrapping it all
 */
func scan() -> String {
    var token = ""
    guard let c = LOOK.cur else { fatalError("EOF") }
    
    if isAlpha(c) {
        token = getName()
    } else if isDigit(c){
        token = getNum()
    } else {
        token = String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3123  abc    xyz\n")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()

/*:
 ## Multiple token support
 */
var token: String
repeat {
    token = scan()
    print(token)
} while(token != LF)

/*:
 ## State Machines
 Before we go on, let's briefly talk about state machines.
 
 Talking about state machines, `getName` in fact implements a state machine; the state being the current
 position in the code.
 
 If we look at what is going on in its entirety, we can see a state machine. Take for example, things
 begin in the start of the state and end when a non alphanumeric character is found. Otherwise, the
 "machine" wioll continue looping until a terminating delimiter is found.
 
 Note that our position in the code we are parsing is entirely dependent on the past history of input
 characters. At that point, the only action to be taken depends on the current state plus the
 `LOOK.cur`. This is what makes our code a **state machine**.
 
 We didn't talk about it but `skipWhite` and `getNum` are both state machines, just like its
 parent function `scan`.
 
 > Keep in mind that **little machines make up big machines.**
 */
