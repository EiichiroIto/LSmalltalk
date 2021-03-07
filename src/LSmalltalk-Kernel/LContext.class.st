Class {
	#name : #LContext,
	#superclass : #LObject,
	#instVars : [
		'method',
		'arguments',
		'temporaries',
		'stack',
		'bytePointer',
		'stackTop',
		'previousContext'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LContext >> backtrace [
	| narg |
	" backtrace context calls "
	narg := 0.
	method name print.
	'(' print.
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

{ #category : #'message performing' }
LContext >> perform: aMethod withArguments: a [ | proc |
	self setup: aMethod withArguments: a.
	proc := LProcess new.
	proc context: self.
	^ proc execute
]

{ #category : #accessing }
LContext >> previousContext [
	^ previousContext
]

{ #category : #'as yet unclassified' }
LContext >> setup: aMethod withArguments: a [
	method := aMethod.
	arguments := LArray new: 1.
	bytePointer := 0.
	stack := LArray new: method stackSize.
	stackTop := 0.
	temporaries := LArray new: method temporarySize
]
