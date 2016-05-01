// Whiteplanes.swift
//
// Copyright (c) 2016 Takuya Katsurada ( https://github.com/nutcrack )
//
// Permissinteractiven is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentatinteractiven files (the "Software"), to deal
// in the Software without restrictinteractiven, including without limitatinteractiven the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditinteractivens:
//
// The above copyright notice and this permissinteractiven notice shall be included in
// all copies or substantial portinteractivens of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTinteractiveN OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTinteractiveN WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// The protocol used as a context of state in Whiteplanes.
public protocol Contextable {
    /// The program counter.
    var counter: Int { get set }
    /// The stack area.
    var stack : [Int] { get set }
    /// The heap area.
    var heap : [Int:Int] { get set }
    /// The bracemap.
    var bracemap : [String:Int] { get set }
    /// The bracestack(jumptable).
    var bracestack : [Int] { get set }
}

/// The protocol used as a interaction calling method.
public protocol Interable {
    /// The input method(For number).
    func inputCalling () -> Int
    /// The input method(For character).
    func inputCalling () -> Character
    /// The output method(For number).
    func outputCalling (chr : Int)
    /// The output method(For character).
    func outputCalling (chr : Character)
}


/// The command protocol.
private protocol Command : CustomStringConvertible {
    /// Execute the command.
    func exec(var context : Contextable, interactive : Interable?)
}

/**
 A `Whiteplanes` object is a whitespace interpreter writen in swift.
 You can create interpreter object from files.
 
 __Whitespace__
 Whitespace is an esoteric programming language developed by Edwin Brady and Chris Morris
 at the University of Durham (also developers of the Kaya and Idris programming languages).
 It was released on 1 April 2003 (April Fool's Day).
 Its name is a reference to whitespace characters. Unlike most programming languages,
 which ignore or assign little meaning to most whitespace characters,
 the Whitespace interpreter ignores any non-whitespace characters.
 Only spaces, tabs and linefeeds have meaning.
 An interesting consequence of this property is that a Whitespace program
 can easily be contained within the whitespace characters of a program written in another language,
 except possibly in languages which depend on spaces for syntax validity such as Python,
 making the text a polyglot.
 
 The language itself is an imperative stack-based language.
 The virtual machine on which the programs run has a stack and a heap.
 The programmer is free to push arbitrary-width integers onto the stack
 (currently there is no implementation of floating point numbers)
 and can also access the heap as a permanent store for variables and data structures.
 */
public class Whiteplanes {
    /// The None character (Never use access)
    static let NONE    : Character = "\r"
    /// The Space character.
    static let SPACE   : Character = " "
    /// The Tab character.
    static let TAB     : Character = "\t"
    /// The Newline character.
    static let NEWLINE : Character = "\n"
    
    // The Runtime error
    enum RuntimeError : ErrorType {
        case Syntax(String)
        case Overflow(String)
    }
    
    /// The source code.
    public var code : String! = nil
    
    /// The command list to be executed.
    private var commands : [Command]? = nil
    
    /// The delegate.
    public var delegate : Interable? = nil
    
    /**
     A Parser object is a whitespace parser.
     */
    private class Parser {
        
        typealias Token = (Character, Character, Character, Character)
        
        /// The parse target.
        private let source : [Character]
        
        /// The current index
        private var current = 0
        
        /**
         Creates a whitespace parser.
         
         - parameter source:  The source code
         - returns:           The parser instance
         */
        init (source : [Character]) {
            self.source = source
        }
        
