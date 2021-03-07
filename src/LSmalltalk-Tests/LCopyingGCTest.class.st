"
A LCopyGCTest is a test class for testing the behavior of LCopyGC
"
Class {
	#name : #LCopyingGCTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LCopyingGCTest >> newAllocator [
	^ LDynamicAllocator new
		memory: LObjectMemory new;
		yourself
]

{ #category : #private }
LCopyingGCTest >> newGC [
	^ LCopyingGC new
		yourself
]

{ #category : #test }
LCopyingGCTest >> testMove [
	| a gc m d1 d2 r1 r2 t |
	gc := self newGC.
	a := self newAllocator.
	m := a memory.
	a allocate: 100.
	a dynamicStart: 1.
	a memoryPointer: 5.
	a gc: gc.
	gc allocator: a.
	gc setupSpaces.
	d1 := a gcIAlloc: 5.
	self assert: (a isInCurrentSpace: d1).
	m objectAt: d1 class: (m newSmallInteger: 30).
	m objectAt: d1 string: 'abcde'.
	d2 := a gcAlloc: 1.
	m objectAt: d2 class: (m newSmallInteger: 10).
	m objectAt: d2 dataAt: 0 put: d1.
	self assert: (a isInCurrentSpace: d2).
	gc toggleSpace.
	r1 := gc move: (m newSmallInteger: 5).
	self assert: (m smallIntegerValue: r1) equals: 5.
	r1 := gc move: (m newSmallInteger: 15).
	self assert: (m smallIntegerValue: r1) equals: 15.
	r1 := gc move: d1.
	self assert: (a isInCurrentSpace: r1).
	self assert: (m classOfObjectAt: r1) equals: (m newSmallInteger: 30).
	self assert: (m stringOfObjectAt: r1) equals: 'abcde'.
	r2 := gc move: d2.
	self assert: (a isInCurrentSpace: r2).
	self assert: (m classOfObjectAt: r2) equals: (m newSmallInteger: 10).
	self assert: (m objectAt: r2 dataAt: 0) equals: r1.
	t := a availableMemory.
	self assert: (gc move: d1) equals: r1.
	self assert: (gc move: d2) equals: r2.
	self assert: a availableMemory equals: t
]

{ #category : #test }
LCopyingGCTest >> testOldBase [
	| a |
	a := self newGC.
	self assert: a oldBase isNil.
	a oldBase: 123.
	self assert: a oldBase equals: 123
]

{ #category : #test }
LCopyingGCTest >> testOldEnd [
	| a |
	a := self newGC.
	self assert: a oldEnd isNil.
	a oldEnd: 123.
	self assert: a oldEnd equals: 123
]

{ #category : #test }
LCopyingGCTest >> testSetupSpaces [
	| gc a |
	a := self newAllocator.
	a allocate: 1000.
	a dynamicStart: 101.
	gc := self newGC.
	gc allocator: a.
	gc setupSpaces.
	self assert: gc spaceOne equals: 101.
	self assert: gc spaceSize equals: 448.
	self assert: gc spaceTwo equals: 549.
	self assert: a memoryBase equals: 101.
	self assert: a memoryEnd equals: 548.
	a := self newAllocator.
	a allocate: 1000.
	a dynamicStart: 109.
	gc allocator: a.
	gc setupSpaces.
	self assert: gc spaceOne equals: 109.
	self assert: gc spaceSize equals: 444.
	self assert: gc spaceTwo equals: 553.
	self assert: a memoryBase equals: 109.
	self assert: a memoryEnd equals: 552
]

{ #category : #test }
LCopyingGCTest >> testSpaceOne [
	| a |
	a := self newGC.
	self assert: a spaceOne isNil.
	a spaceOne: 123.
	self assert: a spaceOne equals: 123
]

{ #category : #test }
LCopyingGCTest >> testSpaceSize [
	| a |
	a := self newGC.
	self assert: a spaceSize isNil.
	a spaceSize: 123.
	self assert: a spaceSize equals: 123
]

{ #category : #test }
LCopyingGCTest >> testSpaceTwo [
	| a |
	a := self newGC.
	self assert: a spaceTwo isNil.
	a spaceTwo: 123.
	self assert: a spaceTwo equals: 123
]

{ #category : #test }
LCopyingGCTest >> testToggleSpace [
	| a gc |
	a := self newAllocator.
	a allocate: 1000.
	a dynamicStart: 101.
	gc := self newGC.
	gc allocator: a.
	gc setupSpaces.
	self assert: a memoryBase equals: 101.
	self assert: a memoryEnd equals: 548.
	gc toggleSpace.
	self assert: a memoryBase equals: 549.
	self assert: a memoryEnd equals: 996.
	gc toggleSpace.
	self assert: a memoryBase equals: 101.
	self assert: a memoryEnd equals: 548.
	gc toggleSpace.
	self assert: a memoryBase equals: 549.
	self assert: a memoryEnd equals: 996
]
