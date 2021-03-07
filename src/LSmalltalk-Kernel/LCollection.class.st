Class {
	#name : #LCollection,
	#superclass : #LMagnitude,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #comparing }
LCollection >> < aCollection [
	self
		do: [ :element | 
			(aCollection includes: element)
				ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #comparing }
LCollection >> = aCollection [
	^ self < aCollection and: [ aCollection < self ]
]

{ #category : #accessing }
LCollection >> anyOne [
	self do: [ :it | ^ it ].
	self emptyCollection
]

{ #category : #converting }
LCollection >> asArray [
	| newArray index |
	newArray := LArray new: self size.
	index := 1.
	self do: [ :element | newArray at: index put: element.
		index := index + 1 ].
	^ newArray
]

{ #category : #converting }
LCollection >> asList [
	^ LList new addAll: self
]

{ #category : #converting }
LCollection >> asString [
	| newString index |
	newString := LString new: self size.
	index := 1.
	self
		do: [ :element | 
			newString at: index put: element.
			index := index + 1 ].
	^ newString
]

{ #category : #accessing }
LCollection >> at: value [
	^ self at: value ifAbsent: [ self noElement ]
]

{ #category : #accessing }
LCollection >> at: value ifAbsent: exceptionBlock [
	self do: [ :element | element = value ifTrue: [ ^ element ]].
	^ exceptionBlock value
]

{ #category : #enumerating }
LCollection >> collect: transformBlock [	| newList |
	newList := LList new.
	self do: [:element | newList addLast: (transformBlock value: element)].
	^ newList
]

{ #category : #enumerating }
LCollection >> do: aBlock [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
LCollection >> emptyCollection [
	self error: (self class printString + ' is empty')
]

{ #category : #'instance creation' }
LCollection >> from: argLow [
	^ self from: argLow to: (self size)
]

{ #category : #'instance creation' }
LCollection >> from: argLow to: argHigh [
	| ret idx size base low high |
	low := argLow max: 1.
	high := argHigh min: self size.
	size := high - low + 1.
	size < 1
		ifTrue: [ ^ LArray new: 0 ].
	ret := LArray new: size.
	base := idx := 1.
	self
		do: [ :elem | 
			(idx >= low and: [ idx <= high ])
				ifTrue: [ ret at: base put: elem.
					base := base + 1.
					base > size
						ifTrue: [ ^ ret ] ].
			idx := idx + 1 ].
	^ ret
]

{ #category : #testing }
LCollection >> includes: value [
	self at: value ifAbsent: [ ^ false ].
	^ true
]

{ #category : #testing }
LCollection >> isEmpty [
	" empty if there are no elements "
	^ self size = 0
]

{ #category : #'as yet unclassified' }
LCollection >> noElement [
	self error: 'Element not present'
]

{ #category : #'as yet unclassified' }
LCollection >> occurencesOf: obj [
	| count |
	count := 0.
	self
		do: [ :o | 
			o = obj
				ifTrue: [ count := count + 1 ] ].
	^ count
]

{ #category : #printing }
LCollection >> printString [
	| count res |
	res := super printString.
	(self respondsTo: #do:)
		ifFalse: [ ^ res ].
	count := 0.
	res := res + ' ('.
	self
		basicDo: [ :elem | 
			count = 0
				ifFalse: [ res := res + ' ' ].
			res := res + elem printString.
			count := count + 1.
			count >= 20
				ifTrue: [ ^ res + ' ...)' ] ].
	^ res + ')'
]

{ #category : #enumerating }
LCollection >> reject: testBlock [
	" select the things that do not match predicate "
	^ self select: [:x | (testBlock value: x) not ]
]

{ #category : #enumerating }
LCollection >> select: testBlock [
	| newList |
	newList := LList new.
	self
		do: [ :x | 
			(testBlock value: x)
				ifTrue: [ newList addLast: x ] ].
	^ newList
]

{ #category : #accessing }
LCollection >> size [
	| tally |
	tally := 0.
	self do: [ :i | tally := tally + 1 ].
	^ tally
]
