Class {
	#name : #LInteger,
	#superclass : #LNumber,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LInteger class >> new: low [
	self primNo: 32 a: low.
	self primitiveFailed
]

{ #category : #arithmetic }
LInteger >> * arg [
	self primNo: 28 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self * arg asInteger].
	self primitiveFailed
]

{ #category : #arithmetic }
LInteger >> + arg [
	self primNo: 27 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self + arg asInteger].
	self primitiveFailed
]

{ #category : #arithmetic }
LInteger >> - arg [
	self primNo: 29 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self - arg asInteger].
	self primitiveFailed
]

{ #category : #comparing }
LInteger >> < arg [
	self primNo: 30 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self < arg asInteger].
	self primitiveFailed
]

{ #category : #comparing }
LInteger >> = arg [
	self primNo: 31 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self = arg asInteger].
	self primitiveFailed
]

{ #category : #converting }
LInteger >> asInteger [
	^self
]

{ #category : #converting }
LInteger >> asSmallInt [
	self primNo: 33 a: self.
	self overflow
]

{ #category : #comparing }
LInteger >> hash [
	self primNo: 33 a: self.
	^ (self rem: 65536) asSmallInt
]

{ #category : #arithmetic }
LInteger >> quo: arg [
	self primNo: 25 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self quo: arg asInteger].
	(0 = arg) ifTrue: [^ self error: 'division by zero'].
	self primitiveFailed
]

{ #category : #arithmetic }
LInteger >> rem: arg [
	self primNo: 26 a: self b: arg.
	(arg isMemberOf: LInteger) ifFalse: [^self rem: arg asInteger].
	(0 = arg) ifTrue: [^ self error: 'division by zero'].
	self primitiveFailed
]

{ #category : #'as yet unclassified' }
LInteger >> truncSmallInt [
	self primNo: 40 a: self.
	self primitiveFailed
]
