Class {
	#name : #LParserNode,
	#superclass : #LObject,
	#instVars : [
		'lineNum'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LParserNode class >> at: l [ | ret |
	ret := super new.
	self in: ret at: 1 put: l.
	^ ret
]

{ #category : #'as yet unclassified' }
LParserNode class >> new [
	self error: 'Must use at: for creation'
]

{ #category : #'as yet unclassified' }
LParserNode >> assignable [
	^ false
]

{ #category : #'as yet unclassified' }
LParserNode >> compile: encoder [
	encoder lineNum: lineNum
]

{ #category : #'as yet unclassified' }
LParserNode >> isBlock [
	^ false
]

{ #category : #'as yet unclassified' }
LParserNode >> isSuper [
	^ false
]
