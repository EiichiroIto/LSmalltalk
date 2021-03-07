Class {
	#name : #LNumber,
	#superclass : #LMagnitude,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LNumber class >> new [
	" can't create this way, return zero "
	^ 0
]

{ #category : #'path commands' }
LNumber >> absolute [
	(self negative) ifTrue: [ ^ self negated ]
]

{ #category : #converting }
LNumber >> asChar [
	^ LChar new: (self asSmallInt)
]

{ #category : #converting }
LNumber >> asDigit [
	(self < 10) ifTrue:
		[ ^(LChar new: (self asSmallInt + 48)) asString ].
	^(LChar new: (self asSmallInt + 55)) asString
]

{ #category : #accessing }
LNumber >> atRandom [
	" Return random number from 1 to self "
	(self < 2) ifTrue: [ ^ self ].
	^ ((1 to: self) atRandom)
]

{ #category : #'bit manipulation' }
LNumber >> bitAnd: arg [
	^ (self asSmallInt bitAnd: arg)
]

{ #category : #'bit manipulation' }
LNumber >> bitOr: arg [
	^ (self asSmallInt bitOr: arg)
]

{ #category : #'bit manipulation' }
LNumber >> bitShift: arg [
	^ (self asSmallInt bitShift: arg)
]

{ #category : #'as yet unclassified' }
LNumber >> factorial [
	self <= 1 ifTrue: [ ^ 1 ]
	ifFalse: [ ^ (self - 1) factorial * self ]
]

{ #category : #arithmetic }
LNumber >> negated [
	^0-self
]

{ #category : #testing }
LNumber >> negative [
	^ self < 0
]

{ #category : #'as yet unclassified' }
LNumber >> overflow [
	self error: 'Numeric overflow'
]

{ #category : #printing }
LNumber >> printString [
	^ self printWidth: 1 base: 10
]

{ #category : #printing }
LNumber >> printWidth: width [
	^ self printWidth: width base: 10
]

{ #category : #printing }
LNumber >> printWidth: width base: base [
	| res n dig wasNeg wide |
	res := ''.
	(self negative) ifTrue: [
		wasNeg := true.
		wide := width-1.
		n := self negated
	] ifFalse: [
		wasNeg := false.
		wide := width.
		n := self
	].
	[true] whileTrue: [
		res := ((n rem: base) asDigit) + res.
		n := n quo: base.
		(n = 0) ifTrue: [
			((res size)+1) to: wide do: [:ignore|
				res := '0' + res
			].
			wasNeg ifTrue: [ res := '-' + res ].
			^res
		]
	]
]

{ #category : #accessing }
LNumber >> to: limit [
	^ LInterval from: self to: limit step: 1
]

{ #category : #'as yet unclassified' }
LNumber >> to: limit by: step [
	^ LInterval from: self to: limit step: step
]

{ #category : #'as yet unclassified' }
LNumber >> to: limit by: step do: aBlock [
	| i |
	i := self.
	[ i <= limit ] whileTrue: [ aBlock value: i. i := i + step ]
]

{ #category : #'as yet unclassified' }
LNumber >> to: limit do: aBlock [
	| i |
	" optimize arithmetic loops "
	i := self.
	[ i <= limit ]
		whileTrue: [ aBlock value: i.
			i := i + 1 ]
]
