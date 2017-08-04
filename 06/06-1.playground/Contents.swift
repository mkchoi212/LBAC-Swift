import Foundation

/*:
 # LBaC
 # Part VI: Boolean Expressions
 ## The Plan
 
 **TL;DR** We will remove the option of parenthesized boolean expressions as a possible boolean factor
 
 In part V, we took a look at control constructs but didn't handle branch conditions. Instead
 we filled in the gap with a dummy function `condition()`. In this section, we will replace that
 dummy function with a real one!
 
 The first thing is to note how boolean and algebraic operators are different.
 For example,
 
 ```
 a * - b
 ```
 
 is not allowed since unary minus is considered to go with an entire term. But in *boolean
 algebra*
 
 ```
 a AND NOT b
 ```
 
 makes perfect sense.
 
 Ok, so we know the difference main syntactic difference between arithmetic and boolean algebra
 but how do we establish a syntax rule for both of them so that we can do stuff like
 ```
 IF (x >= 0) and (x <= 100) THEN ...
 ```
 in our control constructs?
 
 If we look at relational operators, it's BNF is
 ```
 <relation> ::= <expression> <relop> <expression>
 ```
 where the result is a single boolean value. So, we can say that this is just another kind of factor.
 The big thing to note here is that while relational expressions seem arithematic in nature with their
 numeric values, they evaluate to boolean values. And because of this, they act as a bridge between
 arithmetic and boolean algebra.
 
 But, if we go ahead and apply this rule to a parser and try to parse the following
 ```
 IF ((((((A + B + C) < 0 ) AND ....
 ```
 it won't work. The reason is because when the compiler has read upto the `IF` token, it is expecting a
 boolean expression. But the first expression it comes to is `A + B + C`, which an ARITHMETIC expression.
 To fix this, we need to make a BIG change to the grammar; **we can only allow parentheses in one kind of
 factor.**
 
 Various languages do this differently but we will choose to remove the option of parenthesized boolean
 expressions as a possible boolean factor; the way C does it. We will also add relational expressions
 as a form of boolean factors.
 
 Also, the newly defined relation BNF
 ```
 <relation>     ::= | <expression> [<relop> <expression]
 ```
 says that the relational operator and the second expression are all optional. The consequence of this
 is that every expression is potential a booelan expression; this is why `if(100)` is valid in C.
 
 That's it for the theory so let's start from a blank cradle 😌😌
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

/*:
 ## New boolean input tokens
 `T` and `F`
 */
func isBoolean(_ c: Character) -> Bool {
    return ["T","F"].contains(String(c).uppercased())
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
 ## Read new boolean token
 */
func getBoolean() -> Bool {
    if let cur = LOOK.cur, !isBoolean(cur) {
        expected("Boolean Literal")
    }
    
    let boolVal = String(LOOK.cur!).uppercased() == "T"
    LOOK.getChar()
    return boolVal
}

func getName() -> Character {
    if let cur = LOOK.cur, !isAlpha(cur) {
        expected("Name")
    }
    let upper = String(LOOK.cur!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

func getNum() -> Character {
    if let cur = LOOK.cur, !isDigit(cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

/*:
 ## Generating ASM
 Like we stored numeric data into register `D0`, we need to do the same with boolean expressions.
 We are going to use
 - `FFFF` or `-1` -> `TRUE`
 - `0` -> `FALSE`
 
 Because `^FFFF == 0` where `^` is a bitwise NOT.
 */
func boolExpression() {
    if let cur = LOOK.cur, !isBoolean(cur) {
        expected("Boolean literal")
    }
    
    if getBoolean() {
        emitLine(msg: "MOVE #-1,D0")
    } else {
        emitLine(msg: "CLR D0")
    }
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "T")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
boolExpression()

