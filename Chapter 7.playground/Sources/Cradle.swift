import Foundation

public let TAB: Character = "\t"
public let LF: Character  = "\n"
let whiteChars: [Character] = [" ", TAB, LF]


public struct Buffer {
  var idx: Int
  public var cur: Character?
  let input: String
  
  public init(idx: Int, cur: Character?, input: String) {
    self.idx = idx
    self.cur = cur
    self.input = input
  }
}

public extension Buffer {
  init() {
    idx = 0
    input = readLine()!
  }
  
  public mutating func getChar() {
    let i = input.index(input.startIndex, offsetBy: idx)
    
    if i == input.endIndex {
      cur = nil
    } else {
      cur = input[i]
      idx += 1
    }
  }
}

public extension Buffer {
  mutating func match(_ c: Character) {
    if cur == c {
      getChar()
    } else {
      expected("\(c)")
    }
  }
  
  mutating func getName() -> String {
    var token = ""
    if let c = cur, !isAlpha(c) {
      expected("Name")
    }
    
    while let c = cur, isAlphaNum(c) {
      token += String(c).uppercased()
      getChar()
    }
    
    while let c = cur, isWhite(c) {
      getChar()
    }
    return token
  }
  
  mutating func getNum() -> String {
    var token = ""
    if let c = cur, !isDigit(c) {
      expected("Integer")
    }
    
    while let c = cur, isDigit(c) {
      token += String(c)
      getChar()
    }
    
    while let c = cur, isWhite(c) {
      getChar()
    }
    return token
  }
}

public func error(msg: String) {
  print("Error: \(msg).")
}

public func abort(msg: String) {
  error(msg: msg)
  exit(EXIT_FAILURE)
}

public func expected(_ s: String) {
  abort(msg: "\(s) expected")
}

public func emit(msg: String) {
  print("\(TAB) \(msg)", separator: "", terminator: "")
}

public func emitLine(msg: String) {
  print("\(TAB) \(msg)")
}

public func isAlpha(_ c: Character?) -> Bool {
  if let c = c, "a"..."z" ~= c || "A"..."Z" ~= c {
    return true
  } else {
    return false
  }
}

public func isDigit(_ c: Character?) -> Bool {
  if let c = c, "0"..."9" ~= c {
    return true
  } else {
    return false
  }
}

public func isAlphaNum(_ c: Character?) -> Bool {
  return isAlpha(c) || isDigit(c)
}

public func isWhite(_ c: Character) -> Bool {
  return whiteChars.contains(c)
}

