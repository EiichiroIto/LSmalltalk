Class {
	#name : #LInterval,
	#superclass : #LCollection,
	#instVars : [
		'low',
		'high',
		'step'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LInterval class >> from: l to: h step: s [ | newInterval |
	newInterval := self in: self new at: 1 put: l.
	self in: newInterval at: 2 put: h.
	self in: newInterval at: 3 put: s.
	^ newInterval
]

{ #category : #accessing }
LInterval >> atRandom [
	| ret |
	" Return a random element from our sequence "
	ret := (LSmallInt atRandom) rem: ((high - low + 1) quo: step).
	^ low + (ret * step)
]

{ #category : #enumerating }
LInterval >> do: aBlock [
	| current |
	current := low.
	(step < 0)
		ifTrue: [
			[ current >= high ] whileTrue:
				[ aBlock value: current.
				current := current + step ] ]
		ifFalse: [
			[ current <= high ] whileTrue:
				[ aBlock value: current.
				current := current + step ] ]
]

{ #category : #accessing }
LInterval >> high [
	^ high
]

{ #category : #accessing }
LInterval >> high: h [
	high := h
]

{ #category : #testing }
LInterval >> includes: val [
	" Check within range first "
	((val < low) or: [val > high]) ifTrue: [ ^ false ].
	" Then check if in equivalence class of interval "
	^ ((val - low) rem: step) = 0
]

{ #category : #accessing }
LInterval >> low [
	^ low
]

{ #category : #accessing }
LInterval >> low: l [
	low := l
]

{ #category : #printing }
LInterval >> printString [
	| s |
	s := (self class printString) + ' <' +
		low printString + '..' + high printString.
	(step ~= 1) ifTrue: [ s := s + ' by ' + step printString ].
	^ s + '>'
]
