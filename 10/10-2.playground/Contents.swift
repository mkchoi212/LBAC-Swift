import Foundation
/*:
 # LBaC
 # Part X: Introducing "TINY"
 ## Part 2: Begin Blocks
 When processing code in the main program, we will use **BEGIN-blocks** from Pascal.
 
 We could also require a *name* for the program like such
 ```
 BEGIN <name>
 END <name>
 ```
 to make things clear. But this is just **syntactic sugar**. You can add this later if you'd like to.
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

func header() {
    emitLine(msg: "WARMST\tEQU $A01E")
}

func prolog() {
    postLabel("MAIN")
}

func epilog() {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END MAIN")
}

/*:
 ### BEGIN-block
 ```
 BEGIN
 <MAIN PROGRAM>
 END
 ```
 */

func main() {
    match("b")
    prolog()
    match("e")
    epilog()
}

/*:
 ### Updated prog()
 > We combined `prolog` and `epilog` into `main` and added BEGIN-blocks
 */
 
func prog() {
    match("p")
    header()
    main()
    match(".")
}

/*:
 ## So far...
 ```
 PROGRAM
 BEGIN
 END
 .
 ```
 or `pbe.` is the only legal program.
 
 We are rolling with steam and making progress 🚂🚂🚂.
 
 > Try deliberately making errors and see what happens; like leaving out a `b`. The compiler should catch errors!!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pbe.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
