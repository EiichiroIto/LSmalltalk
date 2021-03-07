Class {
	#name : #LTree,
	#superclass : #LCollection,
	#instVars : [
		'root'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #adding }
LTree >> add: anElement [
	root isNil
		ifTrue: [ root := LNode new: anElement ]
		ifFalse: [ root add: anElement ].
	^ anElement
]

{ #category : #adding }
LTree >> addAll: aCollection [
	aCollection do: [:element| self add: element ]
]

{ #category : #accessing }
LTree >> at: key ifAbsent: exceptionBlock [
	root isNil
		ifTrue: [ ^ exceptionBlock value ]
		ifFalse: [ ^ root at: key ifAbsent: exceptionBlock ]
]

{ #category : #enumerating }
LTree >> collect: transformBlock [
	| newTree |
	newTree := LTree new.
	self do: [:element| newTree add: (transformBlock value: element)].
	^ newTree
]

{ #category : #copying }
LTree >> copy [
	^ LTree new addAll: self
]

{ #category : #enumerating }
LTree >> do: aBlock [
	root notNil ifTrue: [ root do: aBlock ]
]

{ #category : #accessing }
LTree >> first [
	root notNil
		ifTrue: [ ^root first ]
		ifFalse: [ self emptyCollection ]
]

{ #category : #testing }
LTree >> isEmpty [
	^ root isNil
]

{ #category : #removing }
LTree >> remove: key ifAbsent: exceptionBlock [
	root isNil
		ifTrue: [ exceptionBlock value ]
		ifFalse: [ root := root remove: key ifAbsent: exceptionBlock ]
]

{ #category : #removing }
LTree >> removeFirst [
	root isNIl ifTrue: [ self emptyCollection ].
	root := root removeFirst
]

{ #category : #enumerating }
LTree >> reverseDo: aBlock [
	root notNil ifTrue: [ root reverseDo: aBlock ]
]

{ #category : #enumerating }
LTree >> select: testBlock [
	| newTree |
	newTree := LTree new.
	self do: [:element|
		(testBlock value: element)
			ifTrue: [newTree add: element]
	].
	^ newTree
]
