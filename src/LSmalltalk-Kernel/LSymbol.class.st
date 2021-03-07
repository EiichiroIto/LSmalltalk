Class {
	#name : #LSymbol,
	#superclass : #LMagnitude,
	#classInstVars : [
		'symbols'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LSymbol class >> intern: string [
	self primNo: 23 a: string b: LSymbol
]

{ #category : #'instance creation' }
LSymbol class >> new: fromString [
	^ symbols
		at: fromString
		ifAbsent: [ symbols add: (self intern: fromString) ]
]

{ #category : #comparing }
LSymbol >> < arg [
	" works with either symbol or string arguments "

	^ self printString < arg printString
]

{ #category : #comparing }
LSymbol >> = aString [
	" works with either symbol or string arguments "

	^ self printString = aString printString
]

{ #category : #converting }
LSymbol >> asString [
	^self printString
]

{ #category : #converting }
LSymbol >> asSymbol [
	^ self
]

{ #category : #comparing }
LSymbol >> hash [
	^ self printString hash
]

{ #category : #printing }
LSymbol >> printString [
	self primNo: 23 a: self b: LString.
]
