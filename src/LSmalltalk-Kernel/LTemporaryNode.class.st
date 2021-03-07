Class {
	#name : #LTemporaryNode,
	#superclass : #LParserNode,
	#instVars : [
		'position'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LTemporaryNode >> assign: encoder [
	encoder genHigh: 7 low: position - 1
]

{ #category : #'as yet unclassified' }
LTemporaryNode >> assignable [
	^ true
]

{ #category : #'as yet unclassified' }
LTemporaryNode >> compile: encoder block: inBlock [
	super compile: encoder.
	encoder genHigh: 3 low: position - 1
]

{ #category : #'as yet unclassified' }
LTemporaryNode >> position: p [
	position := p
]
