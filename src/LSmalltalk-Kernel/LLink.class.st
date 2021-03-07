Class {
	#name : #LLink,
	#superclass : #LObject,
	#instVars : [
		'value',
		'next'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LLink class >> value: v [
		" return a new link with given value field "
		" and empty link field "
	^ self in: self new at: 1 put: v
]

{ #category : #'as yet unclassified' }
LLink class >> value: v next: n [	| new |
		" return a new link with the given fields "
	new := self new.
	self in: new at: 1 put: v.
	self in: new at: 2 put: n.
	^ new
]

{ #category : #adding }
LLink >> addLast: anElement [
	next notNil
		ifTrue: [ ^ next addLast: anElement ]
		ifFalse: [ next := LLink value: anElement ]
]

{ #category : #enumerating }
LLink >> do: aBlock [
	aBlock value: value.
	next notNil ifTrue: [ ^ next do: aBlock ]
]

{ #category : #accessing }
LLink >> next [
	^ next
]

{ #category : #removing }
LLink >> remove: anElement ifAbsent: exceptionBlock [
	value = anElement
		ifTrue: [ ^ next ]
		ifFalse: [ next notNil
			ifTrue: [ next := next remove: anElement
				ifAbsent: exceptionBlock. ^ self ]
			ifFalse: [ ^ exceptionBlock value ] ]
]

{ #category : #enumerating }
LLink >> reverseDo: aBlock [
	next notNil ifTrue: [ next reverseDo: aBlock ].
	aBlock value: value
]

{ #category : #evaluating }
LLink >> value [
	^ value
]

{ #category : #accessing }
LLink >> value: val [
	value := val
]
