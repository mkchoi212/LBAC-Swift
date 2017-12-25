//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 2: Groundwork
 
 Previous part's output was not much but we are getting there.
 
 But before we begin defining control structures, we need to lay some additional groundwork.
 Note that our syntax will look a bit like [Ada](https://en.wikibooks.org/wiki/Ada_Programming/Basic).
 
 `IF` statements look like the following in Ada and we'll be using the same format.
 ```
 IF <condition> <block A> ENDIF <block B>
 ```
 > We won't deal with the `else-clause` right now. That comes AFTER we do the `if-statement`!
 ### Labels
 At this point, we need some kind of concept that helps us keep track of various branches to make assembler programming easier. So, we will be using unique `label`s to help us organize them.
 
 This is because the above if-statement needs to be translated into the following assembly code
 ```
        Branch if NOT <Condition> to <Label>
        A
 Label: B
 ```
 > `Branch` instruction will branch | jump to the line in the code denoted by `Label:` if `NOT Condition` turns out to evaluate to `true`. Otherwise, it will continue going down the line; in this case, it will continue to execute `A`.
 */

/*:
 > This will be used to count the number of `label`s in use
 */
var LCNT: Int = 0

/*:
 ### newLabel()
 To remind you once more, labels allow us to keep track of various branches.
 
 This will generate unique labels in the form `LXX` where `XX` is the label number, provided by `LCNT`.
 */
func newLabel() -> String {
  let label = "L\(String(LCNT))"
  LCNT += 1
  return label
}

/*:
 ### postLabel()
 This function will write the label to the assembly code
 */
func postLabel(_ label: String) {
  emitLine(msg: "\(label):")
}

func other() {
  emitLine(msg: "\(LOOK.getName())")
}

func block() {
  while let cur = LOOK.cur, !(["e"].contains(cur)) {
    other()
  }
}

func program() {
  block()
  if let cur = LOOK.cur, cur != "e" {
    expected("End")
  }
  emitLine(msg: "END")
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "ae")
  LOOK.getChar()
  return LOOK
}

/*:
 ### So far...
 The output hasn't changed yet but we've set up some good foundation on which we can work on in the future.
 
 For future reference, the code we will write will look something like this...
 
 ```
 IF
 <condition>    { eval_condition()
                  let l = newLabel()
                  emitMsg(Branch False to L); }
 
 <block>
 
 ENDIF          { postLabel(l) }
 ```
 */
var LOOK = initialize()
program()

//: [Next](@next)
