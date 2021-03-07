Class {
	#name : #LChar,
	#superclass : #LMagnitude,
	#instVars : [
		'value'
	],
	#classInstVars : [
		'chars'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LChar class >> basicNew: value [
	" create and initialize a new char "
	^ self in: self new at: 1 put: value
]

{ #category : #'as yet unclassified' }
LChar class >> doInput [
	self primNo: 9
]

{ #category : #api }
LChar class >> eof [
	" return an EOF indication--not a true LChar, but polymorphic "

	^ self new: 256
]

{ #category : #'class initialization' }
LChar class >> init [
	chars isNil
		ifTrue: [ chars := LArray new: 257.
			1 to: 257 do: [ :idx | chars at: idx put: (LChar basicNew: idx - 1) ] ]
]

{ #category : #accessing }
LChar class >> input [
	| c |
	" read a single char from input stream "
	c := self doInput.
	c notNil
		ifTrue: [ ^ self new: c ]
		ifFalse: [ ^ nil ]
]

{ #category : #'instance creation' }
LChar class >> new: value [
	" return unique LChar for ASCII value (or EOF) "
	(value < 257) ifTrue: [ ^ chars at: value+1 ].

	" otherwise build a custom LChar "
	^ self basicNew: value
]

{ #category : #'as yet unclassified' }
LChar class >> newline [
		" return newline character "
	^ self new: 10
]

{ #category : #'stop conditions' }
LChar class >> tab [
		" return tab character "
	^ self new: 9
]

{ #category : #comparing }
LChar >> < aChar [
	^ value < aChar value
]

{ #category : #comparing }
LChar >> = aChar [
	^ value = aChar value
]

{ #category : #converting }
LChar >> asString [
	" return char as a string value "
	| s |
	s := LString new: 1.
	s at: 1 put: self.
	^ s
]

{ #category : #comparing }
LChar >> hash [
	^ value
]

{ #category : #testing }
LChar >> isAlphabetic [
	^ self isLowerCase or: [ self isUpperCase ]
]

{ #category : #testing }
LChar >> isAlphanumeric [
		" are we a letter or a digit? "
	^ self isAlphabetic or: [ self isDigit ]
]

{ #category : #testing }
LChar >> isBlank [
		"spaces, tabs and newlines are all blank"
	^ value = 32 or: [ value = 9 or: [ value = 10 ] ]
]

{ #category : #testing }
LChar >> isDigit [
	^ self between: $0 and: $9
]

{ #category : #testing }
LChar >> isEOF [
	^ value = 256
]

{ #category : #testing }
LChar >> isLowerCase [
	^ self between: $a and: $z
]

{ #category : #testing }
LChar >> isUpperCase [
	^ self between: $A and: $Z
]

{ #category : #'as yet unclassified' }
LChar >> lowerCase [
	self isUpperCase
		ifTrue: [ ^ LChar new: (value - 65) + 97 ]
]

{ #category : #printing }
LChar >> print [
	self primNo: 3 a: value
]

{ #category : #printing }
LChar >> printString [
	| s |
	s := LString new: 2.
	s at: 1 put: $$.
	s at: 2 put: self.
	^ s
]

{ #category : #'as yet unclassified' }
LChar >> upperCase [
	self isLowerCase
		ifTrue: [ ^ LChar new: (value - 97) + 65 ]
]

{ #category : #evaluating }
LChar >> value [
		" return our ascii value as an integer "
	^ value
]
