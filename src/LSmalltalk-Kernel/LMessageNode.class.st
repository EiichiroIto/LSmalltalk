Class {
	#name : #LMessageNode,
	#superclass : #LParserNode,
	#instVars : [
		'receiver',
		'name',
		'arguments'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LMessageNode >> argumentsAreBlock [
	arguments do: [ :arg | arg isBlock ifFalse: [ ^ false ]].
	^ true
]

{ #category : #'as yet unclassified' }
LMessageNode >> cascade: encoder block: inBlock [
	self evaluateArguments: encoder block: inBlock.
	self sendMessage: encoder block: inBlock
]

{ #category : #'as yet unclassified' }
LMessageNode >> compile2: encoder block: inBlock [
	self argumentsAreBlock ifTrue: [
		name = #ifTrue: ifTrue: [ ^ self compile: encoder
				test: 8 constant: 10 block: inBlock ].
		name = #ifFalse: ifTrue: [ ^ self compile: encoder
				test: 7 constant: 10 block: inBlock ].
		name = #and: ifTrue: [ ^ self compile: encoder
				test: 8 constant: 12 block: inBlock ].
		name = #or: ifTrue: [ ^ self compile: encoder
				test: 7 constant: 11 block: inBlock ].
		name = #ifTrue:ifFalse:
			ifTrue: [ ^ self optimizeIf: encoder block: inBlock ].
		].
	self evaluateArguments: encoder block: inBlock.
	name = '<' asSymbol ifTrue: [ ^ encoder genHigh: 11 low: 0].
	name = '<=' asSymbol ifTrue: [ ^ encoder genHigh: 11 low: 1].
	name = '+' asSymbol ifTrue: [ ^ encoder genHigh: 11 low: 2].
	self sendMessage: encoder block: inBlock
]

{ #category : #'as yet unclassified' }
LMessageNode >> compile: encoder block: inBlock [
	super compile: encoder.
	receiver isNil
		ifTrue: [ ^ self cascade: encoder block: inBlock ].
	((receiver isBlock and: [ self argumentsAreBlock ])
		and: [name = #whileTrue: or: [ name = #whileFalse ] ] )
		ifTrue: [ ^ self optimizeWhile: encoder block: inBlock ].
	receiver compile: encoder block: inBlock.
	receiver isSuper
		ifTrue: [ ^ self sendToSuper: encoder block: inBlock ].
	name = #isNil ifTrue: [ ^ encoder genHigh: 10 low: 0 ].
	name = #notNil ifTrue: [ ^ encoder genHigh: 10 low: 1 ].
	self compile2: encoder block: inBlock
]

{ #category : #'as yet unclassified' }
LMessageNode >> compile: encoder test: t constant: c block: inBlock [ | save ssave |
	super compile: encoder.
	encoder genHigh: 15 low: t.  " branch test "
	save := encoder genVal: 0.
	arguments first compileInLine: encoder block: inBlock.
	encoder genHigh: 15 low: 6.  " branch "
	ssave := encoder genVal: 0.
	encoder patch: save.
	encoder genHigh: 5 low: c.  " push constant "
	encoder patch: ssave
]

{ #category : #'as yet unclassified' }
LMessageNode >> evaluateArguments: encoder block: inBlock [
	encoder pushArgs: 1 + arguments size.
	arguments reverseDo: [ :arg |
		arg compile: encoder block: inBlock ]
]

{ #category : #'as yet unclassified' }
LMessageNode >> optimizeIf: encoder block: inBlock [ | save ssave |
	encoder genHigh: 15 low: 7.  " branch if true test "
	save := encoder genVal: 0.
	arguments first compileInLine: encoder block: inBlock.
	arguments removeFirst.
	encoder genHigh: 15 low: 6.  " branch "
	ssave := encoder genVal: 0.
	encoder patch: save.
	arguments first compileInLine: encoder block: inBlock.
	encoder patch: ssave
]

{ #category : #'as yet unclassified' }
LMessageNode >> optimizeWhile: encoder block: inBlock [ | start save |
	start := encoder currentLocation.
	receiver compileInLine: encoder block: inBlock.
	name = #whileTrue:	" branch if false/true "
		ifTrue: [ encoder genHigh: 15 low: 8 ]
		ifFalse: [ encoder genHigh: 15 low: 7 ].
	save := encoder genVal: 0.
	arguments first compileInLine: encoder block: inBlock.
	encoder genHigh: 15 low: 5. " pop from stack "
	encoder genHigh: 15 low: 6. " branch "
	encoder genVal: start. " branch target "
	encoder patch: save.
	encoder genHigh: 5 low: 10  " push nil "
]

{ #category : #'as yet unclassified' }
LMessageNode >> receiver: r name: n arguments: a [
	receiver := r.
	name := n.
	arguments := a
]

{ #category : #'as yet unclassified' }
LMessageNode >> sendMessage: encoder block: inBlock [
	encoder popArgs: arguments size.
		" mark arguments, then send message "
	encoder genHigh: 8 low: 1 + arguments size.
	encoder genHigh: 9 low: (encoder genLiteral: name)
]

{ #category : #'as yet unclassified' }
LMessageNode >> sendToSuper: encoder block: inBlock [
	self evaluateArguments: encoder block: inBlock.
	encoder genHigh: 8 low: 1 + arguments size.
	encoder genHigh: 15 low: 11.
	encoder genCode: (encoder genLiteral: name)
]
