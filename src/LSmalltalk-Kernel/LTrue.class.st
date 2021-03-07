Class {
	#name : #LTrue,
	#superclass : #LBoolean,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LTrue class >> new [
	" there is only one true value "

	^ true
]

{ #category : #controlling }
LTrue >> and: aBlock [
	^ aBlock value
]

{ #category : #controlling }
LTrue >> ifTrue: trueBlock ifFalse: falseBlock [
	^ trueBlock value
]

{ #category : #'logical operations' }
LTrue >> not [
	^ false
]

{ #category : #controlling }
LTrue >> or: aBlock [
	^ true
]

{ #category : #printing }
LTrue >> printString [
	^ 'true'
]
