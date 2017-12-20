import Foundation
/*:
 # LBaC
 # Part X: Introducing "TINY"
 ## Part 4: Declarations and Symbols
 
 Let's produce some actual code for declarations!
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

func main() {
    match("b")
    prolog()
    match("e")
    epilog()
}

/*:
 ### alloc()
 Just writes command to assembler to allocate storage. Nothing to it.
 */
func alloc(_ n: Character) {
    emitLine(msg: "\(n):\tDC 0")
}

/*:
 ### decl()
 Let's allocate the variable now!
 
 And since TINY supports a variable list as such
 ```
 var a, b, c, d
 ```
 let's make that happen as well.
 */
func decl() {
    match("v")
    alloc(getName())
    while let cur = LOOK.cur, cur == "," {
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
    header()
    topDecl()
    main()
    match(".")
}

/*:
 ## So far...
 Notice the output of the Playground to see how variables are allocated.
 
 > A "real" compiler would also have a symbols table. We will ignore them for now until we need to make one.
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b,cbe.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
