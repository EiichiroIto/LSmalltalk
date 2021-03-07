Class {
	#name : #LNode,
	#superclass : #LObject,
	#instVars : [
		'value',
		'left',
		'right'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LNode class >> new: value [
	" creation, left left and right empty "
	^ self in: self new at: 1 put: value
]

{ #category : #adding }
LNode >> add: anElement [
	value < anElement
		ifTrue: [ right notNil
			ifTrue: [ right add: anElement ]
			ifFalse: [ right := LNode new: anElement ] ]
		ifFalse: [ left notNil
			ifTrue: [ left add: anElement ]
			ifFalse: [ left := LNode new: anElement ] ]
]

{ #category : #accessing }
LNode >> at: key ifAbsent: exceptionBlock [
	value = key ifTrue: [ ^ value ].
	value < key
		ifTrue: [ right notNil
			ifTrue: [ ^ right at: key ifAbsent: exceptionBlock ]
			ifFalse: [ ^ exceptionBlock value ] ]
		ifFalse: [ left notNil
			ifTrue: [ ^ left at: key ifAbsent: exceptionBlock ]
			ifFalse: [ ^ exceptionBlock value ] ]
]

{ #category : #enumerating }
LNode >> do: aBlock [
	left notNil ifTrue: [ left do: aBlock ].
	aBlock value: value.
	^ right notNil ifTrue: [ right do: aBlock ]
]

{ #category : #accessing }
LNode >> first [
	left notNil
		ifTrue: [ ^ left first ]
		ifFalse: [ ^ value ]
]

{ #category : #removing }
LNode >> remove: key ifAbsent: exceptionBlock [
	value = key
		ifTrue: [ right notNil
			ifTrue: [ value := right first.
			right := right removeFirst.
			^ self ]
			ifFalse: [ ^ left ] ].
	value < key
		ifTrue: [ right notNil
			ifTrue: [ right := right remove: key ifAbsent: exceptionBlock ]
			ifFalse: [ ^ exceptionBlock value ] ]
		ifFalse: [ left notNil
			ifTrue: [ left := left removeL key ifAbsent: exceptionBlock ]
			ifFalse: [ ^ exceptionBlock value ] ]
]

{ #category : #removing }
LNode >> removeFirst [
	left notNil
		ifTrue: [ left := left removeFirst. ^ self ]
		ifFalse: [ ^ right ]
]

{ #category : #enumerating }
LNode >> reverseDo: aBlock [
	right notNil ifTrue: [ right do: aBlock ].
	aBlock value: value.
	left notNil ifTrue: [ left do: aBlock ]
]

{ #category : #evaluating }
LNode >> value [
	^ value
]
