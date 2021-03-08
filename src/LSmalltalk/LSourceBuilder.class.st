Class {
	#name : #LSourceBuilder,
	#superclass : #Object,
	#instVars : [
		'output'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #api }
LSourceBuilder >> class: aString instanceMethod: aString2 [
	output add: 'METHOD ' , aString.
	aString2 linesDo: [ :each | output add: each ].
	output add: '!'
]

{ #category : #api }
LSourceBuilder >> class: aString isInstanceOf: aString2 andSubClassOf: aString3 withVariables: aCollection [
	| s |
	s := WriteStream on: String new.
	s
		nextPutAll: 'RAWCLASS ';
		nextPutAll: aString;
		nextPutAll: ' ';
		nextPutAll: aString2;
		nextPutAll: ' ';
		nextPutAll: aString3;
		nextPutAll: ' '.
	aCollection
		do: [ :each | s nextPutAll: each ]
		separatedBy: [ s nextPutAll: ' ' ].
	output add: s contents
]

{ #category : #api }
LSourceBuilder >> class: aString superClass: aString2 variables: aCollection [ 
	output add: 'CLASS ', aString, ' ', aString2, ' ', (aCollection joinUsing: Character space)
]

{ #category : #initialization }
LSourceBuilder >> initialize [
	output := OrderedCollection new
]

{ #category : #accessing }
LSourceBuilder >> output [
	^ output
]

{ #category : #accessing }
LSourceBuilder >> output: anObject [
	output := anObject
]

{ #category : #api }
LSourceBuilder >> writeOn: aStream [
	output
		do: [ :each | 
			aStream nextPutAll: each.
			aStream nextPutAll: String cr ]
]
