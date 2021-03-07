Class {
	#name : #LObject,
	#superclass : #LProtoObject,
	#classVars : [
		'LSmalltalk',
		'LSymbols'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #accessing }
LObject class >> in: object at: index put: value [
	" change data field in object, used during initialization "
	" returns the intialized object "
	self primNo: 5 a: value b: object c: index
]

{ #category : #comparing }
LObject >> = arg [
	^ self == arg
]

{ #category : #comparing }
LObject >> == arg [
	self primNo: 1 a: self b: arg
]

{ #category : #enumerating }
LObject >> basicDo: aBlock [
	^ self do: aBlock
]

{ #category : #accessing }
LObject >> basicSize [
	self primNo: 4 a: self.
	self primitiveFailed
]

{ #category : #'reflective operations' }
LObject >> become: other [
	" Exchange identity with another object "

	(LArray with: self)
		elementsExchangeIdentityWith: (LArray with: other)
]

{ #category : #'class membership' }
LObject >> class [
	self primNo: 2 a: self
]

{ #category : #debugging }
LObject >> debug [
	self primNo: 18
]

{ #category : #'reflective operations' }
LObject >> doesNotUnderstand: aSel [
	self
		error:
			self printString + ' (class ' + self class printString
				+ '): does not understand ' + aSel printString
]

{ #category : #'error handling' }
LObject >> error: str [
	" print the message "
	str printNl.
	" then halt "
	self primNo: 19
]

{ #category : #comparing }
LObject >> hash [
	" Most objects should generate something based on their value "
	^ self class printString hash
]

{ #category : #'as yet unclassified' }
LObject >> in: object at: index [
	" browse instance variable via debugger "
	self primNo: 24 a: object b: index.
	self primitiveFailed
]

{ #category : #'class membership' }
LObject >> isKindOf: aClass [
	| clas |
	clas := self class.
	[ clas notNil ]
		whileTrue: [ clas == aClass
				ifTrue: [ ^ true ].
			clas := clas superclass ].
	^ false
]

{ #category : #'class membership' }
LObject >> isMemberOf: aClass [
	^ self class == aClass
]

{ #category : #testing }
LObject >> isNil [
	^ false
]

{ #category : #testing }
LObject >> notNil [
	^ true
]

{ #category : #'primitive failure' }
LObject >> primitiveFailed [
	self error: 'Primitive failed'
]

{ #category : #printing }
LObject >> print [
	self printString do: [ :c | c print ]
]

{ #category : #printing }
LObject >> printNl [
	self print.
	LChar newline print
]

{ #category : #printing }
LObject >> printString [
	^ self class printString
]

{ #category : #services }
LObject >> question: text [
	| answer |
	text print.
	answer := LString input.
	answer notNil
		ifTrue: [ answer := answer at: 1 ifAbsent: [ $n ] ].
	^ answer = $y or: [ answer = $Y ]
]

{ #category : #'class membership' }
LObject >> respondsTo: aMessage [
	^ self class allMethods includes: aMessage
]

{ #category : #private }
LObject >> species [
	" By default, we re-instantiate ourselves as our own Class "
	^ self class
]

{ #category : #'error handling' }
LObject >> subclassResponsibility [
	self error: 'Subclass responsibility'
]

{ #category : #comparing }
LObject >> ~= arg [
	^ (self = arg) not
]

{ #category : #comparing }
LObject >> ~~ arg [
	^ (self == arg) not
]
