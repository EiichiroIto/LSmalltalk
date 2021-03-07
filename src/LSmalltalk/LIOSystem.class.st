Class {
	#name : #LIOSystem,
	#superclass : #Object,
	#instVars : [
		'inputs',
		'outputs'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #api }
LIOSystem >> eof [
	^ nil
]

{ #category : #api }
LIOSystem >> getChar [
	| str |
	inputs isEmpty
		ifTrue: [ str := UIManager default request: self getOutput.
			str ifNil: [ ^ nil ].
			str do: [ :each | inputs add: each ].
			inputs add: Character linefeed ].
	^ inputs removeFirst asciiValue
]

{ #category : #private }
LIOSystem >> getOutput [
	| ret |
	ret := outputs asByteArray asString.
	outputs := OrderedCollection new.
	^ ret
]

{ #category : #initialization }
LIOSystem >> initialize [
	inputs := OrderedCollection new.
	outputs := OrderedCollection new
]

{ #category : #api }
LIOSystem >> putChar: aCharacter [
	outputs add: aCharacter
]
