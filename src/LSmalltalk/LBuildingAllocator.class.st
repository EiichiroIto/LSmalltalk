Class {
	#name : #LBuildingAllocator,
	#superclass : #LMemoryAllocator,
	#instVars : [
		'free'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #api }
LBuildingAllocator >> dictionary: anInteger insertAt: anInteger2 put: anInteger3 [
	| keys vals res a obj sz |
	keys := memory objectAt: anInteger dataAt: memory keysInDictionary.
	vals := memory objectAt: anInteger dataAt: memory valuesInDictionary.
	sz := memory sizeOfObjectAt: keys.
	0 to: sz - 1 do: [ :index | 
		a := memory objectAt: keys dataAt: index.
		res := memory compareString: anInteger2 with: a.
		res < 0
			ifTrue: [ obj := self insertedArray: keys at: index put: anInteger2.
				memory objectAt: anInteger dataAt: memory keysInDictionary put: obj.
				obj := self insertedArray: vals at: index put: anInteger3.
				memory objectAt: anInteger dataAt: memory valuesInDictionary put: obj.
				^ self ].
		res = 0
			ifTrue: [ self error: 'dictionary insert duplicate key' ] ].
	obj := self insertedArray: keys at: sz put: anInteger2.
	memory objectAt: anInteger dataAt: memory keysInDictionary put: obj.
	obj := self insertedArray: vals at: sz put: anInteger3.
	memory objectAt: anInteger dataAt: memory valuesInDictionary put: obj
]

{ #category : #accessing }
LBuildingAllocator >> free [
	^ free
]

{ #category : #accessing }
LBuildingAllocator >> free: anObject [
	free := anObject
]

{ #category : #api }
LBuildingAllocator >> gcAlloc: anInteger [
	| result |
	result := free - 1.
	free := free + memory objectSize + (anInteger * memory pointerSize).
	free > memory core size
		ifTrue: [ self error: 'out of memory' ].
	memory objectAt: result size: anInteger.
	^ result
]

{ #category : #private }
LBuildingAllocator >> insertedArray: anInteger at: anInteger2 put: anInteger3 [
	| size obj |
	size := memory sizeOfObjectAt: anInteger.
	obj := self gcAlloc: size + 1.
	memory objectAt: obj class: (memory classOfObjectAt: anInteger).
	0 to: anInteger2 - 1 do: [ :each | 
		memory
			objectAt: obj
			dataAt: each
			put: (memory objectAt: anInteger dataAt: each) ].
	memory objectAt: obj dataAt: anInteger2 put: anInteger3.
	anInteger2 to: size - 1 do: [ :each | 
		memory
			objectAt: obj
			dataAt: each + 1
			put: (memory objectAt: anInteger dataAt: each) ].
	^ obj
]

{ #category : #api }
LBuildingAllocator >> newByteArray: anArray [
	| addr |
	addr := self binaryAlloc: anArray size.
	memory objectAt: addr byteArray: anArray.
	^ addr
]

{ #category : #api }
LBuildingAllocator >> newClass: anInteger adding: anInteger2 [
	| cl |
	cl := self gcAlloc: memory classSize + anInteger2.
	memory classAt: cl name: anInteger.
	^ cl
]

{ #category : #api }
LBuildingAllocator >> newString: aString [
	| addr |
	addr := self binaryAlloc: aString size.
	memory objectAt: addr string: aString.
	^ addr
]

{ #category : #private }
LBuildingAllocator >> reset [
	free := 1
]
