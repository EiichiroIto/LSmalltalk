"
A LMemoryAllocatorTest is a test class for testing the behavior of LMemoryAllocator
"
Class {
	#name : #LMemoryAllocatorTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LMemoryAllocatorTest >> newMemory [
	^ LObjectMemory new
]

{ #category : #test }
LMemoryAllocatorTest >> testAllocateMemory [
	| a m |
	m := self newMemory.
	self assert: m core isNil.
	a := LBuildingAllocator new.
	a memory: m.
	a allocateMemory: 1024.
	self assert: m core size equals: 1024
]

{ #category : #test }
LMemoryAllocatorTest >> testBinaryAlloc [
	| a m addr |
	m := self newMemory.
	a := LBuildingAllocator new.
	a memory: m.
	a allocateMemory: 1024.
	addr := a binaryAlloc: 3.
	self assert: addr equals: 0.
	self assert: (m core at: 1) equals: (3 << 2 bitOr: 2).
	addr := a binaryAlloc: 4.
	self assert: addr equals: 16.
	self assert: (m core at: 17) equals: (4 << 2 bitOr: 2)
]

{ #category : #test }
LMemoryAllocatorTest >> testMemory [
	| a m |
	a := LBuildingAllocator new.
	self assert: a memory isNil.
	m := self newMemory.
	a memory: m.
	self assert: a memory identicalTo: m
]
