Class {
	#name : #LStaticAllocator,
	#superclass : #LMemoryAllocator,
	#instVars : [
		'staticPointer'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #api }
LStaticAllocator >> asDynamicAllocator [
	| obj |
	obj := self dynamicAllocatorClass new.
	obj memory: self memory.
	obj dynamicStart: self staticPointer.
	^ obj
]

{ #category : #private }
LStaticAllocator >> reset [
	staticPointer := 1
]

{ #category : #api }
LStaticAllocator >> staticAlloc: anInteger [
	| obj |
	obj := staticPointer - 1.
	staticPointer := staticPointer + ((anInteger + 2) * memory pointerSize).
	staticPointer > memory core size
		ifTrue: [ self error: 'insufficient static memory' ].
	memory objectAt: obj size: anInteger.
	^ obj
]

{ #category : #api }
LStaticAllocator >> staticIAlloc: anInteger [
	| trueSize obj |
	trueSize := (anInteger + memory bytesPerWord - 1) // memory bytesPerWord.
	obj := self staticAlloc: trueSize.
	memory objectAt: obj size: anInteger.
	memory markBinaryObjectAt: obj.
	^ obj
]

{ #category : #accessing }
LStaticAllocator >> staticPointer [
	^ staticPointer
]

{ #category : #accessing }
LStaticAllocator >> staticPointer: anObject [
	staticPointer := anObject
]
