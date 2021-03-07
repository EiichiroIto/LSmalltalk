"
A LDynamicAllocatorTest is a test class for testing the behavior of LDynamicAllocator
"
Class {
	#name : #LDynamicAllocatorTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LDynamicAllocatorTest >> newAllocator [
	^ LDynamicAllocator new
		memory: LObjectMemory new;
		yourself
]

{ #category : #test }
LDynamicAllocatorTest >> testDynamicStart [
	| a |
	a := self newAllocator.
	self assert: a dynamicStart isNil.
	self assert: a memoryBase isNil.
	self assert: a memoryPointer isNil.
	a dynamicStart: 123.
	self assert: a dynamicStart equals: 123.
	self assert: a memoryBase equals: 123.
	self assert: a memoryPointer equals: 123
]

{ #category : #test }
LDynamicAllocatorTest >> testGc [
	| a gc |
	a := self newAllocator.
	self assert: a gc isNil.
	gc := LCopyingGC new.
	a gc: gc.
	self assert: a gc identicalTo: gc
]

{ #category : #test }
LDynamicAllocatorTest >> testIsDynamicMemory [
	| a |
	a := self newAllocator.
	a dynamicStart: 101.
	self assert: (a isDynamicMemory: 100).
	self assert: (a isDynamicMemory: 200).
	self deny: (a isDynamicMemory: 99)
]

{ #category : #test }
LDynamicAllocatorTest >> testIsInCurrentSpace [
	| a m |
	a := self newAllocator.
	m := a memory.
	a allocate: 10.
	a memoryBase: 1.
	self assert: (a isInCurrentSpace: 0).
	self assert: (a isInCurrentSpace: 9).
	self deny: (a isInCurrentSpace: 10)
]

{ #category : #test }
LDynamicAllocatorTest >> testMemoryBase [
	| a |
	a := self newAllocator.
	self assert: a memoryBase isNil.
	a memoryBase: 123.
	self assert: a memoryBase equals: 123
]

{ #category : #test }
LDynamicAllocatorTest >> testMemoryEnd [
	| a |
	a := self newAllocator.
	a allocate: 1000.
	self assert: a memoryEnd equals: 1000.
	a memoryEnd: 123.
	self assert: a memoryEnd equals: 123
]

{ #category : #test }
LDynamicAllocatorTest >> testMemoryPointer [
	| a |
	a := self newAllocator.
	self assert: a memoryPointer isNil.
	a memoryPointer: 123.
	self assert: a memoryPointer equals: 123
]

{ #category : #test }
LDynamicAllocatorTest >> testPopRoot [
	| a |
	a := self newAllocator.
	a rootStack: #(123 456 789) asOrderedCollection.
	self assert: a popRoot equals: 789.
	self assert: a popRoot equals: 456.
	self assert: a popRoot equals: 123.
	a := self newAllocator.
	a pushRoot: 1.
	a pushRoot: 2.
	a pushRoot: 3.
	self assert: a popRoot equals: 3.
	self assert: a popRoot equals: 2.
	self assert: a popRoot equals: 1
]

{ #category : #test }
LDynamicAllocatorTest >> testPushRoot [
	| a |
	a := self newAllocator.
	a pushRoot: 123.
	a pushRoot: 456.
	self assertCollection: a rootStack asArray equals: #(123 456)
]

{ #category : #test }
LDynamicAllocatorTest >> testRootStack [
	| a |
	a := self newAllocator.
	self assert: a rootStack isCollection.
	self assert: a rootStack isEmpty.
	a rootStack: #(1 2 3).
	self assertCollection: a rootStack equals: #(1 2 3)
]

{ #category : #test }
LDynamicAllocatorTest >> testStaticRoots [
	| a |
	a := self newAllocator.
	self assert: a staticRoots isCollection.
	self assert: a staticRoots isEmpty.
	a staticRoots: #(1 2 3).
	self assertCollection: a staticRoots equals: #(1 2 3)
]

{ #category : #test }
LDynamicAllocatorTest >> testThirdOfRoot [
	| a |
	a := self newAllocator.
	a pushRoot: 1.
	a pushRoot: 2.
	a pushRoot: 3.
	self assert: a thirdOfRoot equals: 1
]

{ #category : #test }
LDynamicAllocatorTest >> testWhenCompleted [
	| a |
	a := self newAllocator.
	a gc: LGarbageCollector new.
	self assert: a whenCompleted isNil.
	a whenCompleted: [ 1 + 2 ].
	self assert: a whenCompleted isBlock
]
