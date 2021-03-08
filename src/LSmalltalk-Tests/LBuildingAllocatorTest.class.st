"
A LBuildingAllocatorTest is a test class for testing the behavior of LBuildingAllocator
"
Class {
	#name : #LBuildingAllocatorTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LBuildingAllocatorTest >> newAllocator [
	^ LBuildingAllocator new
]

{ #category : #private }
LBuildingAllocatorTest >> newMemory [
	^ LObjectMemory new
]

{ #category : #test }
LBuildingAllocatorTest >> testDictionaryInsertAtPut [
	| m dict keys vals k1 k2 k3 k4 a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocateMemory: 1024.
	dict := a gcAlloc: 2.
	m objectAt: dict class: 91.
	keys := a gcAlloc: 0.
	m objectAt: keys class: 92.
	vals := a gcAlloc: 0.
	m objectAt: vals class: 93.
	m objectAt: dict dataAt: 0 put: keys.
	m objectAt: dict dataAt: 1 put: vals.
	k1 := a binaryAlloc: 3.
	m objectAt: k1 string: 'abc'.
	k2 := a binaryAlloc: 3.
	m objectAt: k2 string: 'def'.
	k3 := a binaryAlloc: 4.
	m objectAt: k3 string: 'abcd'.
	k4 := a binaryAlloc: 3.
	m objectAt: k4 string: 'def'.
	a dictionary: dict insertAt: k1 put: 11.
	a dictionary: dict insertAt: k2 put: 12.
	a dictionary: dict insertAt: k3 put: 13.
	keys := m objectAt: dict dataAt: 0.
	vals := m objectAt: dict dataAt: 1.
	self assert: (m classOfObjectAt: keys) equals: 92.
	self assert: (m classOfObjectAt: vals) equals: 93.
	self assert: (m sizeOfObjectAt: keys) equals: 3.
	self assert: (m sizeOfObjectAt: vals) equals: 3.
	self assert: (m objectAt: keys dataAt: 0) equals: k1.
	self assert: (m objectAt: keys dataAt: 1) equals: k3.
	self assert: (m objectAt: keys dataAt: 2) equals: k2.
	self assert: (m objectAt: vals dataAt: 0) equals: 11.
	self assert: (m objectAt: vals dataAt: 1) equals: 13.
	self assert: (m objectAt: vals dataAt: 2) equals: 12.
	self should: [ m dictionary: dict insertAt: k4 put: 99 ] raise: Error
]

{ #category : #test }
LBuildingAllocatorTest >> testFree [
	| m a |
	m := self newMemory.
	a := self newAllocator
		memory: m;
		yourself.
	self assert: a free equals: 1.
	a free: 123.
	self assert: a free equals: 123
]

{ #category : #test }
LBuildingAllocatorTest >> testGcAlloc [
	| m addr a |
	m := self newMemory.
	a := self newAllocator
		memory: m;
		yourself.
	a allocateMemory: 1024.
	self assert: a free equals: 1.
	addr := a gcAlloc: 5.
	self assert: addr equals: 0.
	self assert: (m core at: 1) equals: 5 << 2.
	self assert: a free equals: 1 + m objectSize + (5 * m pointerSize).
	addr := a gcAlloc: 3.
	self assert: addr equals: 32.
	self assert: (m core at: 33) equals: 3 << 2.
	self assert: a free equals: 33 + m objectSize + (3 * m pointerSize)
]

{ #category : #test }
LBuildingAllocatorTest >> testInsertedArrayAtPut [
	| m b r a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocateMemory: 1024.
	b := a gcAlloc: 4.
	m objectAt: b dataAt: 0 put: 9.
	m objectAt: b dataAt: 1 put: 8.
	m objectAt: b dataAt: 2 put: 7.
	m objectAt: b dataAt: 3 put: 6.
	r := a insertedArray: b at: 2 put: 3.
	self assert: (m objectAt: r dataAt: 0) equals: 9.
	self assert: (m objectAt: r dataAt: 1) equals: 8.
	self assert: (m objectAt: r dataAt: 2) equals: 3.
	self assert: (m objectAt: r dataAt: 3) equals: 7.
	self assert: (m objectAt: r dataAt: 4) equals: 6.
	self assert: (m sizeOfObjectAt: r) equals: 5
]

{ #category : #test }
LBuildingAllocatorTest >> testNewByteArray [
	| m a b |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocateMemory: 1024.
	b := a newByteArray: #[33 44 55 66 77].
	self
		assertCollection: (m byteArrayOfObjectAt: b)
		equals: #[33 44 55 66 77]
]

{ #category : #test }
LBuildingAllocatorTest >> testNewClassAdding [
	| m a b |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocateMemory: 1024.
	b := a newClass: 1 adding: 2.
	self assert: (m nameOfClassAt: b) equals: 1.
	self assert: (m sizeOfObjectAt: b) equals: m classSize + 2
]

{ #category : #test }
LBuildingAllocatorTest >> testNewString [
	| m s1 s2 a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocateMemory: 1024.
	s1 := a newString: 'abc'.
	s2 := a newString: 'defg'.
	self assert: (m stringOfObjectAt: s1) equals: 'abc'.
	self assert: (m stringOfObjectAt: s2) equals: 'defg'
]
