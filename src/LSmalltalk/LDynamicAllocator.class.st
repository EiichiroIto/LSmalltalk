Class {
	#name : #LDynamicAllocator,
	#superclass : #LMemoryAllocator,
	#instVars : [
		'memoryBase',
		'memoryPointer',
		'gc',
		'rootStack',
		'staticRoots',
		'memoryEnd',
		'dynamicStart'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #api }
LDynamicAllocator >> addStaticRoot: anInteger [
	| i |
	i := staticRoots indexOf: anInteger.
	i > 0
		ifTrue: [ ^ self ].
	staticRoots add: anInteger
]

{ #category : #api }
LDynamicAllocator >> availableMemory [
	^ self memoryEnd - memoryBase + 1
]

{ #category : #api }
LDynamicAllocator >> currentObjectsDo: aBlock [
	| addr size |
	addr := memoryBase - 1.
	[ addr < (memoryPointer - 1) ]
		whileTrue: [ size := memory sizeOfObjectAt: addr.
			(memory isBinaryAt: addr)
				ifTrue: [ size := memory trueSizeOf: size ].
			size := memory objectSizeOf: size.
			addr + size > memoryPointer
				ifTrue: [ self error ].
			aBlock cull: addr.
			addr := addr + size ].
	^ addr
]

{ #category : #accessing }
LDynamicAllocator >> dynamicStart [
	^ dynamicStart
]

{ #category : #accessing }
LDynamicAllocator >> dynamicStart: anObject [
	dynamicStart := anObject.
	memoryPointer := anObject.
	memoryBase := anObject
]

{ #category : #accessing }
LDynamicAllocator >> gc [
	^ gc
]

{ #category : #accessing }
LDynamicAllocator >> gc: anObject [
	gc := anObject
]

{ #category : #api }
LDynamicAllocator >> gcAlloc: anInteger [
	^ self
		gcAlloc: anInteger
		insufficientDo: [ gc garbageCollect: anInteger ]
]

{ #category : #private }
LDynamicAllocator >> gcAlloc: anInteger insufficientDo: aBlock [
	| obj |
	obj := gc allocate: anInteger.
	obj ifNil: [ ^ aBlock value ].
	memory objectAt: obj size: anInteger.
	^ obj
]

{ #category : #api }
LDynamicAllocator >> gcIAlloc: anInteger [
	^ self
		gcIAlloc: anInteger
		insufficientDo: [ gc garbageCollect: anInteger ]
]

{ #category : #private }
LDynamicAllocator >> gcIAlloc: anInteger insufficientDo: aBlock [
	| trueSize obj |
	trueSize := memory trueSizeOf: anInteger.
	obj := self gcAlloc: trueSize insufficientDo: aBlock.
	memory objectAt: obj size: anInteger.
	memory markBinaryObjectAt: obj.
	^ obj
]

{ #category : #initialization }
LDynamicAllocator >> initialize [
	super initialize.
	rootStack := OrderedCollection new.
	staticRoots := OrderedCollection new
]

{ #category : #testing }
LDynamicAllocator >> isDynamicMemory: anInteger [
	^ anInteger + 1 >= dynamicStart
]

{ #category : #testing }
LDynamicAllocator >> isInCurrentSpace: anInteger [
	^ anInteger + 1 between: memoryBase and: self memoryEnd
]

{ #category : #accessing }
LDynamicAllocator >> memoryBase [
	^ memoryBase
]

{ #category : #accessing }
LDynamicAllocator >> memoryBase: anObject [
	memoryBase := anObject
]

{ #category : #accessing }
LDynamicAllocator >> memoryEnd [
	^ memoryEnd ifNil: [ memory coreSize ]
]

{ #category : #accessing }
LDynamicAllocator >> memoryEnd: anObject [
	memoryEnd := anObject
]

{ #category : #accessing }
LDynamicAllocator >> memoryPointer [
	^ memoryPointer
]

{ #category : #accessing }
LDynamicAllocator >> memoryPointer: anObject [
	memoryPointer := anObject
]

{ #category : #api }
LDynamicAllocator >> popRoot [
	^ rootStack removeLast
]

{ #category : #api }
LDynamicAllocator >> pushRoot: anInteger [
	rootStack add: anInteger
]

{ #category : #accessing }
LDynamicAllocator >> rootStack [
	^ rootStack
]

{ #category : #accessing }
LDynamicAllocator >> rootStack: anObject [
	rootStack := anObject
]

{ #category : #api }
LDynamicAllocator >> simpleAllocate: anInteger [
	| obj |
	obj := memoryPointer - 1.
	memoryPointer := memoryPointer + (memory objectSizeOf: anInteger).
	^ memoryPointer <= self memoryEnd
		ifTrue: [ obj ]
		ifFalse: [ nil ]
]

{ #category : #api }
LDynamicAllocator >> staticObjectsDo: aBlock [
	| addr size |
	addr := 0.
	[ addr < (dynamicStart - 1) ]
		whileTrue: [ size := memory sizeOfObjectAt: addr.
			(memory isBinaryAt: addr)
				ifTrue: [ size := memory trueSizeOf: size ].
			size := memory objectSizeOf: size.
			addr + size > memoryPointer
				ifTrue: [ self error ].
			aBlock cull: addr.
			addr := addr + size ].
	^ addr
]

{ #category : #accessing }
LDynamicAllocator >> staticRoots [
	^ staticRoots
]

{ #category : #accessing }
LDynamicAllocator >> staticRoots: anObject [
	staticRoots := anObject
]

{ #category : #api }
LDynamicAllocator >> thirdOfRoot [
	^ rootStack at: (rootStack size - 2)
]

{ #category : #accessing }
LDynamicAllocator >> whenCompleted [
	^ gc whenCompleted
]

{ #category : #accessing }
LDynamicAllocator >> whenCompleted: aBlock [
	gc whenCompleted: aBlock
]
