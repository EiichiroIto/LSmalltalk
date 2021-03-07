Class {
	#name : #LReturnNode,
	#superclass : #LParserNode,
	#instVars : [
		'expression'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LReturnNode >> compile: encoder block: inBlock [
	super compile: encoder.
	expression compile: encoder block: inBlock.
	inBlock
		ifTrue: [ encoder genHigh: 15 low: 3 " block return " ]
		ifFalse: [ encoder genHigh: 15 low: 2 " stack return " ]
]

{ #category : #'as yet unclassified' }
LReturnNode >> expression: e [
	expression := e
]
