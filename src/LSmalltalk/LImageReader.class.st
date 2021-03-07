Class {
	#name : #LImageReader,
	#superclass : #Object,
	#instVars : [
		'stream',
		'memory',
		'objects',
		'allocator'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #accessing }
LImageReader >> allocator [
	^ allocator
]

{ #category : #accessing }
LImageReader >> allocator: anObject [
	allocator := anObject
]

{ #category : #initialization }
LImageReader >> initialize [
	objects := OrderedCollection new
]

{ #category : #accessing }
LImageReader >> memory [
	^ memory
]

{ #category : #accessing }
LImageReader >> memory: anObject [
	memory := anObject
]

{ #category : #api }
LImageReader >> objectRead [
	| type |
	type := self readWord.
	type = 0
		ifTrue: [ self error: 'read in a null object' ].
	type = 1
		ifTrue: [ ^ self readOrdinalObject ].
	type = 2
		ifTrue: [ ^ self readInteger ].
	type = 3
		ifTrue: [ ^ self readByteArray ].
	type = 4
		ifTrue: [ ^ self readPreviousObject ].
	type = 5
		ifTrue: [ ^ self readNilObject ].
	self error: 'invalid type'
]

{ #category : #accessing }
LImageReader >> objects [
	^ objects
]

{ #category : #accessing }
LImageReader >> objects: anObject [
	objects := anObject
]

{ #category : #private }
LImageReader >> readByteArray [
	| size obj s |
	size := self readWord.
	obj := allocator staticIAlloc: size.
	objects add: obj.
	s := ((1 to: size) collect: [ :each | self readWord ]) asByteArray asString.
	memory objectAt: obj string: s.
	memory objectAt: obj class: self objectRead.
	^ obj
]

{ #category : #private }
LImageReader >> readInt32 [
	| v c |
	v := 0.
	c := 1.
	4
		timesRepeat: [ v := v + (stream next * c).
			c := c * 256 ].
	(v between: 0 and: 16r7FFFFFFF)
		ifFalse: [ self error ].
	v >= 16r40000000
		ifTrue: [ v := v - 16r80000000 ].
	^ v
]

{ #category : #private }
LImageReader >> readInteger [
	| val |
	val := self readInt32.
	^ memory newSmallInteger: val
]

{ #category : #private }
LImageReader >> readNilObject [
	^ objects first
]

{ #category : #private }
LImageReader >> readOrdinalObject [
	| size obj |
	size := self readWord.
	obj := allocator staticAlloc: size.
	objects add: obj.
	memory objectAt: obj class: self objectRead.
	0 to: size - 1 do:
		[ :each | memory objectAt: obj dataAt: each put: self objectRead ].
	^ obj
]

{ #category : #private }
LImageReader >> readPreviousObject [
	| size |
	size := self readWord.
	^ objects at: size + 1
]

{ #category : #private }
LImageReader >> readWord [
	| u |
	stream atEnd
		ifTrue: [ self error: 'unexpected end of file reading image file' ].
	u := stream next.
	u = 255
		ifTrue: [ ^ 255 + self readWord ].
	^ u
]

{ #category : #accessing }
LImageReader >> stream [
	^ stream
]

{ #category : #accessing }
LImageReader >> stream: anObject [
	stream := anObject
]
