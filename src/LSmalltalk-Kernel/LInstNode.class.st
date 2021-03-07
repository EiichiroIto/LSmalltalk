Class {
	#name : #LInstNode,
	#superclass : #LParserNode,
	#instVars : [
		'position'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LInstNode >> assign: encoder [
	encoder genHigh: 6 low: position - 1
]

{ #category : #'as yet unclassified' }
LInstNode >> assignable [
	^ true
]

{ #category : #'as yet unclassified' }
LInstNode >> compile: encoder block: inBlock [
	super compile: encoder.
	encoder genHigh: 1 low: position - 1
]

{ #category : #'as yet unclassified' }
LInstNode >> position: p [
	position := p
]
