"
A LGarbageCollectorTest is a test class for testing the behavior of LGarbageCollector
"
Class {
	#name : #LGarbageCollectorTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LGarbageCollectorTest >> newAllocator [
	^ LDynamicAllocator new
		memory: LObjectMemory new;
		yourself
]

{ #category : #private }
LGarbageCollectorTest >> newGC [
	^ LGarbageCollector new
		yourself
]

{ #category : #test }
LGarbageCollectorTest >> testAllocator [
	| gc a |
	gc := self newGC.
	self assert: gc allocator isNil.
	a := self newAllocator.
	gc allocator: a.
	self assert: gc allocator identicalTo: a
]

{ #category : #test }
LGarbageCollectorTest >> testGcCount [
	| a |
	a := self newGC.
	self assert: a gcCount equals: 0.
	a gcCount: 123.
	self assert: a gcCount equals: 123
]

{ #category : #test }
LGarbageCollectorTest >> testInitialize [
	| a |
	a := self newGC.
	self assert: a gcCount equals: 0
]

{ #category : #test }
LGarbageCollectorTest >> testMemory [
	| gc a |
	gc := self newGC.
	a := self newAllocator.
	gc allocator: a.
	self assert: gc memory identicalTo: a memory
]

{ #category : #test }
LGarbageCollectorTest >> testWhenCompleted [
	| gc |
	gc := self newGC.
	self assert: gc whenCompleted isNil.
	gc whenCompleted: [ 1 + 2 ].
	self assert: gc whenCompleted isBlock
]
