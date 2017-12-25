//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VI: Boolean Expressions
 ## Part 2: Expansion
 
 In this part, we will expand upon the boolean definition of an `expression`.
 ```
 <b-expression> ::= <b-term> [<orop> <b-term>]*
 ```
 It may look complicated but it means that we want to be able to chain multiple `terms` with `orops`.
 `orop`s represent boolean operations like `| -> OR` and `~ -> XOR`.
 
 An example of the expression we want to parse in this part is
 ```
 a | b | c ~ d
 ```
 */

/*:
 ### isOrOp
 Once again
 ```
 | -> OR
 ~ -> XOR
 ```
 */
func isOrOp(_ c: Character) -> Bool {
  return ["|", "~"].contains(c)
}

/*:
 ### boolOr()
 */
func boolOr() {
  LOOK.match("|")
  boolTerm()
  emitLine(msg: "OR (SP)+,D0")
}

/*:
 ### boolXor()
 */
func boolXor() {
  LOOK.match("~")
  boolTerm()
  emitLine(msg: "EOR (SP)+,D0")
}

/*:
 ### relation()
 All non-boolean factors are handled by this dummy function.
 */
func relation() {
  emitLine(msg: "<Relation>")
  LOOK.getChar()
}

/*:
 ### boolFactor()
 This is just a boolean version of `factor()` we have been using all along.
 */
func boolFactor() {
  if let cur = LOOK.cur, isBoolean(cur) {
    if LOOK.getBoolean() {
      emitLine(msg: "MOVE #-1,D0")
    } else {
      emitLine(msg: "CLR D0")
    }
  } else {
    relation()
  }
}

/*:
 ### notFactor()
 `!` is used to denote a not.
 
 Notice how a `boolFactor` must follow a `!`.
 */
func notFactor() {
  if let cur = LOOK.cur, cur == "!" {
    LOOK.match("!")
    boolFactor()
    emitLine(msg: "EOR #-1,D0")
  } else {
    boolFactor()
  }
}

/*:
 ### boolTerm()
 */
func boolTerm() {
  notFactor()
  while let cur = LOOK.cur, cur == "&" {
    emitLine(msg: "MOVE D0,-(SP)")
    LOOK.match("&")
    notFactor()
    emitLine(msg: "AND (SP)+,D0")
  }
}

/*:
 ### boolExpression()
 Notice `|` and `~` have been added to the list of possible operators.
 */
func boolExpression() {
  boolTerm()
  while let cur = LOOK.cur, isOrOp(cur) {
    emitLine(msg: "MOVE D0,-(SP)")
    switch cur {
    case "|":
      boolOr()
    case "~":
      boolXor()
    default:
      expected("| or ~")
    }
  }
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "Z|T|!F&W")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
boolExpression()

/*:
 ### So far...
 We can now parse `AND, ORs, NOTS`!
 
 Also, every *non-boolean* character is replaced by a `<Relation>` placeholder.
 But do not worry as we will implement the full version of `relation` in the next part 🚀🚀🚀
 */

//: [Next](@next)
