"
A LObjectMemoryTest is a test class for testing the behavior of LObjectMemory
"
Class {
	#name : #LObjectMemoryTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LObjectMemoryTest >> newAllocator [
	^ LBuildingAllocator new
]

{ #category : #private }
LObjectMemoryTest >> newMemory [
	^ LObjectMemory new
]

{ #category : #test }
LObjectMemoryTest >> testAddressOfObjectAtDataAt [
	| m a r |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	r := a gcAlloc: 10.
	self assert: (m addressOfObjectAt: r dataAt: 0) equals: r + 8.
	self assert: (m addressOfObjectAt: r dataAt: 1) equals: r + 12.
	self assert: (m addressOfObjectAt: r dataAt: 2) equals: r + 16.
	r := a gcAlloc: 20.
	self assert: (m addressOfObjectAt: r dataAt: 0) equals: r + 8.
	r := a gcAlloc: 5.
	self assert: (m addressOfObjectAt: r dataAt: 0) equals: r + 8
]

{ #category : #test }
LObjectMemoryTest >> testBCopyFromToCount [
	| m |
	m := self newMemory.
	m core: #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15] copy.
	m bCopyFrom: 4 to: 10 count: 3.
	self
		assertCollection: m core
		equals: #[1 2 3 4 5 6 7 8 9 10 5 6 7 14 15].
	m := self newMemory.
	m core: #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15] copy.
	m bCopyFrom: 9 to: 0 count: 4.
	self
		assertCollection: m core
		equals: #[10 11 12 13 5 6 7 8 9 10 11 12 13 14 15]
]

{ #category : #test }
LObjectMemoryTest >> testBinaryMask [
	| m |
	m := self newMemory.
	self assert: m binaryMask equals: 2
]

{ #category : #test }
LObjectMemoryTest >> testByteAddressOfObjectAt [
	| m a r |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	r := a binaryAlloc: 10.
	self assert: (m byteAddressOfObjectAt: r) equals: r + 8.
	r := a binaryAlloc: 20.
	self assert: (m byteAddressOfObjectAt: r) equals: r + 8.
	r := a binaryAlloc: 5.
	self assert: (m byteAddressOfObjectAt: r) equals: r + 8
]

{ #category : #test }
LObjectMemoryTest >> testByteArrayOfObjectAt [
	| m addr arr a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	arr := #[99 98 97 96].
	addr := a binaryAlloc: arr size.
	m objectAt: addr byteArray: arr.
	self assertCollection: (m byteArrayOfObjectAt: addr) equals: arr
]

{ #category : #test }
LObjectMemoryTest >> testByteAt [
	| m |
	m := self newMemory.
	m core: #[10 20 30 40 50].
	self assert: (m byteAt: 0) equals: 10.
	self assert: (m byteAt: 1) equals: 20.
	self assert: (m byteAt: 2) equals: 30
]

{ #category : #test }
LObjectMemoryTest >> testBytesPerWord [
	| m |
	m := self newMemory.
	self assert: m bytesPerWord equals: 4
]

{ #category : #test }
LObjectMemoryTest >> testClassAtInstanceSize [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl instanceSize: 5.
	self
		assert: (m objectAt: cl dataAt: m instanceSizeInClass)
		equals: (5 << 1) + m smallIntegerMask
]

{ #category : #test }
LObjectMemoryTest >> testClassAtMethods [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl methods: 5.
	self assert: (m methodsOfClassAt: cl) equals: 5
]

{ #category : #test }
LObjectMemoryTest >> testClassAtName [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl name: 5.
	self assert: (m objectAt: cl dataAt: m nameInClass) equals: 5
]

{ #category : #test }
LObjectMemoryTest >> testClassAtParentClass [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl parentClass: 5.
	self assert: (m parentClassOfClassAt: cl) equals: 5
]

{ #category : #test }
LObjectMemoryTest >> testClassAtVariables [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl variables: 5.
	self assert: (m variablesOfClassAt: cl) equals: 5
]

{ #category : #test }
LObjectMemoryTest >> testClassOfObjectAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 123 class: 34567.
	self assert: (m classOfObjectAt: 123) equals: 34567
]

{ #category : #test }
LObjectMemoryTest >> testClassSize [
	| m |
	m := self newMemory.
	self assert: m classSize equals: 5
]

{ #category : #test }
LObjectMemoryTest >> testClearObjectAt [
	| m a r |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	r := a gcAlloc: 10.
	0 to: 10 do: [ :each | m objectAt: r dataAt: each put: 10 atRandom + 1 ].
	0 to: 10 do: [ :each | self assert: (m objectAt: r dataAt: each) ~= 0 ].
	m clearObjectAt: r.
	0 to: 9 do: [ :each | self assert: (m objectAt: r dataAt: each) equals: 0 ].
	self assert: (m objectAt: r dataAt: 10) ~= 0
]

{ #category : #test }
LObjectMemoryTest >> testCompareStringWith [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 10 string: 'abc'.
	m objectAt: 10 size: 3.
	m objectAt: 30 string: 'def'.
	m objectAt: 30 size: 3.
	m objectAt: 50 string: 'abc'.
	m objectAt: 50 size: 3.
	m objectAt: 70 string: 'abcd'.
	m objectAt: 70 size: 4.
	self assert: (m compareString: 10 with: 10) equals: 0.
	self assert: (m compareString: 30 with: 30) equals: 0.
	self assert: (m compareString: 50 with: 50) equals: 0.
	self assert: (m compareString: 70 with: 70) equals: 0.
	self assert: (m compareString: 10 with: 50) equals: 0.
	self assert: (m compareString: 10 with: 30) equals: -1.
	self assert: (m compareString: 30 with: 10) equals: 1.
	self assert: (m compareString: 50 with: 70) equals: -1.
	self assert: (m compareString: 70 with: 50) equals: 1
]

{ #category : #test }
LObjectMemoryTest >> testCopyBinaryDataObjectAtTo [
	| m a d1 d2 |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 100.
	d1 := a binaryAlloc: 5.
	m objectAt: d1 string: 'abcde'.
	d2 := a binaryAlloc: 5.
	m copyBinaryDataObjectAt: d1 to: d2.
	self assert: (m stringOfObjectAt: d1) equals: 'abcde'.
	self assert: (m stringOfObjectAt: d2) equals: 'abcde'
]

{ #category : #test }
LObjectMemoryTest >> testCopyDataObjectAtTo [
	| m a d1 d2 |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 100.
	d1 := a gcAlloc: 3.
	m objectAt: d1 dataAt: 0 put: 10.
	m objectAt: d1 dataAt: 1 put: 20.
	m objectAt: d1 dataAt: 2 put: 30.
	d2 := a gcAlloc: 3.
	m copyDataObjectAt: d1 to: d2.
	self assert: (m objectAt: d1 dataAt: 0) equals: 10.
	self assert: (m objectAt: d1 dataAt: 1) equals: 20.
	self assert: (m objectAt: d1 dataAt: 2) equals: 30.
	self assert: (m objectAt: d2 dataAt: 0) equals: 10.
	self assert: (m objectAt: d2 dataAt: 1) equals: 20.
	self assert: (m objectAt: d2 dataAt: 2) equals: 30
]

{ #category : #test }
LObjectMemoryTest >> testCore [
	| m a |
	m := self newMemory.
	self assert: m core isNil.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	self assert: (m core isKindOf: ByteArray).
	self assert: m core notEmpty
]

{ #category : #test }
LObjectMemoryTest >> testCoreAtBitOr [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m coreAt: 1 uint8: 5.
	m coreAt: 4 uint8: 10.
	self assert: (m core byteAt: 1) equals: 5.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 10.
	self assert: (m core byteAt: 5) equals: 0.
	m coreAt: 1 bitOr: 8.
	m coreAt: 4 bitOr: 9.
	self assert: (m core byteAt: 1) equals: 13.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 11.
	self assert: (m core byteAt: 5) equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testCoreAtUint32 [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m coreAt: 1 uint32: 258.
	self assert: (m core byteAt: 1) equals: 2.
	self assert: (m core byteAt: 2) equals: 1.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 0.
	self should: [ m coreAt: 0 uint32: 1 ] raise: Error
]

{ #category : #test }
LObjectMemoryTest >> testCoreAtUint8 [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m coreAt: 1 uint8: 258.
	m coreAt: 4 uint8: 10.
	self assert: (m core byteAt: 1) equals: 2.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 10.
	self assert: (m core byteAt: 5) equals: 0.
	self should: [ m coreAt: 0 uint8: 1 ] raise: Error
]

{ #category : #test }
LObjectMemoryTest >> testCoreSize [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 10.
	self assert: m coreSize equals: 10.
	a allocate: 20.
	self assert: m coreSize equals: 20
]

{ #category : #test }
LObjectMemoryTest >> testDefaultCoreSize [
	| m |
	m := self newMemory.
	self assert: m defaultCoreSize equals: 2048
]

{ #category : #test }
LObjectMemoryTest >> testFitsSmallInteger [
	| m |
	m := self newMemory.
	self assert: (m fitsSmallInteger: 0).
	self assert: (m fitsSmallInteger: -16r40000000).
	self assert: (m fitsSmallInteger: 16r3FFFFFFF).
	self deny: (m fitsSmallInteger: -16r40000001).
	self deny: (m fitsSmallInteger: 16r40000000)
]

{ #category : #test }
LObjectMemoryTest >> testGcDoneAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1000.
	self deny: (m gcDoneAt: 0).
	m markGcDoneObjectAt: 0.
	self assert: (m gcDoneAt: 0)
]

{ #category : #test }
LObjectMemoryTest >> testGcDoneMask [
	| m |
	m := self newMemory.
	self assert: m gcDoneMask equals: 1
]

{ #category : #test }
LObjectMemoryTest >> testInitialAllocate [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	self assert: m core size equals: 1024.
	m initialAllocate: 500.
	self assert: m core size equals: 500
]

{ #category : #test }
LObjectMemoryTest >> testInstanceSizeInClass [
	| m |
	m := self newMemory.
	self assert: m instanceSizeInClass equals: 3
]

{ #category : #test }
LObjectMemoryTest >> testInstanceSizeOfClassAt [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	m classAt: cl instanceSize: 11.
	self assert: (m instanceSizeOfClassAt: cl) equals: 11
]

{ #category : #test }
LObjectMemoryTest >> testIsBinaryAt [
	| m e b c d a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	e := a gcAlloc: 5.
	b := a binaryAlloc: 10.
	c := a binaryAlloc: 20.
	d := a gcAlloc: 30.
	self deny: (m isBinaryAt: e).
	self assert: (m isBinaryAt: b).
	self assert: (m isBinaryAt: c).
	self deny: (m isBinaryAt: d)
]

{ #category : #test }
LObjectMemoryTest >> testIsSmallInteger [
	| m v a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 2048.
	100
		timesRepeat: [ v := m newSmallInteger: (-10000 to: 10000) atRandom.
			self assert: (m isSmallInteger: v) ].
	50
		timesRepeat: [ v := a gcAlloc: 10 atRandom.
			self deny: (m isSmallInteger: v) ]
]

{ #category : #test }
LObjectMemoryTest >> testMarkBinaryObjectAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m markBinaryObjectAt: 10.
	self assert: (m isBinaryAt: 10).
	self deny: (m isBinaryAt: 20)
]

{ #category : #test }
LObjectMemoryTest >> testMarkGcDoneObjectAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 100.
	m coreAt: 11 uint8: 20.
	self assert: (m uint8CoreAt: 10) equals: 0.
	m markGcDoneObjectAt: 9.
	m markGcDoneObjectAt: 10.
	self assert: (m uint8CoreAt: 10) equals: 1.
	self assert: (m uint8CoreAt: 11) equals: 21
]

{ #category : #test }
LObjectMemoryTest >> testMethodsInClass [
	| m |
	m := self newMemory.
	self assert: m methodsInClass equals: 2
]

{ #category : #test }
LObjectMemoryTest >> testMethodsOfClassAt [
	self testClassAtMethods
]

{ #category : #test }
LObjectMemoryTest >> testNameInClass [
	| m |
	m := self newMemory.
	self assert: m nameInClass equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testNameOfClassAt [
	| m s cl a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	s := a newString: 'abc'.
	cl := a newClass: s adding: 0.
	self assert: (m nameOfClassAt: cl) equals: s
]

{ #category : #test }
LObjectMemoryTest >> testNewSmallInteger [
	| m |
	m := self newMemory.
	self assert: (m newSmallInteger: 10) equals: 21.
	self assert: (m newSmallInteger: -16r40000000) equals: 16r80000001.
	self assert: (m newSmallInteger: 16r3FFFFFFF) equals: 16r7FFFFFFF.
	self should: [ m newSmallInteger: 16r40000000 ] raise: Error
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtByteArray [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 byteArray: #[99 98 97 96].
	self assert: (m core byteAt: 1) equals: 0.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 0.
	self assert: (m core byteAt: 6) equals: 0.
	self assert: (m core byteAt: 7) equals: 0.
	self assert: (m core byteAt: 8) equals: 0.
	self assert: (m core byteAt: 9) equals: 99.
	self assert: (m core byteAt: 10) equals: 98.
	self assert: (m core byteAt: 11) equals: 97.
	self assert: (m core byteAt: 12) equals: 96
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtByteAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 byteAt: 1 put: 10.
	m objectAt: 0 byteAt: 2 put: 20.
	m objectAt: 0 byteAt: 3 put: 30.
	self assert: (m objectAt: 0 byteAt: 1) equals: 10.
	self assert: (m objectAt: 0 byteAt: 2) equals: 20.
	self assert: (m objectAt: 0 byteAt: 3) equals: 30
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtByteAtPut [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 byteAt: 0 put: 10.
	m objectAt: 0 byteAt: 1 put: 20.
	m objectAt: 0 byteAt: 2 put: 30.
	self assert: (m uint8CoreAt: 1) equals: 0.
	self assert: (m uint8CoreAt: 2) equals: 0.
	self assert: (m uint8CoreAt: 3) equals: 0.
	self assert: (m uint8CoreAt: 4) equals: 0.
	self assert: (m uint8CoreAt: 5) equals: 0.
	self assert: (m uint8CoreAt: 6) equals: 0.
	self assert: (m uint8CoreAt: 7) equals: 0.
	self assert: (m uint8CoreAt: 8) equals: 0.
	self assert: (m uint8CoreAt: 9) equals: 10.
	self assert: (m uint8CoreAt: 10) equals: 20.
	self assert: (m uint8CoreAt: 11) equals: 30.
	self assert: (m uint8CoreAt: 12) equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtClass [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 class: 258.
	self assert: (m core byteAt: 1) equals: 0.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 2.
	self assert: (m core byteAt: 6) equals: 1.
	self assert: (m core byteAt: 7) equals: 0.
	self assert: (m core byteAt: 8) equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtDataAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 10 dataAt: 0 put: 258.
	m objectAt: 30 dataAt: 1 put: 12345.
	self assert: (m objectAt: 10 dataAt: 0) equals: 258.
	self assert: (m objectAt: 30 dataAt: 1) equals: 12345
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtDataAtPut [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 dataAt: 0 put: 258.
	m objectAt: 0 dataAt: 1 put: 261+256.
	self assert: (m core byteAt: 1) equals: 0.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 0.
	self assert: (m core byteAt: 6) equals: 0.
	self assert: (m core byteAt: 7) equals: 0.
	self assert: (m core byteAt: 8) equals: 0.
	self assert: (m core byteAt: 9) equals: 2.
	self assert: (m core byteAt: 10) equals: 1.
	self assert: (m core byteAt: 11) equals: 0.
	self assert: (m core byteAt: 12) equals: 0.
	self assert: (m core byteAt: 13) equals: 5.
	self assert: (m core byteAt: 14) equals: 2.
	self assert: (m core byteAt: 15) equals: 0.
	self assert: (m core byteAt: 16) equals: 0.
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtRawDataAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 100.
	m objectAt: 0 class: 10.
	m objectAt: 0 dataAt: 0 put: 20.
	m objectAt: 0 dataAt: 1 put: 30.
	self assert: (m objectAt: 0 rawDataAt: 0) equals: 10.
	self assert: (m objectAt: 0 rawDataAt: 1) equals: 20.
	self assert: (m objectAt: 0 rawDataAt: 2) equals: 30
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtRawDataAtPut [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 100.
	m objectAt: 0 rawDataAt: 0 put: 10.
	m objectAt: 0 rawDataAt: 1 put: 20.
	m objectAt: 0 rawDataAt: 2 put: 30.
	self assert: (m classOfObjectAt: 0) equals: 10.
	self assert: (m objectAt: 0 dataAt: 0) equals: 20.
	self assert: (m objectAt: 0 dataAt: 1) equals: 30
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtSize [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 4 size: 65.
	self assert: (m core byteAt: 1) equals: 0.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 4.
	self assert: (m core byteAt: 6) equals: 1.
	self assert: (m core byteAt: 7) equals: 0.
	self assert: (m core byteAt: 8) equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testObjectAtString [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 0 string: 'abc'.
	self assert: (m core byteAt: 1) equals: 0.
	self assert: (m core byteAt: 2) equals: 0.
	self assert: (m core byteAt: 3) equals: 0.
	self assert: (m core byteAt: 4) equals: 0.
	self assert: (m core byteAt: 5) equals: 0.
	self assert: (m core byteAt: 6) equals: 0.
	self assert: (m core byteAt: 7) equals: 0.
	self assert: (m core byteAt: 8) equals: 0.
	self assert: (m core byteAt: 9) equals: $a asciiValue.
	self assert: (m core byteAt: 10) equals: $b asciiValue.
	self assert: (m core byteAt: 11) equals: $c asciiValue.
	self assert: (m core byteAt: 12) equals: 0
]

{ #category : #test }
LObjectMemoryTest >> testObjectSize [
	| m |
	m := self newMemory.
	self assert: m objectSize equals: 12
]

{ #category : #test }
LObjectMemoryTest >> testObjectSizeOf [
	| m |
	m := self newMemory.
	self assert: (m objectSizeOf: 0) equals: 8.
	self assert: (m objectSizeOf: 1) equals: 12.
	self assert: (m objectSizeOf: 2) equals: 16.
	self assert: (m objectSizeOf: 3) equals: 20
]

{ #category : #test }
LObjectMemoryTest >> testParentClassInClass [
	| m |
	m := self newMemory.
	self assert: m parentClassInClass equals: 1
]

{ #category : #test }
LObjectMemoryTest >> testParentClassOfClassAt [
	self testClassAtParentClass
]

{ #category : #test }
LObjectMemoryTest >> testPointerSize [
	| m |
	m := self newMemory.
	self assert: m pointerSize equals: 4
]

{ #category : #test }
LObjectMemoryTest >> testRawAddressOfObjectAtDataAt [
	| m |
	m := self newMemory.
	self assert: (m rawAddressOfObjectAt: 0 dataAt: 0) equals: 4.
	self assert: (m rawAddressOfObjectAt: 0 dataAt: 1) equals: 8.
	self assert: (m rawAddressOfObjectAt: 0 dataAt: 2) equals: 12.
	self assert: (m rawAddressOfObjectAt: 10 dataAt: 0) equals: 14
]

{ #category : #test }
LObjectMemoryTest >> testSizeOfObjectAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m objectAt: 123 size: 34567.
	self assert: (m sizeOfObjectAt: 123) equals: 34567
]

{ #category : #test }
LObjectMemoryTest >> testSmallIntegerMask [
	| m |
	m := self newMemory.
	self assert: m smallIntegerMask equals: 1
]

{ #category : #test }
LObjectMemoryTest >> testSmallIntegerValue [
	| m a v |
	m := self newMemory.
	100
		timesRepeat: [ a := (-10000 to: 10000) atRandom.
			v := m newSmallInteger: a.
			self assert: (m smallIntegerValue: v) equals: a ].
	self assert: (m smallIntegerValue: 16rFFFFFFFF) equals: -1.
	self assert: (m smallIntegerValue: 1) equals: 0.
	self should: [ m smallIntegerValue: 16r100000000 ] raise: Error.
	self should: [ m smallIntegerValue: -1 ] raise: Error
]

{ #category : #test }
LObjectMemoryTest >> testStringOfObjectAt [
	| m addr str a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	str := 'abcdefghi'.
	addr := a binaryAlloc: str size.
	m objectAt: addr string: str.
	self assert: (m stringOfObjectAt: addr) equals: str
]

{ #category : #test }
LObjectMemoryTest >> testStringPositionOfObjectAt [
	| m |
	m := self newMemory.
	self assert: (m stringPositionOfObjectAt: 1) equals: 10.
	self assert: (m stringPositionOfObjectAt: 10) equals: 19
]

{ #category : #test }
LObjectMemoryTest >> testTrueSizeOf [
	| m |
	m := self newMemory.
	self assert: (m trueSizeOf: 0) equals: 0.
	self assert: (m trueSizeOf: 1) equals: 1.
	self assert: (m trueSizeOf: 2) equals: 1.
	self assert: (m trueSizeOf: 3) equals: 1.
	self assert: (m trueSizeOf: 4) equals: 1.
	self assert: (m trueSizeOf: 5) equals: 2.
	self assert: (m trueSizeOf: 6) equals: 2.
	self assert: (m trueSizeOf: 7) equals: 2.
	self assert: (m trueSizeOf: 8) equals: 2
]

{ #category : #test }
LObjectMemoryTest >> testUint32CoreAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m core byteAt: 1 put: 2.
	m core byteAt: 2 put: 1.
	m coreAt: 1 uint32: 258.
	self assert: (m uint32CoreAt: 1) equals: 258.
	self should: [ m uint32CoreAt: 0 ] raise: Error.
	self assert: (m uint32CoreAt: 100) equals: 0.
	m core byteAt: 100 put: 16rFF.
	m core byteAt: 101 put: 16rFF.
	m core byteAt: 102 put: 16rFF.
	m core byteAt: 103 put: 16rFF.
	self assert: (m uint32CoreAt: 100) equals: 16rFFFFFFFF
]

{ #category : #test }
LObjectMemoryTest >> testUint8CoreAt [
	| m a |
	m := self newMemory.
	a := self newAllocator.
	a memory: m.
	a allocate: 1024.
	m coreAt: 10 uint8: 50.
	m coreAt: 11 uint8: 10.
	self assert: (m uint8CoreAt: 10) equals: 50.
	self assert: (m uint8CoreAt: 11) equals: 10.
	self should: [ m uint8CoreAt: 0 ] raise: Error
]

{ #category : #test }
LObjectMemoryTest >> testVariablesInClass [
	| m |
	m := self newMemory.
	self assert: m variablesInClass equals: 4
]

{ #category : #test }
LObjectMemoryTest >> testVariablesOfClassAt [
	self testClassAtVariables
]
