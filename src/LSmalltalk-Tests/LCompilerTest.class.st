"
A LCompilerTest is a test class for testing the behavior of LCompiler
"
Class {
	#name : #LCompilerTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LCompilerTest >> astFor: aString [
	^ RBParser parseMethod: aString
]

{ #category : #private }
LCompilerTest >> newCompiler [
	^ LCompiler new
]

{ #category : #test }
LCompilerTest >> testAddArgument [
	| c |
	c := self newCompiler.
	self assert: c arguments isCollection.
	self assert: c arguments size equals: 1.
	c addArgument: 'abc'.
	c addArgument: 'def'.
	self assertCollection: c arguments asArray equals: #('self' 'abc' 'def')
]

{ #category : #test }
LCompilerTest >> testAddLiteral [
	| c r |
	c := self newCompiler.
	self assert: c literals isCollection.
	self assert: c literals isEmpty.
	r := c addLiteral: 'abc'.
	self assert: r equals: 0.
	r := c addLiteral: 'def'.
	self assert: r equals: 1.
	self assertCollection: c literals asArray equals: #('abc' 'def')
]

{ #category : #test }
LCompilerTest >> testAddTemporary [
	| c |
	c := self newCompiler.
	self assert: c temporaries isCollection.
	self assert: c temporaries isEmpty.
	c addTemporary: 'abc'.
	c addTemporary: 'def'.
	self assertCollection: c temporaries asArray equals: #('abc' 'def').
	self should: [ c addTemporary: #a: ] raise: Error
]

{ #category : #test }
LCompilerTest >> testArguments [
	| c r |
	c := self newCompiler.
	self assert: c arguments isCollection.
	self assert: c arguments size equals: 1.
	r := #(1 2 3).
	c arguments: r.
	self assert: c arguments identicalTo: r
]

{ #category : #test }
LCompilerTest >> testBlockBackup [
	| c |
	c := self newCompiler.
	self assert: c blockBackup isNil.
	c blockBackup: 123.
	self assert: c blockBackup equals: 123.
	c blockBackup: 456.
	self assert: c blockBackup equals: 456
]

{ #category : #test }
LCompilerTest >> testByteTop [
	| c |
	c := self newCompiler.
	self assert: c byteTop equals: 0.
	c genByte: 10.
	c genByte: 20.
	self assert: c byteTop equals: 2
]

{ #category : #test }
LCompilerTest >> testBytes [
	| c r |
	c := self newCompiler.
	self assert: c bytes isCollection.
	self assert: c bytes isEmpty.
	r := #(1 2 3).
	c bytes: r.
	self assert: c bytes identicalTo: r
]

{ #category : #test }
LCompilerTest >> testClearTemporaries [
	| c |
	c := self newCompiler.
	c addTemporary: 'abc'.
	c addTemporary: 'def'.
	self assertCollection: c temporaries asArray equals: #('abc' 'def').
	self assert: c maxTemp equals: 2.
	c clearTemporaries.
	self assert: c temporaries isCollection.
	self assert: c temporaries isEmpty.
	self assert: c maxTemp equals: 0
]

{ #category : #test }
LCompilerTest >> testDoAssignment [
	| c |
	c := self newCompiler.
	c instanceVariables: #('x' 'y').
	c addTemporary: 'abc'.
	c addTemporary: 'def'.
	c doAssignment: 'abc'.
	self assert: c bytes first equals: c assignTemporary << 4.
	c doAssignment: 'def'.
	self assert: c bytes second equals: (c assignTemporary << 4) + 1.
	c doAssignment: 'x'.
	self assert: c bytes third equals: c assignInstance << 4.
	c doAssignment: 'y'.
	self assert: c bytes fourth equals: (c assignInstance << 4) + 1.
	self should: [ c doAssignment: 'z' ] raise: Error
]

{ #category : #test }
LCompilerTest >> testFailBlock [
	| c |
	c := self newCompiler.
	c failBlock: 123
]

{ #category : #test }
LCompilerTest >> testGenByte [
	| c |
	c := self newCompiler.
	self assert: c bytes isEmpty.
	c genByte: 123.
	c genByte: 456.
	c genByte: 78.
	self assert: c bytes size equals: 3.
	self assert: c bytes first equals: 123.
	self assert: c bytes second equals: (456 bitAnd: 16rFF).
	self assert: c bytes third equals: 78
]

{ #category : #test }
LCompilerTest >> testGenInstructionAnd [
	| c |
	c := self newCompiler.
	c genInstruction: 1 and: 2.
	c genInstruction: 1 and: 20.
	c genInstruction: 20 and: 30.
	self assert: c bytes first equals: (1 << 4) + 2.
	self assert: c bytes second equals: 1.
	self assert: c bytes third equals: 20.
	self assert: c bytes fourth equals: 0.
	self assert: c bytes fifth equals: 20.
	self assert: c bytes sixth equals: 30.
	self assert: c bytes size equals: 6
]

{ #category : #test }
LCompilerTest >> testGenLiteral [
	| c |
	c := self newCompiler.
	self assert: c bytes isEmpty.
	c genLiteral: 5.
	c genLiteral: 123.
	c genLiteral: 'abc'.
	self assertCollection: c literals asArray equals: #(123 'abc').
	self assert: c bytes size equals: 3.
	self assert: c bytes first equals: (c pushConstant << 4) + 5.
	self assert: c bytes second equals: (c pushLiteral << 4).
	self assert: c bytes third equals: (c pushLiteral << 4) + 1
]

{ #category : #test }
LCompilerTest >> testGenVal [
	| c |
	c := self newCompiler.
	self assert: c bytes isEmpty.
	c genVal: 123.
	c genVal: 456.
	c genVal: 78.
	self assert: c bytes size equals: 6.
	self assert: c bytes first equals: 123.
	self assert: c bytes second equals: 0.
	self assert: c bytes third equals: (456 bitAnd: 16rFF).
	self assert: c bytes fourth equals: 1.
	self assert: c bytes fifth equals: 78.
	self assert: c bytes sixth equals: 0.
	self should: [ c genVal: 99999 ] raise: Error
]

{ #category : #test }
LCompilerTest >> testGenValAt [
	| c |
	c := self newCompiler.
	self assert: c bytes isEmpty.
	c genVal: 123.
	c genVal: 456.
	c genVal: 78.
	self assert: c bytes size equals: 6.
	self assert: c bytes first equals: 123.
	self assert: c bytes second equals: 0.
	self assert: c bytes third equals: (456 bitAnd: 16rFF).
	self assert: c bytes fourth equals: 1.
	c genVal: 100 at: 2.
	self assert: c bytes third equals: 100.
	self assert: c bytes fourth equals: 0
]

{ #category : #test }
LCompilerTest >> testGlobals [
	| c r |
	c := self newCompiler.
	self assert: c globals isNil.
	r := Dictionary new.
	c globals: r.
	self assert: c globals identicalTo: r
]

{ #category : #test }
LCompilerTest >> testInstanceVariables [
	| c r |
	c := self newCompiler.
	self assert: c instanceVariables isNil.
	r := #(1 2 3).
	c instanceVariables: r.
	self assert: c instanceVariables identicalTo: r
]

{ #category : #test }
LCompilerTest >> testIsIdentifier [
	| c |
	c := self newCompiler.
	self assert: (c isIdentifier: 'a').
	self assert: (c isIdentifier: 'abc').
	self deny: (c isIdentifier: 'abc:').
	self deny: (c isIdentifier: 'abc:def:')
]

{ #category : #test }
LCompilerTest >> testLiterals [
	| c r |
	c := self newCompiler.
	self assert: c literals isCollection.
	self assert: c literals isEmpty.
	r := #(1 2 3).
	c literals: r.
	self assert: c literals identicalTo: r
]

{ #category : #test }
LCompilerTest >> testLookupGlobal [
	| c r |
	c := self newCompiler.
	r := Dictionary new.
	r at: #abc put: 1.
	r at: 'def' put: 2.
	c globals: r.
	self assert: (c lookupGlobal: 'abc') equals: 1.
	self assert: (c lookupGlobal: 'def') equals: 2.
	self should: [ c lookupGlobal: 'ghi' ] raise: Error
]

{ #category : #test }
LCompilerTest >> testLookupInstance [
	| c r |
	c := self newCompiler.
	self assert: c instanceVariables isNil.
	c instanceVariables: #('abc' 'def' 'ghi').
	r := c lookupInstance: 'abc'.
	self assert: r equals: 1.
	r := c lookupInstance: 'def'.
	self assert: r equals: 2.
	r := c lookupInstance: 'ghi'.
	self assert: r equals: 3.
	r := c lookupInstance: 'jkl'.
	self assert: r equals: 0
]

{ #category : #test }
LCompilerTest >> testMaxTemp [
	| c |
	c := self newCompiler.
	c addTemporary: 'abc'.
	c addTemporary: 'def'.
	self assertCollection: c temporaries asArray equals: #('abc' 'def').
	self assert: c maxTemp equals: 2.
	c clearTemporaries.
	self assert: c maxTemp equals: 0.
	c maxTemp: 123.
	self assert: c maxTemp equals: 123
]

{ #category : #test }
LCompilerTest >> testNameTerm [
	| c |
	c := self newCompiler.
	c instanceVariables: #('a' 'b' 'c').
	c arguments: #('d' 'e' 'f').
	c
		globals:
			{('X' -> 10).
			('Y' -> 20)} asDictionary.
	c addTemporary: 'x'.
	c addTemporary: 'y'.
	c nameTerm: 'x'.
	c nameTerm: 'c'.
	c nameTerm: 'e'.
	c nameTerm: 'X'.
	c nameTerm: 'Y'.
	self assert: c bytes first equals: c pushTemporary << 4.
	self assert: c bytes second equals: (c pushInstance << 4) + 2.
	self assert: c bytes third equals: (c pushArgument << 4) + 1.
	self assert: c bytes fourth equals: c pushLiteral << 4.
	self assert: c bytes fifth equals: (c pushLiteral << 4) + 1
]

{ #category : #test }
LCompilerTest >> testParseAssignment [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 | x | y := 5. a := 2.'.
	c temporaries: #('x' 'y').
	c instanceVariables: #('a' 'b').
	c parseAssignment: n statements first.
	self assert: c bytes first equals: (c pushConstant << 4) + 5.
	self assert: c bytes second equals: (c assignTemporary << 4) + 1.
	self assert: c bytes size equals: 2.
	c parseAssignment: n statements second.
	self assert: c bytes third equals: (c pushConstant << 4) + 2.
	self assert: c bytes fourth equals: (c assignInstance << 4).
	self assert: c bytes size equals: 4
]

{ #category : #test }
LCompilerTest >> testParseBinaryMessage [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 | x | 1 + 2. 1 - 2'.
	c temporaries: #('x').
	c parseBinaryMessage: n statements first.
	self assert: c bytes first equals: (c pushConstant << 4) + 1.
	self assert: c bytes second equals: (c pushConstant << 4) + 2.
	self assert: c bytes third equals: (c sendBinary << 4) + c plusConst.
	self assert: c bytes size equals: 3.
	c parseBinaryMessage: n statements second.
	self assertCollection: c literals asArray equals: #(-).
	self assert: c bytes fourth equals: (c pushConstant << 4) + 1.
	self assert: c bytes fifth equals: (c pushConstant << 4) + 2.
	self assert: c bytes sixth equals: (c markArguments << 4) + 2.
	self assert: c bytes seventh equals: (c sendMessage << 4)
]

{ #category : #test }
LCompilerTest >> testParseBlock [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 | x y | [ :z | ]'.
	c temporaries: #(x y) asOrderedCollection.
	c parseBlock: n statements first.
	self assert: c bytes first equals: (c pushBlock << 4) + 2.
	self assert: c bytes second equals: 5.
	self assert: c bytes third equals: 0.
	self
		assert: c bytes fourth
		equals: (c pushConstant << 4) + c nilConst.
	self assert: c bytes fifth equals: (c doSpecial << 4) + c stackReturn.
	self assert: c bytes size equals: 5.
	c := self newCompiler.
	n := self astFor: 'test1 | x y | [ :z | x + z. x + y ]'.
	c temporaries: #(x y) asOrderedCollection.
	c parseBlock: n statements first.
	self assert: c bytes first equals: (c pushBlock << 4) + 2.
	self assert: c bytes second equals: 11.
	self assert: c bytes third equals: 0.
	self assert: c bytes fourth equals: (c pushTemporary << 4) + 0.
	self assert: c bytes fifth equals: (c pushTemporary << 4) + 2.
	self assert: c bytes sixth equals: (c sendBinary << 4) + c plusConst.
	self assert: c bytes seventh equals: (c doSpecial << 4) + c popTop.
	self assert: c bytes eighth equals: (c pushTemporary << 4) + 0.
	self assert: c bytes ninth equals: (c pushTemporary << 4) + 1.
	self
		assert: (c bytes at: 10)
		equals: (c sendBinary << 4) + c plusConst.
	self
		assert: (c bytes at: 11)
		equals: (c doSpecial << 4) + c stackReturn.
	self assert: c bytes size equals: 11
]

{ #category : #test }
LCompilerTest >> testParseMessage [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 (1 + 2) * 3'.
	c parseBinaryMessage: n statements first.
	self assertCollection: c literals asArray equals: #(*).
	self assert: c bytes first equals: (c pushConstant << 4) + 1.
	self assert: c bytes second equals: (c pushConstant << 4) + 2.
	self assert: c bytes third equals: (c sendBinary << 4) + c plusConst.
	self assert: c bytes fourth equals: (c pushConstant << 4) + 3.
	self assert: c bytes fifth equals: (c markArguments << 4) + 2.
	self assert: c bytes sixth equals: (c sendMessage << 4).
	self assert: c bytes size equals: 6
]

{ #category : #test }
LCompilerTest >> testParsePrimitive [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 prim x: 99 a: 1 b: 2'.
	c parsePrimitive: n statements first.
	self assert: c bytes first equals: (c pushConstant << 4) + 1.
	self assert: c bytes second equals: (c pushConstant << 4) + 2.
	self assert: c bytes third equals: (c doPrimitive << 4) + 2.
	self assert: c bytes fourth equals: 99.
	self assert: c bytes size equals: 4
]

{ #category : #test }
LCompilerTest >> testParseStatement [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 | x y z | ^ z'.
	c parseTemporaries: n temporaries.
	c returnOp: c stackReturn.
	c parseStatement: n statements first.
	self assert: c bytes first equals: (c pushTemporary << 4) + 2.
	self assert: c bytes second equals: (c doSpecial << 4) + c stackReturn.
	c := self newCompiler.
	n := self astFor: 'test1 ^ x + y'.
	c instanceVariables: #(x y).
	c returnOp: c stackReturn.
	c parseStatement: n statements first.
	self assert: c bytes first equals: (c pushInstance << 4) + 0.
	self assert: c bytes second equals: (c pushInstance << 4) + 1.
	self assert: c bytes third equals: (c sendBinary << 4) + c plusConst.
	self assert: c bytes fourth equals: (c doSpecial << 4) + c stackReturn
]

{ #category : #test }
LCompilerTest >> testParseTemporaries [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 | x y z | (1 + 2) * 3'.
	c parseTemporaries: n temporaries.
	self assertCollection: c temporaries asArray equals: #(x y z)
]

{ #category : #test }
LCompilerTest >> testParseUnaryMessage [
	| c n |
	c := self newCompiler.
	n := self astFor: 'test1 10 negated'.
	c parseUnaryMessage: n statements first.
	self assertCollection: c literals asArray equals: #(10 negated).
	self assert: c bytes first equals: (c pushLiteral << 4) + 0.
	self assert: c bytes second equals: (c markArguments << 4) + 1.
	self assert: c bytes third equals: (c sendMessage << 4) + 1.
	self assert: c bytes size equals: 3.
	c := self newCompiler.
	n := self astFor: 'test1 super test'.
	c parseUnaryMessage: n statements first.
	self assertCollection: c literals asArray equals: #(test).
	self assert: c bytes first equals: (c pushArgument << 4) + 0.
	self assert: c bytes second equals: (c markArguments << 4) + 1.
	self assert: c bytes third equals: (c doSpecial << 4) + c sendToSuper.
	self assert: c bytes fourth equals: 0.
	self assert: c bytes size equals: 4
]

{ #category : #test }
LCompilerTest >> testParserClass [
	self assert: self newCompiler parserClass equals: RBParser
]

{ #category : #test }
LCompilerTest >> testRequestor [
	| c |
	c := self newCompiler.
	c requestor: 123
]

{ #category : #test }
LCompilerTest >> testReturnOp [
	| c |
	c := self newCompiler.
	self assert: c returnOp isNil.
	c returnOp: 123.
	self assert: c returnOp equals: 123.
	c returnOp: 456.
	self assert: c returnOp equals: 456
]

{ #category : #test }
LCompilerTest >> testSource [
	| c |
	c := self newCompiler.
	self assert: c source isNil.
	c source: 'abc'.
	self assert: c source equals: 'abc'.
	c source: 'def'.
	self assert: c source equals: 'def'
]

{ #category : #test }
LCompilerTest >> testSuperMessage [
	| c |
	c := self newCompiler.
	self assert: c superMessage isNil.
	c superMessage: true.
	self assert: c superMessage.
	c superMessage: false.
	self deny: c superMessage
]

{ #category : #test }
LCompilerTest >> testTempTop [
	| c |
	c := self newCompiler.
	c addTemporary: 'abc'.
	c addTemporary: 'def'.
	c addTemporary: 'ghi'.
	self assert: c tempTop equals: 3.
	c tempTop: 2.
	self assert: c tempTop equals: 2.
	self assertCollection: c temporaries asArray equals: #('abc' 'def')
]

{ #category : #test }
LCompilerTest >> testTemporaries [
	| c r |
	c := self newCompiler.
	self assert: c temporaries isCollection.
	self assert: c temporaries isEmpty.
	r := #(1 2 3).
	c temporaries: r.
	self assert: c temporaries identicalTo: r
]
