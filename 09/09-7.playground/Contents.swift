import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 7: C (continued)

 Let's make `getClass` and `getType` do something more interesting...
 
 > Global variables `CLASS`, `SIGN` and `TYPE` have been created
 */

var CLASS : Character!
var SIGN : Character!
var TYPE: Character!

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

/*:
 ### getClass()
 Three single characters are used to represent storage classes
 - a - `auto`
 - x - `extern`
 - s - `static`
 
 We are missing `register` and `extern` but we will ignore them for now.
 
 > Default class is `a` or `auto`
 */
func getClass() {
  if let cur = LOOK.cur, ["a", "x", "s"].contains(cur) {
    CLASS = cur
    LOOK.getChar()
  } else {
    CLASS = "a"
  }
}

/*:
 ### getType()
 
 We will do something very similar to `getClass` with `getType`
  - u - `unsigned`
  - s - `signed`
  - i - `int`
  - l - `long`
  - c - `char`
 */
func getType() {
  TYPE = " "
  if let cur = LOOK.cur, cur == "u" {
    SIGN = "u"
    TYPE = "i"
    LOOK.getChar()
  } else {
    SIGN = "s"
  }
  
  if let cur = LOOK.cur, ["i", "l", "c"].contains(cur) {
    TYPE = cur
    LOOK.getChar()
  }
}

func topDecl() {
    LOOK.getChar()
}

func prog() {
    while LOOK.cur != nil {
      getClass()
      getType()
      topDecl()
    }
}

/*:
 `sih == static int h`
 
 We have long ways to go.
 
 For example, there are many complexities involving just the definition of a type, before we can start talking about actual data/function names.
 
 > But for now, we will ignore all of those complexities; for the sake of swift learning!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "sih")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
