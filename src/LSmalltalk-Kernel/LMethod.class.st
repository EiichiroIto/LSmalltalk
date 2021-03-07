Class {
	#name : #LMethod,
	#superclass : #LObject,
	#instVars : [
		'name',
		'byteCodes',
		'literals',
		'stackSize',
		'temporarySize',
		'class',
		'text'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #private }
LMethod class >> flushCache [
	self primNo: 34.
	self primitiveFailed
]

{ #category : #'as yet unclassified' }
LMethod class >> name: n byteCodes: b literals: l stackSize: s temporarySize: ts class: c text: t [
	| newMethod |
	newMethod := self new.
	super in: newMethod at: 1 put: n.
	super in: newMethod at: 2 put: b.
	super in: newMethod at: 3 put: l.
	super in: newMethod at: 4 put: s.
	super in: newMethod at: 5 put: ts.
	super in: newMethod at: 6 put: c.
	super in: newMethod at: 7 put: t.
	^ newMethod
]

{ #category : #'as yet unclassified' }
LMethod >> args: argNames inst: instNames temp: tempNames [
	" Hook for recording symbolic debug "
]

{ #category : #accessing }
LMethod >> byteCodes [
	^ byteCodes
]

{ #category : #accessing }
LMethod >> literals [
	^ literals
]

{ #category : #accessing }
LMethod >> name [
	^ name
]

{ #category : #accessing }
LMethod >> stackSize [
	^ stackSize
]

{ #category : #accessing }
LMethod >> temporarySize [
	^ temporarySize
]

{ #category : #accessing }
LMethod >> text [
	^ text
]