        /**
         Parse a whitespace source.
         
         - returns:  The command list.
         */
        func parse() throws -> [Command] {
            
            /// Get the literal code.
            func literal() throws -> String {
                var newValue = ""
                
                while current < source.count {
                    let code = source[current++]
                    switch code {
                    case Whiteplanes.SPACE:   newValue += "0"
                    case Whiteplanes.TAB:     newValue += "1"
                    case Whiteplanes.NEWLINE: return newValue
                    default:
                        break
                    }
                }
                throw RuntimeError.Syntax("Syntax error")
            }
            
            var commands = [Command]()
            
            while current < source.count {
                switch token() {
                /// PUSH:
                case (Whiteplanes.SPACE, Whiteplanes.SPACE, _, _):
                    current += 2
                    let command   = Push()
                    command.value = Int(try literal(), radix: 2)!
                    commands.append(command)
                /// COPY:
                case (Whiteplanes.SPACE, Whiteplanes.TAB, Whiteplanes.SPACE, _):
                    current += 3
                    let command   = Copy()
                    command.value = Int(try literal(), radix: 2)!
                    commands.append(command)
                /// SLIDE:
                case (Whiteplanes.SPACE, Whiteplanes.TAB, Whiteplanes.NEWLINE, _):
                    current += 3
                    let command   = Slide()
                    command.value = Int(try literal(), radix: 2)!
                    commands.append(command)
                /// DUPLICATE:
                case (Whiteplanes.SPACE, Whiteplanes.NEWLINE, Whiteplanes.SPACE, _):
                    current += 3
                    commands.append(Duplicate())
                /// SWAP:
                case (Whiteplanes.SPACE, Whiteplanes.NEWLINE, Whiteplanes.TAB, _):
                    current += 3
                    commands.append(Swap())
                /// DISCARD:
                case (Whiteplanes.SPACE, Whiteplanes.NEWLINE, Whiteplanes.NEWLINE, _):
                    current += 3
                    commands.append(Discard())
                /// ADD:
                case (Whiteplanes.TAB, Whiteplanes.SPACE, Whiteplanes.SPACE, Whiteplanes.SPACE):
                    current += 4
                    commands.append(Add())
                /// SUB:
                case (Whiteplanes.TAB, Whiteplanes.SPACE, Whiteplanes.SPACE, Whiteplanes.TAB):
                    current += 4
                    commands.append(Sub())
                /// MUL:
                case (Whiteplanes.TAB, Whiteplanes.SPACE, Whiteplanes.SPACE, Whiteplanes.NEWLINE):
                    current += 4
                    commands.append(Mul())
                /// DIV:
                case (Whiteplanes.TAB, Whiteplanes.SPACE, Whiteplanes.TAB, Whiteplanes.SPACE):
                    current += 4
                    commands.append(Div())
                /// MOD:
                case (Whiteplanes.TAB, Whiteplanes.SPACE, Whiteplanes.TAB, Whiteplanes.TAB):
                    current += 4
                    commands.append(Mod())
                /// STORE
                case (Whiteplanes.TAB, Whiteplanes.TAB, Whiteplanes.SPACE, _):
                    current += 3
                    commands.append(Store())
                /// RETRIEVE
                case (Whiteplanes.TAB, Whiteplanes.TAB, Whiteplanes.TAB, _):
                    current += 3
                    commands.append(Retrieve())
                /// REGISTER
                case (Whiteplanes.NEWLINE, Whiteplanes.SPACE, Whiteplanes.SPACE, _):
                    current += 3
                    let command      = Register()
                    command.name     = try literal()
                    command.location = commands.count
                    commands.append(command)
                /// CALL
                case (Whiteplanes.NEWLINE, Whiteplanes.SPACE, Whiteplanes.TAB, _):
                    current += 3
                    let command      = Call()
                    command.name     = try literal()
                    command.location = commands.count
                    commands.append(command)
                /// JUMP
                case (Whiteplanes.NEWLINE, Whiteplanes.SPACE, Whiteplanes.NEWLINE, _):
                    current += 3
                    let command      = Jump()
                    command.name     = try literal()
                    commands.append(command)
                /// TEST (if push == 0)
                case (Whiteplanes.NEWLINE, Whiteplanes.TAB, Whiteplanes.SPACE, _):
                    current += 3
                    let command      = ETest()
                    command.name     = try literal()
                    commands.append(command)
                /// TEST (if push < 0)
                case (Whiteplanes.NEWLINE, Whiteplanes.TAB, Whiteplanes.TAB, _):
                    current += 3
                    let command      = NTest()
                    command.name     = try literal()
                    commands.append(command)
                /// RETURN
                case (Whiteplanes.NEWLINE, Whiteplanes.TAB, Whiteplanes.NEWLINE, _):
                    current += 3
                    commands.append(Return())
                /// END
                case (Whiteplanes.NEWLINE, Whiteplanes.NEWLINE, Whiteplanes.NEWLINE, _):
                    current += 3
                    commands.append(End())
                /// OUTPUT
                case (Whiteplanes.TAB, Whiteplanes.NEWLINE, Whiteplanes.SPACE, Whiteplanes.SPACE):
                    current += 4
                    commands.append(COutput())
                /// OUTPUT
                case (Whiteplanes.TAB, Whiteplanes.NEWLINE, Whiteplanes.SPACE, Whiteplanes.TAB):
                    current += 4
                    commands.append(IOutput())
                /// INPUT
                case (Whiteplanes.TAB, Whiteplanes.NEWLINE, Whiteplanes.TAB, Whiteplanes.SPACE):
                    current += 4
                    commands.append(CInput())
                /// INPUT
                case (Whiteplanes.TAB, Whiteplanes.NEWLINE, Whiteplanes.TAB, Whiteplanes.TAB):
                    current += 4
                    commands.append(IInput())
                default:
                    throw RuntimeError.Syntax("Syntax error")
                }
            }
            return commands
        }
        
