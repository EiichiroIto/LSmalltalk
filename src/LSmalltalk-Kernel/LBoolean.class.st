Class {
	#name : #LBoolean,
	#superclass : #LObject,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #controlling }
LBoolean >> and: aBlock [
	^ self
		ifTrue: [ aBlock value ]
		ifFalse: [ false ]
]

{ #category : #controlling }
LBoolean >> ifFalse: aBlock [
	^ self
		ifTrue: [ nil ]
		ifFalse: [ aBlock value ]
]

{ #category : #controlling }
LBoolean >> ifFalse: falseBlock ifTrue: trueBlock [
	^ self
		ifTrue: [ trueBlock value ]
		ifFalse: [ falseBlock value ]
]

{ #category : #controlling }
LBoolean >> ifTrue: aBlock [
	^ self
		ifTrue: [ aBlock value ]
		ifFalse: [ nil ]
]

{ #category : #'logical operations' }
LBoolean >> not [
	^ self
		ifTrue: [ false ]
		ifFalse: [ true ]
]

{ #category : #controlling }
LBoolean >> or: aBlock [
	^ self
		ifTrue: [ true ]
		ifFalse: [ aBlock value ]
]
