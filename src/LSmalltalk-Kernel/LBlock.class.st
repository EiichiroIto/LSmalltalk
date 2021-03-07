Class {
	#name : #LBlock,
	#superclass : #LContext,
	#instVars : [
		'argumentLocation',
		'creatingContext',
		'oldBytePointer'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LBlock >> argCount [
	self error: 'Incorrect argument passing to LBlock'
]

{ #category : #'as yet unclassified' }
LBlock >> backtrace [
	| narg |
	" backtrace context calls "
	'block from ' print.
	method name print.
	'(' print.
	narg := 0.
	arguments
		do: [ :a | 
			narg > 0
				ifTrue: [ ', ' print ].
			a class print.
			narg := narg + 1 ].
	')' printNl.
	previousContext notNil
		ifTrue: [ previousContext backtrace ]
]

{ #category : #evaluating }
LBlock >> value [
	" start block execution "
	self primNo: 8 a: self.
	(self argCount)
]

{ #category : #accessing }
LBlock >> value: a [
	" start block execution "
	self primNo: 8 a: a b: self.
	(self argCount)
]

{ #category : #evaluating }
LBlock >> value: a value: b [
	" start block execution "
	self primNo: 8 a: a b: b c: self.
	(self argCount)
]

{ #category : #controlling }
LBlock >> whileFalse: aBlock [
	self value ifFalse: [ aBlock value. ^ self whileFalse: aBlock ]
]

{ #category : #controlling }
LBlock >> whileTrue: aBlock [
	self value ifTrue: [ aBlock value. ^ self whileTrue: aBlock ]
]
