Class {
	#name : #LMethodCache,
	#superclass : #Object,
	#instVars : [
		'entries',
		'cacheHit',
		'cacheMiss'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #accessing }
LMethodCache >> cacheHit [
	^ cacheHit
]

{ #category : #accessing }
LMethodCache >> cacheHit: anObject [
	cacheHit := anObject
]

{ #category : #accessing }
LMethodCache >> cacheMiss [
	^ cacheMiss
]

{ #category : #accessing }
LMethodCache >> cacheMiss: anObject [
	^ cacheMiss := anObject
]

{ #category : #constants }
LMethodCache >> cacheSize [
	^ 703
]

{ #category : #accessing }
LMethodCache >> entries [
	^ entries
]

{ #category : #accessing }
LMethodCache >> entries: anObject [
	entries := anObject
]

{ #category : #api }
LMethodCache >> flush [
	entries := Array new: self cacheSize.
	entries
		withIndexDo: [ :each :index | entries at: index put: LMethodCacheEntry new ]
]

{ #category : #private }
LMethodCache >> indexOfMessageSelector: anInteger receiverClass: anInteger2 [
	^ (anInteger + anInteger2) \\ self cacheSize + 1
]

{ #category : #initialization }
LMethodCache >> initialize [
	cacheHit := cacheMiss := 0.
	self flush
]

{ #category : #api }
LMethodCache >> methodAtMessageSelector: anInteger receiverClass: anInteger2 ifAbsent: aBlock [
	| low cache r |
	low := self
		indexOfMessageSelector: anInteger
		receiverClass: anInteger2.
	cache := entries at: low + 1.
	^ (cache name = anInteger and: [ cache classOfMethod = anInteger2 ])
		ifTrue: [ cacheHit := cacheHit + 1.
			cache method ]
		ifFalse: [ cacheMiss := cacheMiss + 1.
			r := aBlock value.
			r = 0
				ifFalse: [ self
						registerMessageSelector: anInteger
						receiverClass: anInteger2
						method: r ].
			r ]
]

{ #category : #private }
LMethodCache >> registerMessageSelector: anInteger receiverClass: anInteger2 method: anInteger3 [
	| low |
	low := self indexOfMessageSelector: anInteger receiverClass: anInteger2.
	(entries at: low)
		name: anInteger;
		classOfMethod: anInteger2;
		method: anInteger3
]
