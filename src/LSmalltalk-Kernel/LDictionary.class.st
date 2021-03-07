Class {
	#name : #LDictionary,
	#superclass : #LCollection,
	#instVars : [
		'keys',
		'values'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LDictionary class >> new [
	| newDict |
	newDict := super new.
	self in: newDict at: 1 put: (LOrderedArray new: 0).
	self in: newDict at: 2 put: (LArray new: 0).
	^ newDict
]

{ #category : #adding }
LDictionary >> add: anAssoc [
	self at: anAssoc key put: anAssoc value
]

{ #category : #accessing }
LDictionary >> at: key [
	^ self at: key ifAbsent: [ self noKey ]
]

{ #category : #accessing }
LDictionary >> at: key ifAbsent: exceptionBlock [
	| position |
	position := keys location: key.
	((position <= keys size) and: [ key = (keys at: position)])
		ifTrue: [ ^ values at: position ]
		ifFalse: [ ^ exceptionBlock value ]
]

{ #category : #accessing }
LDictionary >> at: key put: value [
	| position |
	position := keys location: key.
	(position <= keys size and: [ key = (keys at: position)])
		ifTrue: [ values at: position put: value ]
		ifFalse: [ keys := keys insert: key at: position.
			values := values insert: value at: position ].
	^ value
]

{ #category : #enumerating }
LDictionary >> binaryDo: aBlock [
	1 to: keys size do:
		[:i | aBlock value: (keys at: i) value: (values at: i) ]
]

{ #category : #enumerating }
LDictionary >> do: aBlock [
	values do: aBlock
]

{ #category : #testing }
LDictionary >> isEmpty [
	^ keys isEmpty
]

{ #category : #'as yet unclassified' }
LDictionary >> keysAsArray [
	| ret |
	ret := LArray new: keys size.
	1 to: keys size do: [ :i | ret at: i put: (keys at: i) ].
	^ ret
]

{ #category : #enumerating }
LDictionary >> keysDo: aBlock [
	1 to: keys size do: [ :i | aBlock value: (keys at: i) ]
]

{ #category : #'as yet unclassified' }
LDictionary >> noKey [
	self error: 'key not found in dictionary lookup'
]

{ #category : #printing }
LDictionary >> printString [
	| count res |
	res := self class printString + ' ('.
	count := 0.
	self
		binaryDo: [ :k :elem | 
			count = 0
				ifFalse: [ res := res + ', ' ].
			res := res + (k printString + ' -> ' + elem printString).
			count := count + 1.
			count >= 20
				ifTrue: [ ^ res + ', ...)' ] ].
	^ res + ')'
]

{ #category : #removing }
LDictionary >> removeKey: key [
	^ self removeKey: key ifAbsent: [ self noKey ]
]

{ #category : #removing }
LDictionary >> removeKey: key ifAbsent: exceptionBlock [
	| position |
	position := keys location: key.
	(position <= keys size and: [ key = (keys at: position) ])
		ifTrue: [ keys := keys removeIndex: position.
			values := values removeIndex: position ]
		ifFalse: [ ^ exceptionBlock value ]
]
