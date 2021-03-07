Class {
	#name : #LPrimitiveNode,
	#superclass : #LParserNode,
	#instVars : [
		'number',
		'arguments'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LPrimitiveNode >> compile: encoder block: inBlock [ | argsize |
	argsize := arguments size.
	super compile: encoder.
	encoder pushArgs: argsize.
	arguments reverseDo: [ :a | a compile: encoder block: inBlock ].
	encoder genHigh: 13 low: argsize.
	encoder genCode: number.
	encoder popArgs: argsize
]

{ #category : #'as yet unclassified' }
LPrimitiveNode >> number: n arguments: a [
	number := n.
	arguments := a.
]
