Class {
	#name : #LMagnitude,
	#superclass : #LObject,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #comparing }
LMagnitude >> <= arg [
	^ self < arg or: [ self = arg ]
]

{ #category : #comparing }
LMagnitude >> > arg [
	^ arg < self
]

{ #category : #comparing }
LMagnitude >> >= arg [
	^ (self > arg) or: [ self = arg ]
]

{ #category : #comparing }
LMagnitude >> between: low and: high [
	^ low <= self and: [ self <= high ]
]

{ #category : #accessing }
LMagnitude >> max: arg [
	^ self < arg ifTrue: [ arg ] ifFalse: [ self ]
]

{ #category : #accessing }
LMagnitude >> min: arg [
	^ self < arg ifTrue: [ self ] ifFalse: [ arg ]
]
