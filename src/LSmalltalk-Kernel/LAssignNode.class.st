Class {
	#name : #LAssignNode,
	#superclass : #LParserNode,
	#instVars : [
		'target',
		'expression'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LAssignNode >> compile: encoder block: inBlock [
	super compile: encoder.
	expression compile: encoder block: inBlock.
	target assign: encoder
]

{ #category : #'as yet unclassified' }
LAssignNode >> target: t expression: e [
	target := t.
	expression := e
]
