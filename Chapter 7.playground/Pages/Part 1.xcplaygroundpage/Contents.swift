/*:
 # LBaC
 # Chapter VII: Lexical Scanning
 ## Part 1: Introduction
 
 > You should actually read `Resources/tutor7.txt` for this one. It has more information regarding the theory behind lexers and various alternatives.
 >
 > I highly recommend you go read `tutor7.txt` from the beginning to `Some Experiments in Scanning` if you have time.
 
 ### TL;DR
 We talked about how we are going to have to create this new thing called a "Lexer" at the end of the previous chapter. But why do we need this new thing called "Lexer" when we did just fine without it?
 
 **We need lexers if we want to support multi-character keywords in our language**. Because let's be real, single-character parsers get old, real quick.
 
 Syntax for a keyword has the same form as any other identifier in a program.
 Take this for example. Variable `IFILE` and the keyword `IF` look identical until we get to the third character.
 The times when we were able to make a decision based on the first character is long
 gone. **We now need to know the ENTIRE WORD before we begin to process it. And this is exactly why we need a scanner.**
 
 > Lexical scanning is the process of scanning a stream of input characters and separating it  into strings called *tokens*
 
 Basically, the lexical scanner deals with things at the character level and passes them along to the parser as indivisible tokens.
 
 ## Experimentation
 Starting from the bare cradle, we will try to scan for basic variables and numbers.
 */


/*:
 ### getName()
 With a simple update, `getName` now parses tokens and returns a `String` instead of a `Character`
 */
func getName() -> String {
    var token = ""
    if let c = LOOK.cur, !isAlpha(c) {
        expected("Name")
    }
    
    while let c = LOOK.cur, isAlphaNum(c) {
        token += String(c).uppercased()
        LOOK.getChar()
    }
    return token
}

/*:
 ### getNum()
 Same thing with `getNum`. We now support numbers bigger than `9` 🎉
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

/*:
 ### So far..
 Verify that the new `get___()` is working and is returning "tokens"
 
 > Try it with various inputs!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3123")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print(">> \(getNum())")
//: [Next](@next)
