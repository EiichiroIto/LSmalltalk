Class {
	#name : #LEncoder,
	#superclass : #LObject,
	#instVars : [
		'name',
		'byteCodes',
		'index',
		'literals',
		'stackSize',
		'maxStack'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LEncoder >> backUp [
	" back up one instruction "
	index := index - 1
]

{ #category : #'as yet unclassified' }
LEncoder >> currentLocation [
	^ index
]

{ #category : #'as yet unclassified' }
LEncoder >> expandByteCodes [	| newarray size |
	size := byteCodes size.
	newarray := LByteArray new: size + 8.
	1 to: size do: [:i | newarray at: i put: (byteCodes at: i)].
	byteCodes := newarray
]

{ #category : #'as yet unclassified' }
LEncoder >> genCode: byte [
	index := index + 1.
	(index >= byteCodes size)
		ifTrue: [ self expandByteCodes].
	byteCodes at: index put: byte.
	^ index
]

{ #category : #'as yet unclassified' }
LEncoder >> genHigh: high low: low [
	(low >= 16)
		ifTrue: [ self genHigh: 0 low: high. self genCode: low ]
		ifFalse: [ self genCode: high * 16 + low ]
]

{ #category : #'as yet unclassified' }
LEncoder >> genLiteral: aValue [ | idx |
	idx := literals indexOf: aValue.
	idx notNil ifTrue: [ ^ idx - 1 ].
	literals := literals with: aValue.
	^ literals size - 1
]

{ #category : #'as yet unclassified' }
LEncoder >> genVal: byte [
	self genCode: (byte rem: 256).
	self genCode: (byte quo: 256).
	^ index-1
]

{ #category : #'as yet unclassified' }
LEncoder >> lineNum: l [
	" Don't care, except in DebugEncoder subclass "
]

{ #category : #'as yet unclassified' }
LEncoder >> method: maxTemps class: c text: text [
	^ LMethod name: name byteCodes: byteCodes literals: literals
		stackSize: maxStack temporarySize: maxTemps class: c
		text: text
]

{ #category : #'as yet unclassified' }
LEncoder >> name: n [
	name := n asSymbol.
	byteCodes := LByteArray new: 20.
	index := 0.
	literals := LArray new: 0.
	stackSize := 0.
	maxStack := 1.
]

{ #category : #'as yet unclassified' }
LEncoder >> patch: loc [
		" patch a goto from a block "
	byteCodes at: loc put: (index rem: 256).
	byteCodes at: (loc + 1) put: (index quo: 256)
]

{ #category : #'as yet unclassified' }
LEncoder >> popArgs: n [
	stackSize := stackSize - n.
]

{ #category : #'as yet unclassified' }
LEncoder >> pushArgs: n [
	stackSize := stackSize + n.
	maxStack := stackSize max: maxStack
]
