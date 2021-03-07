Class {
	#name : #LIdentitySet,
	#superclass : #LSet,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LIdentitySet >> compare: t and: e [
	^ t == e
]