        /**
         Get a next token.
         
         - returns:  The token type.
         */
        private func token() -> Token {
            switch (current + 3) - source.count {
            case 2:  return (source[current], Whiteplanes.NONE,     Whiteplanes.NONE,     Whiteplanes.NONE)
            case 1:  return (source[current], source[current + 1], Whiteplanes.NONE,     Whiteplanes.NONE)
            case 0:  return (source[current], source[current + 1], source[current + 2], Whiteplanes.NONE)
            default: return (source[current], source[current + 1], source[current + 2], source[current + 3])
            }
        }
        
    }
    
    /// The Push Command.
    private class Push : Command {
        var value : Int = 0
        /// A textual representation of self.
        var description : String { return "PUSH" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.stack.append(value)
        }
    }
    
    /// The Copy Command.
    private class Copy : Command {
        var value : Int = 0
        /// A textual representation of self.
        var description : String { return "COPY" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack[value]
            context.stack.append(newValue)
        }
    }
    
    /// The Slide Command.
    private class Slide : Command {
        var value : Int = 0
        /// A textual representation of self.
        var description : String { return "SLIDE" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()!
            for _ in (0..<value) {
                context.stack.popLast()
            }
            context.stack.append(newValue)
        }
    }
    
    /// The Duplicate Command.
    private class Duplicate : Command {
        /// A textual representation of self.
        var description : String { return "DUPLICATE" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.stack.append(context.stack.last!)
        }
    }
    
    /// The Swap Command.
    private class Swap : Command {
        /// A textual representation of self.
        var description : String { return "SWAP" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let fv = context.stack.popLast()!
            let sv = context.stack.popLast()!
            context.stack.append(fv)
            context.stack.append(sv)
        }
    }
    
    /// The Discard Command.
    private class Discard : Command {
        /// A textual representation of self.
        var description : String { return "DISCARD" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.stack.popLast()
        }
    }
    
    /// The Add Command.
    private class Add : Command {
        /// A textual representation of self.
        var description : String { return "ADD" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()! + context.stack.popLast()!
            context.stack.append(newValue)
        }
    }
    
    /// The Sub Command.
    private class Sub : Command {
        /// A textual representation of self.
        var description : String { return "SUB" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()! - context.stack.popLast()!
            context.stack.append(newValue)
        }
    }
    
    /// The Mul Command.
    private class Mul : Command {
        /// A textual representation of self.
        var description : String { return "MUL" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()! * context.stack.popLast()!
            context.stack.append(newValue)
        }
    }
    
    /// The Div Command.
    private class Div : Command {
        /// A textual representation of self.
        var description : String { return "DIV" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()! / context.stack.popLast()!
            context.stack.append(newValue)
        }
    }
    
    /// The Mod Command.
    private class Mod : Command {
        /// A textual representation of self.
        var description : String { return "MOD" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()! % context.stack.popLast()!
            context.stack.append(newValue)
        }
    }
    
    /// The Store Command.
    private class Store : Command {
        /// A textual representation of self.
        var description : String { return "STORE" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let newValue = context.stack.popLast()
            let address  = context.stack.popLast()
            context.heap[address!] = newValue
        }
    }
    
    /// The Retrieve Command.
    private class Retrieve : Command {
        /// A textual representation of self.
        var description : String { return "RETRIEVE" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            let address  = context.stack.popLast()
            context.stack.append(context.heap[address!]!)
        }
    }
    
    /// The Register Command.
    private class Register : Command {
        var name     : String = ""
        var location : Int    = 0
        /// A textual representation of self.
        var description : String { return "REGISTER" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.bracemap[name] = location
        }
    }
    
