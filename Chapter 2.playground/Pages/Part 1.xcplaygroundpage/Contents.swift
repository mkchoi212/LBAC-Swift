/*:
 # LBaC 
 # Chapter II: Expression Parsing
 ## Part 1: Single Digits
 
 Welcome to the first part of the tutorial 🎉🎉🎉
 
 Here will parse and translate mathematical expressions.
 What we eventually want is to output serires of aseembler-language statements
 that perform certain actions.

 > Remember `Cradle.swift` from the first chapter? **We'll be using the cradle in EVERY SINGLE CHAPTER. Because of this, it has been stowed away into the `Sources` folder to de-clutter the Playground 😀**
 */

/// Parse and translate a math expression
func expression() {
    emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
}

/*:
 ## First Run 😝
 In the beginning, we are keeping it simple and starting with a **single digit.**
 Try any single-digit number in `LOOK`'s `input` in `initialize()` and look at its output.
 
 Congratulations! You just wrote a working translator 🎉🎉🎉
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3")     // Try any single-digit number input!
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()


//: [Next](@next)
