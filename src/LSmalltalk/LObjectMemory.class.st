Class {
	#name : #LObjectMemory,
	#superclass : #Object,
	#traits : 'TLObjectSize',
	#classTraits : 'TLObjectSize classTrait',
	#instVars : [
		'core'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #api }
LObjectMemory >> addressOfObjectAt: anInteger dataAt: anInteger2 [
	^ anInteger + self bytesPerWord + self pointerSize
		+ (self pointerSize * anInteger2)
]

{ #category : #api }
LObjectMemory >> bCopyFrom: anInteger to: anInteger2 count: anInteger3 [
	core replaceFrom: anInteger2 + 1 to: anInteger2 + anInteger3 with: core startingAt: anInteger + 1
]

{ #category : #constants }
LObjectMemory >> binaryMask [
	^ 2
]

{ #category : #api }
LObjectMemory >> byteAddressOfObjectAt: anInteger [
	^ (self stringPositionOfObjectAt: anInteger) - 1
]

{ #category : #api }
LObjectMemory >> byteArrayOfObjectAt: anInteger [
	| sz p |
	sz := self sizeOfObjectAt: anInteger.
	p := self stringPositionOfObjectAt: anInteger.
	^ core copyFrom: p to: p + sz - 1
]

{ #category : #api }
LObjectMemory >> byteAt: anInteger [
	^ self uint8CoreAt: anInteger + 1
]

{ #category : #constants }
LObjectMemory >> bytesPerWord [
	^ 4
]

{ #category : #api }
LObjectMemory >> classAt: anInteger instanceSize: anInteger2 [
	self
		objectAt: anInteger
		dataAt: self instanceSizeInClass
		put: (self newSmallInteger: anInteger2)
]

{ #category : #api }
LObjectMemory >> classAt: anInteger methods: anInteger2 [
	self
		objectAt: anInteger
		dataAt: self methodsInClass
		put: anInteger2
]

{ #category : #api }
LObjectMemory >> classAt: anInteger name: anInteger2 [
	self
		objectAt: anInteger
		dataAt: self nameInClass
		put: anInteger2
]

{ #category : #api }
LObjectMemory >> classAt: anInteger parentClass: anInteger2 [
	self
		objectAt: anInteger
		dataAt: self parentClassInClass
		put: anInteger2
]

{ #category : #api }
LObjectMemory >> classAt: anInteger variables: anInteger2 [
	self
		objectAt: anInteger
		dataAt: self variablesInClass
		put: anInteger2
]

{ #category : #api }
LObjectMemory >> classOfObjectAt: anInteger [
	| p |
	p := anInteger + self bytesPerWord + 1.
	^ self uint32CoreAt: p
]

{ #category : #api }
LObjectMemory >> clearObjectAt: anInteger [
	| size block |
	size := self sizeOfObjectAt: anInteger.
	block := (self isBinaryAt: anInteger)
		ifTrue: [ [ :each | self objectAt: anInteger byteAt: each put: 0 ] ]
		ifFalse: [ [ :each | self objectAt: anInteger dataAt: each put: 0 ] ].
	0 to: size - 1 do: block
]

{ #category : #api }
LObjectMemory >> compareString: anInteger with: anInteger2 [
	| pos1 pos2 size1 size2 sz data1 data2 |
	pos1 := self stringPositionOfObjectAt: anInteger.
	pos2 := self stringPositionOfObjectAt: anInteger2.
	size1 := self sizeOfObjectAt: anInteger.
	size2 := self sizeOfObjectAt: anInteger2.
	sz := size1 min: size2.
	0 to: sz - 1 do: [ :index | 
		data1 := self uint8CoreAt: pos1 + index.
		data2 := self uint8CoreAt: pos2 + index.
		data1 ~= data2
			ifTrue: [ ^ data1 < data2
					ifTrue: [ -1 ]
					ifFalse: [ 1 ] ] ].
	^ size1 - size2
]

{ #category : #api }
LObjectMemory >> copyBinaryDataObjectAt: anInteger to: anInteger2 [
	| size src dst |
	size := self sizeOfObjectAt: anInteger.
	src := self byteAddressOfObjectAt: anInteger.
	dst := self byteAddressOfObjectAt: anInteger2.
	self bCopyFrom: src to: dst count: size
]

{ #category : #api }
LObjectMemory >> copyDataObjectAt: anInteger to: anInteger2 [
	| size src dst |
	size := self sizeOfObjectAt: anInteger.
	src := self byteAddressOfObjectAt: anInteger.
	dst := self byteAddressOfObjectAt: anInteger2.
	self bCopyFrom: src to: dst count: size * self bytesPerWord
]

{ #category : #accessing }
LObjectMemory >> core [
	^ core
]

{ #category : #accessing }
LObjectMemory >> core: anObject [
	core := anObject
]

{ #category : #private }
LObjectMemory >> coreAt: anInteger bitOr: anInteger2 [
	| old |
	old := core byteAt: anInteger.
	core byteAt: anInteger put: (old bitOr: anInteger2 \\ 16r100).
	^ anInteger + 1
]

{ #category : #private }
LObjectMemory >> coreAt: anInteger uint32: anInteger2 [
	| v p |
	p := anInteger.
	v := anInteger2.
	self bytesPerWord
		timesRepeat: [ core byteAt: p put: v \\ 16r100.
			p := p + 1.
			v := v // 16r100 ].
	^ p
]

{ #category : #private }
LObjectMemory >> coreAt: anInteger uint8: anInteger2 [
	core byteAt: anInteger put: anInteger2 \\ 16r100.
	^ anInteger + 1
]

{ #category : #api }
LObjectMemory >> coreSize [
	^ core size
]

{ #category : #testing }
LObjectMemory >> fitsSmallInteger: anInteger [
	^ anInteger between: -16r40000000 and: 16r3FFFFFFF
]

{ #category : #testing }
LObjectMemory >> gcDoneAt: anInteger [
	^ ((self uint8CoreAt: anInteger + 1) bitAnd: self gcDoneMask) > 0
]

{ #category : #constants }
LObjectMemory >> gcDoneMask [
	^ 1
]

{ #category : #api }
LObjectMemory >> initialAllocate: anInteger [
	core := ByteArray new: anInteger withAll: 0
]

{ #category : #api }
LObjectMemory >> instanceSizeOfClassAt: anInteger [
	| v |
	v := self objectAt: anInteger dataAt: self instanceSizeInClass.
	^ self smallIntegerValue: v
]

{ #category : #testing }
LObjectMemory >> isBinaryAt: anInteger [
	^ ((self uint8CoreAt: anInteger + 1) bitAnd: self binaryMask) > 0
]

{ #category : #testing }
LObjectMemory >> isSmallInteger: x [
	^ (x bitAnd: self smallIntegerMask) > 0
]

{ #category : #api }
LObjectMemory >> markBinaryObjectAt: anInteger [
	self coreAt: anInteger + 1 bitOr: self binaryMask
]

{ #category : #api }
LObjectMemory >> markGcDoneObjectAt: anInteger [
	self coreAt: anInteger + 1 bitOr: self gcDoneMask
]

{ #category : #api }
LObjectMemory >> methodsOfClassAt: anInteger [
	^ self objectAt: anInteger dataAt: self methodsInClass
]

{ #category : #api }
LObjectMemory >> nameOfClassAt: anInteger [
	^ self objectAt: anInteger dataAt: self nameInClass
]

{ #category : #api }
LObjectMemory >> newSmallInteger: anInteger [
	| v |
	(self fitsSmallInteger: anInteger)
		ifFalse: [ self error ].
	v := anInteger.
	v < 0
		ifTrue: [ v := 16r80000000 + v ].
	^ (v << 1) bitOr: self smallIntegerMask
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger byteArray: anArray [
	| p |
	p := self stringPositionOfObjectAt: anInteger.
	anArray asByteArray do: [ :each | p := self coreAt: p uint8: each ]
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger byteAt: anInteger2 [
	| p |
	p := self byteAddressOfObjectAt: anInteger.
	^ self uint8CoreAt: p + anInteger2 + 1
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger byteAt: anInteger2 put: anInteger3 [
	| p |
	p := self byteAddressOfObjectAt: anInteger.
	self coreAt: p + anInteger2 + 1 uint8: anInteger3
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger class: anInteger2 [
	| p |
	p := anInteger + self bytesPerWord + 1.
	self coreAt: p uint32: anInteger2
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger dataAt: anInteger2 [
	| p |
	p := self addressOfObjectAt: anInteger dataAt: anInteger2.
	^ self uint32CoreAt: p + 1
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger dataAt: anInteger2 put: anInteger3 [
	| p |
	p := self addressOfObjectAt: anInteger dataAt: anInteger2.
	self coreAt: p + 1 uint32: anInteger3
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger rawDataAt: anInteger2 [
	| p |
	p := self rawAddressOfObjectAt: anInteger dataAt: anInteger2.
	^ self uint32CoreAt: p + 1
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger rawDataAt: anInteger2 put: anInteger3 [
	| p |
	p := self rawAddressOfObjectAt: anInteger dataAt: anInteger2.
	self coreAt: p + 1 uint32: anInteger3
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger size: anInteger2 [
	self coreAt: anInteger + 1 uint32: anInteger2 << 2
]

{ #category : #api }
LObjectMemory >> objectAt: anInteger string: aString [
	| p |
	p := self stringPositionOfObjectAt: anInteger.
	aString do: [ :each | p := self coreAt: p uint8: each asciiValue ]
]

{ #category : #api }
LObjectMemory >> objectSizeOf: anInteger [
	^ (anInteger + 2) * self pointerSize
]

{ #category : #api }
LObjectMemory >> parentClassOfClassAt: anInteger [
	^ self objectAt: anInteger dataAt: self parentClassInClass
]

{ #category : #constants }
LObjectMemory >> pointerSize [
	^ 4
]

{ #category : #printing }
LObjectMemory >> printBinaryObjectAt: anInteger on: aStream [
	| bytes obj |
	obj := self classOfObjectAt: anInteger.
	aStream
		nextPutAll: 'class=';
		nextPutAll: obj asString;
		nextPutAll: ',bytes='.
	bytes := self byteArrayOfObjectAt: anInteger.
	(bytes allSatisfy: [ :each | each asCharacter isControlOther not ])
		ifTrue: [ aStream nextPutAll: bytes asString ]
		ifFalse: [ aStream nextPutAll: '#['.
			bytes
				do: [ :each | aStream nextPutAll: each asString ]
				separatedBy: [ aStream nextPut: Character space ].
			aStream nextPut: $] ]
]

{ #category : #printing }
LObjectMemory >> printClassAt: anInteger [
	| stream obj |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Class(';
		nextPutAll: anInteger asString;
		nextPutAll: ',name='.
	obj := self nameOfClassAt: anInteger.
	stream nextPutAll: (self printObjectAt: obj).
	stream nextPutAll: ',parent='.
	obj := self parentClassOfClassAt: anInteger.
	stream nextPutAll: obj asString.
	stream nextPutAll: ',methods='.
	obj := self methodsOfClassAt: anInteger.
	stream nextPutAll: (self sizeOfObjectAt: obj) asString.
	stream nextPutAll: ',instances='.
	stream nextPutAll: (self instanceSizeOfClassAt: anInteger) asString.
	stream nextPutAll: ',variables='.
	obj := self variablesOfClassAt: anInteger.
	stream nextPutAll: (self sizeOfObjectAt: obj) asString.
	stream nextPut: $).
	^ stream contents
]

{ #category : #printing }
LObjectMemory >> printObjectAt: anInteger [
	| stream |
	(self isSmallInteger: anInteger)
		ifTrue: [ ^ self printSmallInteger: anInteger ].
	stream := WriteStream on: String new.
	stream nextPutAll: 'Object('.
	(self isBinaryAt: anInteger)
		ifTrue: [ self printBinaryObjectAt: anInteger on: stream ]
		ifFalse: [ self printObjectAt: anInteger on: stream ].
	stream nextPut: $).
	^ stream contents
]

{ #category : #printing }
LObjectMemory >> printObjectAt: anInteger on: aStream [
	| size obj |
	aStream
		nextPutAll: anInteger asString;
		nextPutAll: ','.
	size := self sizeOfObjectAt: anInteger.
	aStream nextPutAll: 'class='.
	obj := self classOfObjectAt: anInteger.
	aStream
		nextPutAll: obj asString;
		nextPutAll: ',data=['.
	0 to: size - 1 do: [ :each | 
		aStream
			nextPutAll: (self objectAt: anInteger dataAt: each) asString;
			nextPut: Character space ].
	aStream nextPut: $]
]

{ #category : #printing }
LObjectMemory >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: core size asString;
		nextPutAll: ' bytes)'
]

{ #category : #printing }
LObjectMemory >> printSmallInteger: anInteger [
	| v stream |
	stream := WriteStream on: String new.
	v := self smallIntegerValue: anInteger.
	stream
		nextPutAll: 'SmallInteger(';
		nextPutAll: v asString;
		nextPut: $).
	^ stream contents
]

{ #category : #api }
LObjectMemory >> rawAddressOfObjectAt: anInteger dataAt: anInteger2 [
	^ anInteger + self bytesPerWord + (self pointerSize * anInteger2)
]

{ #category : #api }
LObjectMemory >> sizeOfObjectAt: anInteger [
	^ (self uint32CoreAt: anInteger + 1) >> 2
]

{ #category : #constants }
LObjectMemory >> smallIntegerMask [
	^ 1
]

{ #category : #api }
LObjectMemory >> smallIntegerValue: anInteger [
	| v |
	(anInteger between: 0 and: 16rFFFFFFFF)
		ifFalse: [ self error ].
	v := anInteger >> 1.
	^ v < 16r40000000
		ifTrue: [ v ]
		ifFalse: [ v - 16r80000000 ]
]

{ #category : #api }
LObjectMemory >> stringOfObjectAt: anInteger [
	| sz p |
	sz := self sizeOfObjectAt: anInteger.
	p := self stringPositionOfObjectAt: anInteger.
	^ (core copyFrom: p to: p + sz - 1) asString
]

{ #category : #private }
LObjectMemory >> stringPositionOfObjectAt: anInteger [
	^ anInteger + self bytesPerWord + self pointerSize + 1
]

{ #category : #api }
LObjectMemory >> trueSizeOf: anInteger [
	^ (anInteger + self bytesPerWord - 1) // self bytesPerWord
]

{ #category : #api }
LObjectMemory >> uint32At: anInteger [
	^ self uint32CoreAt: anInteger + 1
]

{ #category : #api }
LObjectMemory >> uint32At: anInteger put: anInteger2 [
	self coreAt: anInteger + 1 uint32: anInteger2
]

{ #category : #private }
LObjectMemory >> uint32CoreAt: anInteger [
	| v p c |
	p := anInteger.
	v := 0.
	c := 1.
	self bytesPerWord
		timesRepeat: [ v := v + ((core byteAt: p) * c).
			c := c * 16r100.
			p := p + 1 ].
	^ v
]

{ #category : #private }
LObjectMemory >> uint8CoreAt: anInteger [
	^ core byteAt: anInteger
]

{ #category : #api }
LObjectMemory >> variablesOfClassAt: anInteger [
	^ self objectAt: anInteger dataAt: self variablesInClass
]
