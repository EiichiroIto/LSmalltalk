Class {
	#name : #LOrderedArray,
	#superclass : #LArray,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #adding }
LOrderedArray >> add: value [
	^ self insert: value at: (self location: value)
]

{ #category : #testing }
LOrderedArray >> includes: value [
	| position |
	position := self location: value.
	^ position <= self size and: [ value = (self at: position) ]
]

{ #category : #accessing }
LOrderedArray >> location: value [
	| low high mid |
	low := 1.
	high := self size + 1.
	[ low < high ]
		whileTrue: [ mid := low + high quo: 2.
			(self at: mid) < value
				ifTrue: [ low := mid + 1 ]
				ifFalse: [ high := mid ] ].
	^ low
]
