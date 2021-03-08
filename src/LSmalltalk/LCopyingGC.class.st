Class {
	#name : #LCopyingGC,
	#superclass : #LGarbageCollector,
	#instVars : [
		'oldBase',
		'oldEnd',
		'spaceOne',
		'spaceTwo',
		'spaceSize',
		'oldAddress',
		'replacement',
		'previousObject'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #'debug support' }
LCopyingGC >> checkMemory [
	| r |
	r := allocator
		currentObjectsDo: [ :addr | 
			self checkValidObject: addr ].
	r + 1 = allocator memoryPointer
		ifFalse: [ self error ].
	"r := allocator
		staticObjectsDo: [ :addr | 
			(self isValidObject: addr)
				ifFalse: [ self error ] ]"
]

{ #category : #'debug support' }
LCopyingGC >> checkRoots [
	| checked unchecked addr sz |
	checked := Set new.
	unchecked := allocator staticRoots copy.
	[ unchecked notEmpty ]
		whileTrue: [ addr := unchecked removeFirst.
			((checked includes: addr)
				or: [ addr = 0 or: [ self memory isSmallInteger: addr ] ])
				ifFalse: [ ((self allocator isDynamicMemory: addr) not
						or: [ self allocator isInCurrentSpace: addr ])
						ifFalse: [ self error ].
					checked add: addr.
					unchecked add: (self memory classOfObjectAt: addr).
					(self memory isBinaryAt: addr)
						ifFalse: [ sz := self memory sizeOfObjectAt: addr.
							0 to: sz - 1 do: [ :each | unchecked add: (self memory objectAt: addr dataAt: each) ] ] ] ]
]

{ #category : #'debug support' }
LCopyingGC >> checkValidObject: anInteger [
	| cl size obj |
	anInteger = 16rFFFFFFFF
		ifTrue: [ ^ self error ].
	(self memory isSmallInteger: anInteger)
		ifTrue: [ ^ self ].
	cl := self memory classOfObjectAt: anInteger.
	(self isValidAddress: cl)
		ifFalse: [ ^ self error ].
	(self memory isBinaryAt: anInteger)
		ifTrue: [ ^ self ].
	size := self memory sizeOfObjectAt: anInteger.
	0 to: size - 1 do: [ :each | 
		obj := self memory objectAt: anInteger dataAt: each.
		obj = 16rFFFFFFFF
			ifTrue: [ ^ self error ].
		((self memory isSmallInteger: obj) or: [ self isValidAddress: obj ])
			ifFalse: [ ^ self error ] ].
	^ self
]

{ #category : #'debug support' }
LCopyingGC >> clearOldSpace [
	oldBase to: oldEnd do: [ :each | self memory coreAt: each uint8: 255 ]
]

{ #category : #api }
LCopyingGC >> garbageCollect: anInteger [
	gcCount := gcCount + 1.
	self toggleSpace.
	allocator
		rootStack: (allocator rootStack collect: [ :each | self move: each ]).
	allocator staticRoots
		do: [ :each | 
			| obj |
			obj := self memory uint32At: each.
			obj := self move: obj.
			self memory uint32At: each put: obj ].
	whenCompleted ifNotNil: [ whenCompleted cull: self ].
	^ allocator
		gcAlloc: anInteger
		insufficientDo: [ self error: 'insufficient memory after garbage collection' ]
]

{ #category : #testing }
LCopyingGC >> isInOldSpace: anInteger [
	^ anInteger + 1 between: oldBase and: oldEnd
]

{ #category : #testing }
LCopyingGC >> isValidAddress: anInteger [
	^ anInteger = 0
		or: [ (allocator isInCurrentSpace: anInteger)
				or: [ (allocator isDynamicMemory: anInteger) not ] ]
]

{ #category : #private }
LCopyingGC >> move: anInteger [
	oldAddress := anInteger.
	replacement := 0.
	previousObject := 0.
	[ true ]
		whileTrue: [ self step1.
			((self isInOldSpace: oldAddress)
				or: [ (allocator isInCurrentSpace: oldAddress) or: [ oldAddress = 0 ] ])
				ifFalse: [ self error ].
			self
				step2: [ :v | 
					((self memory isSmallInteger: v) or: [ self isValidAddress: v ])
						ifFalse: [ self error ].
					^ v ] ]
]

{ #category : #accessing }
LCopyingGC >> oldBase [
	^ oldBase
]

{ #category : #accessing }
LCopyingGC >> oldBase: anObject [
	oldBase := anObject
]

{ #category : #accessing }
LCopyingGC >> oldEnd [
	^ oldEnd
]

{ #category : #accessing }
LCopyingGC >> oldEnd: anObject [
	oldEnd := anObject
]

{ #category : #api }
LCopyingGC >> setupSpaces [
	spaceSize := (allocator availableMemory - 3) // 2 // 4 * 4.
	spaceOne := (allocator memoryBase + 2) // 4 * 4 + 1.
	(spaceOne = allocator dynamicStart)
		ifFalse: [ self error ].
	spaceTwo := spaceOne + spaceSize.
	allocator memoryBase: spaceOne.
	allocator memoryEnd: spaceOne + spaceSize - 1
]

{ #category : #accessing }
LCopyingGC >> spaceOne [
	^ spaceOne
]

{ #category : #accessing }
LCopyingGC >> spaceOne: anObject [
	spaceOne := anObject
]

{ #category : #accessing }
LCopyingGC >> spaceSize [
	^ spaceSize
]

{ #category : #accessing }
LCopyingGC >> spaceSize: anObject [
	spaceSize := anObject
]

{ #category : #accessing }
LCopyingGC >> spaceTwo [
	^ spaceTwo
]

{ #category : #accessing }
LCopyingGC >> spaceTwo: anObject [
	spaceTwo := anObject
]

{ #category : #private }
LCopyingGC >> step1 [
	| sz |
	[ true ]
		whileTrue: [ (self memory isSmallInteger: oldAddress)
				ifTrue: [ replacement := oldAddress.
					oldAddress := previousObject.
					^ self ].
			(allocator isInCurrentSpace: oldAddress)
				ifTrue: [ self error: 'GC invariant failure -- address in new space' ].
			(self isInOldSpace: oldAddress)
				ifFalse: [ replacement := oldAddress.
					oldAddress := previousObject.
					^ self ].
			(self memory gcDoneAt: oldAddress)
				ifTrue: [ replacement := (self memory isBinaryAt: oldAddress)
						ifTrue: [ self memory classOfObjectAt: oldAddress ]
						ifFalse: [ sz := self memory sizeOfObjectAt: oldAddress.
							self memory objectAt: oldAddress rawDataAt: sz ].
					oldAddress := previousObject.
					^ self ].
			(self memory isBinaryAt: oldAddress)
				ifTrue: [ self step1Binary ]
				ifFalse: [ self step1Normal ] ]
]

{ #category : #private }
LCopyingGC >> step1Binary [
	| size newAddress |
	size := self memory sizeOfObjectAt: oldAddress.
	newAddress := allocator gcIAlloc: size insufficientDo: [ self error ].
	self memory copyBinaryDataObjectAt: oldAddress to: newAddress.
	self memory markGcDoneObjectAt: oldAddress.
	self memory objectAt: newAddress class: previousObject.
	previousObject := oldAddress.
	oldAddress := self memory classOfObjectAt: oldAddress.
	self memory objectAt: previousObject class: newAddress
]

{ #category : #private }
LCopyingGC >> step1Normal [
	| size newAddress |
	size := self memory sizeOfObjectAt: oldAddress.
	newAddress := allocator gcAlloc: size insufficientDo: [ self error ].

	"newAddress = 595072 ifTrue: [ self halt ]."

	self memory markGcDoneObjectAt: oldAddress.
	self memory objectAt: newAddress rawDataAt: size put: previousObject.
	previousObject := oldAddress.
	oldAddress := self memory objectAt: oldAddress rawDataAt: size.
	self memory objectAt: previousObject rawDataAt: size put: newAddress
]

{ #category : #private }
LCopyingGC >> step2: aBlock [
	[ true ]
		whileTrue: [ oldAddress = 0
				ifTrue: [ aBlock cull: replacement ].
			((self memory isBinaryAt: oldAddress)
				or: [ (self memory sizeOfObjectAt: oldAddress) = 0 ])
				ifTrue: [ self step2Binary ]
				ifFalse: [ ^ self step2Normal ] ]
]

{ #category : #private }
LCopyingGC >> step2Binary [
	| newAddress |
	newAddress := self memory classOfObjectAt: oldAddress.
	previousObject := self memory classOfObjectAt: newAddress.
	self memory objectAt: newAddress class: replacement.
	self memory objectAt: oldAddress class: newAddress.
	replacement := newAddress.
	oldAddress := previousObject
]

{ #category : #private }
LCopyingGC >> step2Normal [
	| newAddress size |
	size := self memory sizeOfObjectAt: oldAddress.
	newAddress := self memory objectAt: oldAddress rawDataAt: size.
	previousObject := self memory objectAt: newAddress rawDataAt: size.
	self memory objectAt: newAddress rawDataAt: size put: replacement.
	size := size - 1.
	[ size > 0
		and: [ (self memory objectAt: oldAddress rawDataAt: size) = 0 ] ]
		whileTrue: [ self memory objectAt: newAddress rawDataAt: size put: 0.
			size := size - 1 ].
	self memory objectAt: oldAddress size: size.

	"oldAddress = 595072 ifTrue: [ self halt ]."

	self memory markGcDoneObjectAt: oldAddress.
	self memory objectAt: newAddress rawDataAt: size put: previousObject.
	previousObject := oldAddress.
	oldAddress := self memory objectAt: oldAddress rawDataAt: size.
	self memory objectAt: previousObject rawDataAt: size put: newAddress
]

{ #category : #private }
LCopyingGC >> toggleSpace [
	allocator memoryBase = spaceOne
		ifTrue: [ allocator memoryBase: spaceTwo.
			oldBase := spaceOne ]
		ifFalse: [ allocator memoryBase: spaceOne.
			oldBase := spaceTwo ].
	allocator memoryPointer: allocator memoryBase.
	allocator memoryEnd: allocator memoryBase + spaceSize - 1.
	oldEnd := oldBase + spaceSize - 1
]
