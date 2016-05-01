// WhiteplanesTest.swift
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

import XCTest
@testable import Whiteplanes

class WhiteplanesTests: XCTestCase {
    
    class Context : Contextable, Interable {
        /// The output contents.
        var contents = ""
        
        // Compliant to WsContextable protocol.
        var counter    :  Int           = 0
        var stack      : [Int]          = []
        var heap       : [Int: Int]     = Dictionary.init(minimumCapacity: 200)
        var bracemap   : [String: Int]  = Dictionary.init(minimumCapacity: 200)
        var bracestack : [Int]          = []
        
        // Compliant to WsInterable protocol.
        func inputCalling() -> Int { return 72  }
        func inputCalling() -> Character { return "H" }
        func outputCalling(chr: Character) {
            contents.append(chr)
        }
        func outputCalling(chr: Int) {
            contents += String(chr)
        }
    }
    
    /// The Resource bundle.
    private let bundle = NSBundle(forClass: WhiteplanesTests.self)
    
    /// Display as 'Hello World' (Simple)
    func testHelloWorld() {
        let context = Context()
        do {
            if let path = bundle.pathForResource("HelloWorld", ofType: "ws"),
                interpreter = try! Whiteplanes(contentsOfFile: path)
            {
                interpreter.delegate = context
                interpreter.run(context)
            }
        }
        XCTAssertEqual("Hello World\n", context.contents)
    }
    
    /// Display as 'Hello World' (Heap operation)
    func testHeapControl() {
        let context = Context()
        do {
            if let path = bundle.pathForResource("HeapControl", ofType: "ws"),
                interpreter = try! Whiteplanes(contentsOfFile: path)
            {
                interpreter.delegate = context
                interpreter.run(context)
            }
        }
        XCTAssertEqual("Hello World\n", context.contents)
    }
    
    /// Display as '52' (Flow control operation)
    func testFlowControl() {
        let context = Context()
        if let path = bundle.pathForResource("FlowControl", ofType: "ws"),
            interpreter = try! Whiteplanes(contentsOfFile: path)
        {
            interpreter.delegate = context
            interpreter.run(context)
        }
        XCTAssertEqual("52", context.contents)
    }
    
    /// Count up test.
    func testCount() {
        let context = Context()
        if let path = bundle.pathForResource("Count", ofType: "ws"),
            interpreter = try! Whiteplanes(contentsOfFile: path)
        {
            interpreter.delegate = context
            interpreter.run(context)
        }
        XCTAssertEqual("1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n", context.contents)
    }
    
    /// Input method test.
    func testInput() {
        let context = Context()
        do {
            if let path = bundle.pathForResource("Input", ofType: "ws"),
                interpreter = try! Whiteplanes(contentsOfFile: path)
            {
                interpreter.delegate = context
                interpreter.run(context)
            }
        }
        XCTAssertEqual("H72", context.contents)
    }
}