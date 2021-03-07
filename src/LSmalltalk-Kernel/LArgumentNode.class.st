Class {
	#name : #LArgumentNode,
	#superclass : #LParserNode,
	#instVars : [
		'position'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LArgumentNode >> compile: encoder block: inBlock [
	super compile: encoder.
	position = 0
		ifTrue: [ encoder genHigh: 2 low: 0 ]
		ifFalse: [ encoder genHigh: 2 low: position - 1 ]
]

{ #category : #'as yet unclassified' }
LArgumentNode >> isSuper [
	^ position = 0
]

{ #category : #'as yet unclassified' }
LArgumentNode >> position: p [
	position := p
]
