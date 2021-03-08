Class {
	#name : #LMemoryAllocator,
	#superclass : #Object,
	#instVars : [
		'memory'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #api }
LMemoryAllocator >> allocateMemory: anInteger [
	memory initialAllocate: anInteger
]

{ #category : #private }
LMemoryAllocator >> binaryAlloc: anInteger [
	| osize addr |
	osize := memory trueSizeOf: anInteger.
	addr := self gcAlloc: osize.
	memory objectAt: addr size: anInteger.
	memory markBinaryObjectAt: addr.
	^ addr
]

{ #category : #private }
LMemoryAllocator >> dynamicAllocatorClass [
	^ LDynamicAllocator
]

{ #category : #accessing }
LMemoryAllocator >> memory [
	^ memory
]

{ #category : #accessing }
LMemoryAllocator >> memory: anObject [
	memory := anObject.
	self reset
]

{ #category : #private }
LMemoryAllocator >> reset [
	"self subclassResponsibility"
]
