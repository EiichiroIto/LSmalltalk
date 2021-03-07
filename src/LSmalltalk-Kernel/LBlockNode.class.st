Class {
	#name : #LBlockNode,
	#superclass : #LParserNode,
	#instVars : [
		'statements',
		'temporaryLocation'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LBlockNode >> compile: encoder block: inBlock [ | patchLocation |
	super compile: encoder.
	encoder genHigh: 12 low: temporaryLocation.
	patchLocation := encoder genVal: 0.
	self compileInLine: encoder block: true.
	encoder genHigh: 15 low: 2. " return top of stack "
	encoder patch: patchLocation
]

{ #category : #'as yet unclassified' }
LBlockNode >> compileInLine: encoder block: inBlock [
	statements reverseDo:
		[ :stmt | stmt compile: encoder block: inBlock.
			encoder genHigh: 15 low: 5 " pop top " ].
	encoder backUp
]

{ #category : #'as yet unclassified' }
LBlockNode >> isBlock [
	^ true
]

{ #category : #'as yet unclassified' }
LBlockNode >> statements: s temporaryLocation: t [
	statements := s.
	temporaryLocation := t
]
