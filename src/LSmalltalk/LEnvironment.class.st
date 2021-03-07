Class {
	#name : #LEnvironment,
	#superclass : #Object,
	#instVars : [
		'symbols',
		'globals',
		'nilObject',
		'bootMethod',
		'trueObject',
		'falseObject'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #api }
LEnvironment >> addGlobal: anInteger named: aString [
	globals at: aString asSymbol put: anInteger
]

{ #category : #api }
LEnvironment >> addSymbol: anInteger named: aString [
	symbols at: aString asSymbol put: anInteger
]

{ #category : #accessing }
LEnvironment >> bootMethod [
	^ bootMethod
]

{ #category : #accessing }
LEnvironment >> bootMethod: anObject [
	bootMethod := anObject
]

{ #category : #accessing }
LEnvironment >> falseObject [
	^ falseObject
]

{ #category : #accessing }
LEnvironment >> falseObject: anObject [
	falseObject := anObject
]

{ #category : #api }
LEnvironment >> globalKeys [
	^ globals keys
]

{ #category : #api }
LEnvironment >> globalNamed: aString [
	^ globals at: aString asSymbol
]

{ #category : #api }
LEnvironment >> globalNamed: aString ifAbsent: aBlock [
	^ globals at: aString ifAbsent: aBlock
]

{ #category : #accessing }
LEnvironment >> globals [
	^ globals
]

{ #category : #accessing }
LEnvironment >> globals: anObject [
	globals := anObject
]

{ #category : #api }
LEnvironment >> globalsDo: aBlock [
	globals do: aBlock
]

{ #category : #testing }
LEnvironment >> includesGlobal: aString [
	^ globals includesKey: aString
]

{ #category : #testing }
LEnvironment >> includesSymbol: aString [
	^ symbols includesKey: aString
]

{ #category : #initialization }
LEnvironment >> initialize [
	globals := Dictionary new.
	symbols := Dictionary new
]

{ #category : #accessing }
LEnvironment >> nilObject [
	^ nilObject
]

{ #category : #accessing }
LEnvironment >> nilObject: anObject [
	nilObject := anObject
]

{ #category : #printing }
LEnvironment >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: 'globals=';
		nextPutAll: globals size asString;
		nextPutAll: ' symbols=';
		nextPutAll: symbols size asString;
		nextPut: $)
]

{ #category : #api }
LEnvironment >> symbolNamed: aString [
	^ symbols at: aString
]

{ #category : #api }
LEnvironment >> symbolValues [
	^ symbols values
]

{ #category : #accessing }
LEnvironment >> symbols [
	^ symbols
]

{ #category : #accessing }
LEnvironment >> symbols: anObject [
	symbols := anObject
]

{ #category : #accessing }
LEnvironment >> trueObject [
	^ trueObject
]

{ #category : #accessing }
LEnvironment >> trueObject: anObject [
	trueObject := anObject
]
