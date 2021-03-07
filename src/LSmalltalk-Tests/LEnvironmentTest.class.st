"
A LEnvironmentTest is a test class for testing the behavior of LEnvironment
"
Class {
	#name : #LEnvironmentTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LEnvironmentTest >> newEnvironment [
	^ LEnvironment new
]

{ #category : #test }
LEnvironmentTest >> testAddGlobalNamed [
	| m |
	m := self newEnvironment.
	self assert: m globals isEmpty.
	m addGlobal: 123 named: 'abc'.
	m addGlobal: 456 named: 'def'.
	self assert: (m globals at: 'abc') equals: 123.
	self assert: (m globals at: 'def') equals: 456
]

{ #category : #test }
LEnvironmentTest >> testAddSymbolNamed [
	| m |
	m := self newEnvironment.
	self assert: m symbols isEmpty.
	m addSymbol: 123 named: 'abc'.
	m addSymbol: 456 named: 'def'.
	self assert: (m symbols at: 'abc') equals: 123.
	self assert: (m symbols at: 'def') equals: 456
]

{ #category : #test }
LEnvironmentTest >> testGlobalNamed [
	| m |
	m := self newEnvironment.
	self assert: m globals isEmpty.
	m addGlobal: 123 named: 'abc'.
	m addGlobal: 456 named: 'def'.
	self assert: (m globalNamed: 'abc') equals: 123.
	self assert: (m globalNamed: 'def') equals: 456.
	self should: [ m globalNamed: 'ghi' ] raise: Error
]

{ #category : #test }
LEnvironmentTest >> testGlobalNamedIfAbsent [
	| m |
	m := self newEnvironment.
	self assert: m globals isEmpty.
	m addGlobal: 123 named: 'abc'.
	m addGlobal: 456 named: 'def'.
	self assert: (m globalNamed: 'abc' ifAbsent: [99]) equals: 123.
	self assert: (m globalNamed: 'def' ifAbsent: [99]) equals: 456.
	self assert: (m globalNamed: 'ghi' ifAbsent: [99]) equals: 99
]

{ #category : #test }
LEnvironmentTest >> testGlobals [
	| m |
	m := self newEnvironment.
	self assert: m globals isDictionary.
	self assert: m globals isEmpty
]

{ #category : #test }
LEnvironmentTest >> testNilObject [
	| b |
	b := self newEnvironment.
	self assert: b nilObject isNil.
	b nilObject: 123.
	self assert: b nilObject equals: 123
]

{ #category : #test }
LEnvironmentTest >> testSymbols [
	| m |
	m := self newEnvironment.
	self assert: m symbols isDictionary.
	self assert: m symbols isEmpty
]
