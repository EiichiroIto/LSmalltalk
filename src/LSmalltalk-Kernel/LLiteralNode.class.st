Class {
	#name : #LLiteralNode,
	#superclass : #LParserNode,
	#instVars : [
		'value'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LLiteralNode >> compile: encoder block: inBlock [
	super compile: encoder.
	value == nil ifTrue: [ ^ encoder genHigh: 5 low: 10 ].
	value == true ifTrue: [ ^ encoder genHigh: 5 low: 11 ].
	value == false ifTrue: [ ^ encoder genHigh: 5 low: 12 ].
	(((value class == LSmallInt) and:
	 [value < 10]) and: [value negative not])
		ifTrue: [ ^ encoder genHigh: 5 low: value ].
	encoder genHigh: 4 low: (encoder genLiteral: value)
]

{ #category : #'as yet unclassified' }
LLiteralNode >> value: v [
	value := v
]
