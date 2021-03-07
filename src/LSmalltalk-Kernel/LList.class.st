Class {
	#name : #LList,
	#superclass : #LCollection,
	#instVars : [
		'elements'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LList class >> with: elemA [
	| newList |
	newList := self new.
	newList add: elemA.
	^ newList
]

{ #category : #'instance creation' }
LList class >> with: elemA with: elemB [
	| newList |
	newList := self new.
	newList add: elemB.  newList add: elemA.
	^ newList
]

{ #category : #'instance creation' }
LList class >> with: elemA with: elemB with: elemC [
	| newList |
	newList := self new.
	newList add: elemC.  newList add: elemB.  newList add: elemA.
	^ newList
]

{ #category : #arithmetic }
LList >> + aCollection [
	^ self addAll: aCollection
]

{ #category : #adding }
LList >> add: anElement [
	elements := LLink value: anElement next: elements.
	^ anElement
]

{ #category : #adding }
LList >> addAll: aCollection [
	aCollection do: [ :element | self addLast: element ]
]

{ #category : #adding }
LList >> addLast: anElement [
	elements isNil
		ifTrue: [ self add: anElement]
		ifFalse: [ elements addLast: anElement ].
	^ anElement
]

{ #category : #accessing }
LList >> at: index [
	| link |
	link := self findLink: index ifAbsent: [ self badIndex ].
	^ link value
]

{ #category : #accessing }
LList >> at: index ifAbsent: aBlock [
	| link |
	link := self findLink: index ifAbsent: [nil].
	link isNil ifTrue: [ ^ aBlock value ].
	^ link value
]

{ #category : #accessing }
LList >> at: index put: value [
	| link |
	link := self findLink: index.
	link value: value
]

{ #category : #'as yet unclassified' }
LList >> badIndex [
	self error: 'Invalid LList index'
]

{ #category : #copying }
LList >> copy [
	^ self asList
]

{ #category : #enumerating }
LList >> do: aBlock [
	^ elements notNil ifTrue: [ elements do: aBlock ]
]

{ #category : #'as yet unclassified' }
LList >> findLink: index ifAbsent: aBlock [
	| idx link |
	link := elements.
	idx := index.
	link isNil ifTrue: [ ^ aBlock value ].
	[ link notNil ] whileTrue: [
		idx := idx-1.
		(idx = 0) ifTrue: [ ^ link ].
		link := link next
	].
	^ aBlock value
]

{ #category : #accessing }
LList >> first [
	^ self at: 1
]

{ #category : #testing }
LList >> isEmpty [
	^ elements isNil
]

{ #category : #removing }
LList >> remove: anElement [
	self remove: anElement
		ifAbsent: [ self emptyCollection ]
]

{ #category : #removing }
LList >> remove: anElement ifAbsent: exceptionBlock [
	elements isNil
		ifTrue: [ exceptionBlock value ]
		ifFalse: [ elements remove: anElement ifAbsent: exceptionBlock ]
]

{ #category : #removing }
LList >> removeFirst [
	elements isNil
		ifTrue: [ self emptyCollection ]
		ifFalse: [ elements := elements next ]
]

{ #category : #highlighting }
LList >> reverse [
	| newList |
	newList := LList new.
	self do: [ :element | newList add: element ].
	^ newList
]

{ #category : #enumerating }
LList >> reverseDo: aBlock [
	^ elements notNil ifTrue: [ elements reverseDo: aBlock ]
]

{ #category : #enumerating }
LList >> select: testBlock [
	| newList |
	newList := LList new.
	self reverseDo: [:element | (testBlock value: element)
		ifTrue: [ newList add: element ] ].
	^ newList
]
