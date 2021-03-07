Class {
	#name : #LGarbageCollector,
	#superclass : #Object,
	#instVars : [
		'gcCount',
		'allocator',
		'whenCompleted'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #accessing }
LGarbageCollector >> allocator [
	^ allocator
]

{ #category : #accessing }
LGarbageCollector >> allocator: anObject [
	allocator := anObject
]

{ #category : #enumerating }
LGarbageCollector >> garbageCollect: anInteger [
	self subclassResponsibility
]

{ #category : #accessing }
LGarbageCollector >> gcCount [
	^ gcCount
]

{ #category : #accessing }
LGarbageCollector >> gcCount: anObject [
	gcCount := anObject
]

{ #category : #initialization }
LGarbageCollector >> initialize [
	gcCount := 0
]

{ #category : #private }
LGarbageCollector >> memory [
	^ allocator memory
]

{ #category : #accessing }
LGarbageCollector >> whenCompleted [
	^ whenCompleted
]

{ #category : #accessing }
LGarbageCollector >> whenCompleted: anObject [
	whenCompleted := anObject
]
