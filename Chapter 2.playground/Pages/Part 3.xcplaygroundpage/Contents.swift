//: [Previous](@previous)
import Foundation

/*:
 # LBaC
 # Chapter II: Expression Parsing
 ## Part 3: Using the Stack / Multiplication and Division
 
 So far, we have been using only wo registers for storing terms.
 It works fine when we are doing `3-2` but what if we want to do something like
 
 ```
 1+(2-(3+(4-5)))
 ```

 To solve this, we will use the **CPU stack** in order to store many variables.
 
 This is a NEARLY functional parser/translator! The output is starting to look like something real 🎉🎉🎉
 */

let TAB: Character = "\t"
let addOp : [Character] = ["+", "-"]
let mulOp : [Character] = ["*", "/"]

func factor() {
    emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
}

/*:
 ### * / + - operations

 
 Instead of moving terms into `D0` and `D1` registers, we are now just pushing them onto the stack.

 > Notice how each operation now uses `-(SP)` and `(SP)+`.
 >
 > In the 68000 asm language, `-(SP)` is a push and `(SP)+` is a pop.
 */
func multiply() {
    LOOK.match("*")
    factor()
    emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
    LOOK.match("/")
    factor()
    emitLine(msg: "MULS (SP)+,DO")
    emitLine(msg: "DIVS D1, D0")
}

func add() {
    LOOK.match("+")
    term()
    emitLine(msg: "ADD (SP)+,D0")
}

func subtract() {
    LOOK.match("-")
    term()
    emitLine(msg: "SUB (SP)+,D0")
    emitLine(msg: "NEG D0")
}

/*:
 ### term()
 You know how when you are given an expression like
 ```
 2 + 3 * 4
 ```
 you are supposed to multiply first and then add?
 
 In the past, people used really complex methods to make this happen but turns out, it's really easy to insure operator precedence rules with our top-down parsing technique!
 
 Until now, we have defined a `term` to be a single number. But we are going to define a `term` as a **PRODUCT OF FACTORS**.
 
 > `factor` is what term used to be, a single digit.
 > Also, notice how `term` looks almost identical to `expression`.
 */
func term() {
    factor()
    
    while let cur = LOOK.cur, mulOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "*":
            multiply()
        case "/":
            divide()
        default:
            expected("* or /")
        }
    }
}

/*:
 ### expression
 Checks for `term`s before checking if `+` or `-` exists in the expression to ensure operator precedence!
 */
 
func expression() {
    // Check for `*` and `/` first!
    term()
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "+":
            add()
        case "-":
            subtract()
        default:
            expected("+ or -")
        }
    }
}

/*:
 ## So far...
 We almost have a functional parser/translator!!!
 
 The output is starting to look useful; if you ignore the inefficiency 😅😅😅
 > If you feel lost, I suggest you go read `tutor2.txt`. But I guarantee you will catch on to the concepts as we go further into the tutorial!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3+2/2")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
expression()
//: [Next](@next)
