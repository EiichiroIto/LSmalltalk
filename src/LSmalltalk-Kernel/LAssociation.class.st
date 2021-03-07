Class {
	#name : #LAssociation,
	#superclass : #LMagnitude,
	#instVars : [
		'key',
		'value'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LAssociation class >> key: k [
		"key is set once, value is resettable"
	^ self in: self new at: 1 put: k
]

{ #category : #'as yet unclassified' }
LAssociation class >> key: k value: v [ | ret |
		"key is set once, value is resettable"
	ret := self new.
	self in: ret at: 1 put: k.
	self in: ret at: 2 put: v.
	^ ret
]

{ #category : #comparing }
LAssociation >> < k [
		"compare both with keys and associations"
	(k class == LAssociation)
		ifTrue: [ ^ key < k key ]
		ifFalse: [ ^ key < k ]
]

{ #category : #comparing }
LAssociation >> = k [
		"compare both with keys and associations"
	(k class == LAssociation)
		ifTrue: [ ^ key = k key ]
		ifFalse: [ ^ key = k ]
]

{ #category : #comparing }
LAssociation >> hash [
	^ key hash
]

{ #category : #accessing }
LAssociation >> key [
	^ key
]

{ #category : #printing }
LAssociation >> printString [
	^ '(' + key printString + ' -> ' + value printString + ')'
]

{ #category : #evaluating }
LAssociation >> value [
	^ value
]

{ #category : #accessing }
LAssociation >> value: v [
	value := v
]
