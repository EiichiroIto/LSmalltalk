Class {
	#name : #LFalse,
	#superclass : #LBoolean,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LFalse class >> new [
	" there is only one false value "

	^ false
]

{ #category : #controlling }
LFalse >> and: aBlock [
	^ false
]

{ #category : #controlling }
LFalse >> ifTrue: trueBlock ifFalse: falseBlock [
	^ falseBlock value
]

{ #category : #'logical operations' }
LFalse >> not [
	^ true
]

{ #category : #controlling }
LFalse >> or: aBlock [
	^ aBlock value
]

{ #category : #printing }
LFalse >> printString [
	^ 'false'
]