    /// The Call Command.
    private class Call : Command {
        var name     : String = ""
        var location : Int    = 0
        /// A textual representation of self.
        var description : String { return "CALL" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.bracestack.append(location)
            context.counter = context.bracemap[name]!
        }
    }
    
    /// The Jump Command.
    private class Jump : Command {
        var name : String = ""
        /// A textual representation of self.
        var description : String { return "JUMP" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.counter = context.bracemap[name]!
        }
    }
    
    /// The Test Command.
    private class ETest : Command {
        var name    : String   = ""
        /// A textual representation of self.
        var description : String { return "ETEST" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            if context.stack.popLast()! == 0 {
                context.counter = context.bracemap[name]!
            }
        }
    }
    
    /// The Test Command.
    private class NTest : Command {
        var name    : String   = ""
        /// A textual representation of self.
        var description : String { return "NTEST" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            if context.stack.popLast()! < 0 {
                context.counter = context.bracemap[name]!
            }
        }
    }
    
    /// The Return Command.
    private class Return : Command {
        /// A textual representation of self.
        var description : String { return "RETURN" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.counter = context.bracestack.popLast()!
        }
    }
    
    /// The End Command.
    private class End : Command {
        /// A textual representation of self.
        var description : String { return "END" }
        /// Execute the command.
        func exec(var context : Contextable, interactive _ : Interable?) {
            context.counter = Int.max - 1
        }
    }
    
    /// The Output Command (For character).
    private class COutput : Command {
        /// A textual representation of self.
        var description : String { return "COUTPUT" }
        /// Execute the command.
        func exec(var context : Contextable, interactive : Interable?) {
            let value   = context.stack.popLast()
            if let delegate = interactive {
                delegate.outputCalling(Character(UnicodeScalar(value!)))
            }
        }
    }
    
    /// The Output Command (For number).
    private class IOutput : Command {
        /// A textual representation of self.
        var description : String { return "IOUTPUT" }
        /// Execute the command.
        func exec(var context : Contextable, interactive : Interable?) {
            let value = context.stack.popLast()
            if let delegate = interactive {
                delegate.outputCalling(value!)
            }
        }
    }
    
    /// The Input Command (For character).
    private class CInput : Command {
        /// A textual representation of self.
        var description : String { return "CINPUT" }
        /// Execute the command.
        func exec(var context : Contextable, interactive : Interable?) {
            let address = context.stack.popLast()!
            if let delegate = interactive {
                let chr : Character = delegate.inputCalling()
                context.heap[address] = Int(String(chr).unicodeScalars.first!.value)
            }
        }
    }
    
    /// The Input Command (For number).
    private class IInput : Command {
        /// A textual representation of self.
        var description : String { return "IINPUT" }
        /// Execute the command.
        func exec(var context : Contextable, interactive : Interable?) {
            let value = context.stack.popLast()!
            if let delegate = interactive {
                let address = value
                context.heap[address] = delegate.inputCalling()
            }
        }
    }
    
    /**
     Creates a whitespace interpreter.
     
     - parameter path:   The file path.
     - returns:          The whitespace interpreter.
     */
    public convenience init? (contentsOfFile path: String) throws {
        if let handle = NSFileHandle(forReadingAtPath: path) {
            let data = handle.readDataToEndOfFile()
            if let code = NSString(data: data, encoding: NSUTF8StringEncoding) {
                try self.init(source: code as String)
                return
            }
        }
        return nil
    }
    
    /**
     Creates a whitespace interpreter.
     
     - parameter source:     The source code.
     - returns:              The whitespace interpreter.
     */
    public init (source : String) throws {
        code = source
        try commands = Parser(source: self.code!.characters.filter(
            { (c : Character) in c == Whiteplanes.SPACE || c == Whiteplanes.TAB || c == Whiteplanes.NEWLINE }
            )).parse()
    }
    
    /**
     Run the interpreter.
     
     - parameter context:    The context.
     */
    public func run (var context : Contextable) {
        if let registers = commands?.filter({(c : Command) in c is Register }) {
            registers.forEach({(register : Command) in register.exec(context, interactive: nil)})
        }
        
        while context.counter < commands!.count {
            let command = commands![context.counter]
            if (command is Register) == false {
                command.exec(context, interactive: delegate)
            }
            context.counter += 1
        }
    }
}