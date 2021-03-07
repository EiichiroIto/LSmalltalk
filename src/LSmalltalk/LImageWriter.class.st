Class {
	#name : #LImageWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'writtenObjects',
		'memory'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #api }
LImageWriter >> imageOut: anInteger [
	| i |
	(memory isSmallInteger: anInteger)
		ifTrue: [ ^ self writeInteger: anInteger ].
"Transcript show: (memory printObjectAt: anInteger); cr."
	i := writtenObjects indexOf: anInteger.
	i > 0
		ifTrue: [ i == 1
				ifTrue: [ self writeWord: 5 ]
				ifFalse: [ self writeWord: 4.
					self writeWord: i - 1 ].
				^ self ].
	writtenObjects add: anInteger.
	(memory isBinaryAt: anInteger)
		ifTrue: [ ^ self writeBinary: anInteger ].
	^ self writeObject: anInteger
]

{ #category : #initialization }
LImageWriter >> initialize [
	writtenObjects := OrderedCollection new
]

{ #category : #accessing }
LImageWriter >> memory [
	^ memory
]

{ #category : #accessing }
LImageWriter >> memory: anObject [
	memory := anObject
]

{ #category : #accessing }
LImageWriter >> stream [
	^ stream
]

{ #category : #accessing }
LImageWriter >> stream: anObject [
	stream := anObject
]

{ #category : #private }
LImageWriter >> writeBinary: anInteger [
	| size arr |
	size := memory sizeOfObjectAt: anInteger.
	self writeWord: 3.
	self writeWord: size.
	arr := memory byteArrayOfObjectAt: anInteger.
	arr do: [ :each | self writeWord: each ].
	self writeClassOf: anInteger
]

{ #category : #private }
LImageWriter >> writeClassOf: anInteger [
	| cl |
	cl := memory classOfObjectAt: anInteger.
	"Transcript show: (memory printClassAt: cl); cr."
	self imageOut: cl
]

{ #category : #private }
LImageWriter >> writeInt32: anInteger [
	| v |
	v := anInteger.
	(v between: -16r40000000 and: 16r3FFFFFFF)
		ifFalse: [ self error ].
	v < 0
		ifTrue: [ v := v + 16r80000000 ].
	4
		timesRepeat: [ stream nextPut: (v bitAnd: 16rFF).
			v := v // 256 ]
]

{ #category : #private }
LImageWriter >> writeInteger: anInteger [
	| v |
	v := memory smallIntegerValue: anInteger.
	self writeWord: 2.
	self writeInt32: v
]

{ #category : #private }
LImageWriter >> writeObject: anInteger [
	| size v |
	size := memory sizeOfObjectAt: anInteger.
	self writeWord: 1.
	self writeWord: size.
	self writeClassOf: anInteger.
	0 to: size - 1 do: [ :each | 
		v := memory objectAt: anInteger dataAt: each.
		self imageOut: v ]
]

{ #category : #private }
LImageWriter >> writeWord: anInteger [
	anInteger < 0
		ifTrue: [ self error: 'writeWord: negative value' ].
	anInteger >= 255
		ifTrue: [ stream nextPut: 255.
			self writeWord: anInteger - 255 ]
		ifFalse: [ stream nextPut: anInteger ]
]

{ #category : #accessing }
LImageWriter >> writtenObjects [
	^ writtenObjects
]

{ #category : #accessing }
LImageWriter >> writtenObjects: anObject [
	writtenObjects := anObject
]
