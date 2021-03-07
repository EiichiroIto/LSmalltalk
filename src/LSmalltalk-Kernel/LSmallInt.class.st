Class {
	#name : #LSmallInt,
	#superclass : #LNumber,
	#classInstVars : [
		'seed'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #accessing }
LSmallInt class >> atRandom [
	" Set up seed one time.  TBD: init from something external;
	  getpid() or time() "
	seed isNil ifTrue: [ seed := 17 ].

	" Rotate the random number generator. "
	seed := ((seed * -1043968403 + 12345) truncSmallInt)
		bitAnd: 268435455.
	^ seed
]

{ #category : #arithmetic }
LSmallInt >> * arg [
	self primNo: 15 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self * arg asSmallInt].
	self primitiveFailed
]

{ #category : #arithmetic }
LSmallInt >> + arg [
	self primNo: 10 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self + arg asSmallInt].
	self primitiveFailed
]

{ #category : #arithmetic }
LSmallInt >> - arg [
	self primNo: 16 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self - arg asSmallInt].
	self primitiveFailed
]

{ #category : #arithmetic }
LSmallInt >> / arg [
	^ self quo: arg
]

{ #category : #comparing }
LSmallInt >> < arg [
	self primNo: 13 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self < arg asSmallInt].
	self primitiveFailed
]

{ #category : #comparing }
LSmallInt >> = arg [
	self primNo: 14 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self = arg asSmallInt].
	self primitiveFailed
]

{ #category : #converting }
LSmallInt >> asInteger [
	^ LInteger new: self
]

{ #category : #converting }
LSmallInt >> asSmallInt [
	^ self
]

{ #category : #'bit manipulation' }
LSmallInt >> bitAnd: arg [
	self primNo: 37 a: self b: arg.
	^ (self bitAnd: arg asSmallInt)
]

{ #category : #'bit manipulation' }
LSmallInt >> bitOr: arg [
	self primNo: 36 a: self b: arg.
	^ (self bitOr: arg asSmallInt)
]

{ #category : #'bit manipulation' }
LSmallInt >> bitShift: arg [
	self primNo: 39 a: self b: arg.
	(arg isKindOf: LSmallInt) ifTrue: [ self overflow ].
	^ (self bitShift: arg asSmallInt)
]

{ #category : #comparing }
LSmallInt >> hash [
	^ self
]

{ #category : #arithmetic }
LSmallInt >> quo: arg [
	self primNo: 11 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self quo: arg asSmallInt].
	(0 = arg) ifTrue: [^ self error: 'division by zero'].
	self primitiveFailed
]

{ #category : #arithmetic }
LSmallInt >> rem: arg [
	self primNo: 12 a: self b: arg.
	(arg isMemberOf: LSmallInt) ifFalse: [^self rem: arg asSmallInt].
	(0 = arg) ifTrue: [^ self error: 'division by zero'].
	self primitiveFailed
]

{ #category : #'as yet unclassified' }
LSmallInt >> truncSmallInt [
	^ self
]
