Class {
	#name : #LBodyNode,
	#superclass : #LParserNode,
	#instVars : [
		'statements'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LBodyNode >> compile: encoder block: inBlock [
	super compile: encoder.
	statements reverseDo:
		[ :stmt | stmt compile: encoder block: inBlock.
			encoder genHigh: 15 low: 5 " pop "].
	encoder genHigh: 15 low: 1 " return self "
]

{ #category : #'as yet unclassified' }
LBodyNode >> statements: s [
	statements := s
]
