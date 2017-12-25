/*:
 # LBaC
 # Chapter VI: Boolean Expressions
 ## Part 1: The Plan
 
 > **TL;DR** We will remove the option of parenthesized boolean expressions as a possible boolean factor
 
 In the previous chapter, we looked at control constructs but didn't handle the branch conditions within those constructs. Instead we filled in the gap with a dummy function `condition()`.
 
 In this section, we will replace that dummy function with a real one! Yay
 
 The first thing we have realize is how boolean and algebraic operators are different.
 
 ```
 a * - b
 ```
 is not allowed since the `-` operator is considered to go with an entire term. IOW, the expression technically should be
 ```
 (a*) - b
 ```
 which doesn't make any sense.
 
 But in **boolean algebra**
 ```
 a AND NOT b
 ```
 makes perfect sense.
 
 Ok, so we know the difference main syntactic difference between arithmetic and boolean algebra
 but *how do we establish a syntax rule for both of them* so that we can do stuff like this?
 ```
 IF (x >= 0) and (x <= 100) THEN ...
 ```
 
 If we look at relational operators, it's syntactic notation is
 ```
 <relation> ::= <expression> <relop> <expression>
 ```
 where the result is a single boolean value.
 
 So, we can say that this is just another kind of factor.
 
 The big thing to note here is that **while relational expressions seem arithematic in nature with their
 numeric values, they evaluate to boolean values. And because of this, they act as a bridge between
 arithmetic and boolean algebra.**
 
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
 
 Wow.... that is a lot to take in... 😱
 Anyways... that's it for the theory so let's start from a blank cradle
 */

/*:
 ### isBoolean()
 Boolean in our program are either `T` or `F`
 */
func isBoolean(_ c: Character) -> Bool {
    return ["T","F"].contains(String(c).uppercased())
}

/*:
 ### getBoolean()
 This reads a new boolean token
 */
func getBoolean() -> Bool {
    if let cur = LOOK.cur, !isBoolean(cur) {
        expected("Boolean Literal")
    }
    
    let boolVal = String(LOOK.cur!).uppercased() == "T"
    LOOK.getChar()
    return boolVal
}

/*:
 ### boolExpression()
 Remember how we used to store numeric data into register `D0` in previous chapters?
 We need to do the same thing with boolean expressions.
 
 The data we are going to store into the registers will have the following definitions
 ```
 FFFF == -1 -> TRUE
 0 -> FALSE
 ```
 This is because `^FFFF == 0` where `^` is a bitwise NOT and this makes it easier to covert between `T` and `F`.
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

/*:
 ### So far...
 We can parse a single boolean expression! Yaaaayyyyy!!!
 
 More is to come so stay tuned 😜
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "T")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
boolExpression()
//: [Next](@next)
