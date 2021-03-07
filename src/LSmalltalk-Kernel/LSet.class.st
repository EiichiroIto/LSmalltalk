Class {
	#name : #LSet,
	#superclass : #LCollection,
	#instVars : [
		'members',
		'growth'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LSet class >> new [
	^ self new: 10
]

{ #category : #'as yet unclassified' }
LSet class >> new: size [
	| ret |
	ret := super new.
	self in: ret at: 1 put: (LArray new: size).
	self in: ret at: 2 put: size.
	^ ret
]

{ #category : #'as yet unclassified' }
LSet class >> with: objA [
	| ret |
	ret := self new.
	ret add: objA.
	^ ret
]

{ #category : #'as yet unclassified' }
LSet class >> with: objA with: objB [
	| ret |
	ret := self new.
	ret add: objA. ret add: objB.
	^ ret
]

{ #category : #'as yet unclassified' }
LSet class >> with: objA with: objB with: objC [
	| ret |
	ret := self new.
	ret add: objA. ret add: objB. ret add: objC.
	^ ret
]

{ #category : #adding }
LSet >> add: elem [
     | pos |
	" Find the appropriate slot... if none, need to grow the LSet "
	pos := self location: elem.
	pos isNil ifTrue: [
		self grow.
		^ self add: elem
	].

	" If the slot is nil, this is a new entry which we put in place now.
	  If it wasn't nil, we still re-store it so that if it's an
	  Association, the value portion will be updated. "
	members at: pos put: elem.
	^ elem
]

{ #category : #accessing }
LSet >> at: value ifAbsent: aBlock [
	| pos |
	pos := self location: value.
	((pos isNil) or: [ (members at: pos) isNil ]) ifTrue: [
		^ aBlock value
	].
	^ value
]

{ #category : #'as yet unclassified' }
LSet >> compare: t and: e [
	^ t = e
]

{ #category : #enumerating }
LSet >> do: aBlock [
	members do: [:elem| elem notNil ifTrue: [ aBlock value: elem ]]
]

{ #category : #private }
LSet >> grow [
	| old |
	" Re-create ourselves in place with a new, bigger storage "
	old := members.
	members := LArray new: old size + growth.

	" Re-insert each existing LSet member "
	old do: [ :elem | self add: elem ]
]

{ #category : #accessing }
LSet >> indexOf: value [
	^ self at: value ifAbsent: [ nil ]
]

{ #category : #accessing }
LSet >> location: elem [
	| pos start t |
	start := pos := (elem hash rem: members size) + 1.
	[ true ] whileTrue: [
		" Return this position if we match, or have reached
		  a nil slot. "
		t := members at: pos.
		((t isNil) or: [self compare: t and: elem]) ifTrue: [
			^ pos
		].

		" Advance to next slot, circularly "
		pos := pos + 1.
		(pos > members size) ifTrue: [
			pos := 1
		].

		" Return nil if we have scanned the whole LSet "
		(pos = start) ifTrue: [ ^ nil ]
	]
]

{ #category : #'as yet unclassified' }
LSet >> rehash: start [
	| pos elem |
	pos := start.
	[ true ]
		whileTrue: [ " Advance to next slot, ceasing when we reach our start "
			pos := pos + 1.
			pos > members size
				ifTrue: [ pos := 1 ].
			pos = start
				ifTrue: [ ^ self ].

			" If we reach a nil slot, there are no further rehash
		  worries. "
			elem := members at: pos.
			elem isNil
				ifTrue: [ ^ self ].

			" Nil out the slot, and then re-insert the element "
			members at: pos put: nil.
			self add: elem ]
]

{ #category : #removing }
LSet >> remove: elem [
	^ self remove: elem ifAbsent: [self noElement ]
]

{ #category : #removing }
LSet >> remove: elem ifAbsent: aBlock [
	| pos |
	" If not found, return error "
	pos := self location: elem.
	(pos isNil or: [ (members at: pos) isNil ])
		ifTrue: [ aBlock value ].

	" Remove our element from the LSet "
	members at: pos put: nil.

	" Re-hash all that follow "
	self rehash: pos.
	^ elem
]

{ #category : #accessing }
LSet >> size [
	| tally |
	tally := 0.
	members
		do: [ :elem | 
			elem notNil
				ifTrue: [ tally := tally + 1 ] ].
	^ tally
]
