Class {
	#name : #LCascadeNode,
	#superclass : #LParserNode,
	#instVars : [
		'head',
		'list'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LCascadeNode >> compile: encoder block: inBlock [
	super compile: encoder.
	head compile: encoder block: inBlock.
	list reverseDo: [ :stmt |
		encoder genHigh: 15 low: 4. " duplicate "
		stmt compile: encoder block: inBlock.
		encoder genHigh: 15 low: 5 "pop from stack " ]
]

{ #category : #'as yet unclassified' }
LCascadeNode >> head: h [
	head := h
]

{ #category : #'as yet unclassified' }
LCascadeNode >> list: l [
	list := l
]
