import Foundation
/*:
 # LBaC
 # Part X: Introducing "TINY"
 ## Part 5: Initializers

 So Pascal doesn't allow you to initialize data items in the declaration... doesn't that bother you?
 
 We'll fix that here 😎
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

/*:
 ### getNum()
 Now supports multi-digit integers!
 */
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
 Six added lines and now you can initialize variables with **signed and unsigned integers** 🎉🎉🎉
 */
func alloc(_ n: Character) {
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
    header()
    topDecl()
    main()
    match(".")
}

/*:
 ## So far...
 
 Things are starting to look real! The program doesn't really do anything useful but still!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b=123,c=-456be.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
