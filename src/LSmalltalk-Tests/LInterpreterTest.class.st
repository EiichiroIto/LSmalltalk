"
A LInterpreterTest is a test class for testing the behavior of LInterpreter
"
Class {
	#name : #LInterpreterTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LInterpreterTest >> newInterpreter [
	^ LInterpreter new
]

{ #category : #test }
LInterpreterTest >> testClassNames [
	| i c |
	i := self newInterpreter.
	self assert: i classNames isNil.
	c := LClassNames new.
	i classNames: c.
	self assert: i classNames identicalTo: c
]
