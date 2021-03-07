Class {
	#name : #LProcess,
	#superclass : #LObject,
	#instVars : [
		'context',
		'state',
		'result'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #accessing }
LProcess >> context [
	^ context
]

{ #category : #accessing }
LProcess >> context: aContext [
	context := aContext
]

{ #category : #'as yet unclassified' }
LProcess >> doExecute: ticks [
	self primNo: 6 a: self b: ticks
]

{ #category : #execution }
LProcess >> execute [
	| r |
	r := self doExecute: 0.
	r = 3
		ifTrue: [ " Note: state field is filled in with arguments on error "
			(state at: 1) print.
			' (class ' print.
			(state at: 1) class print.
			') ' print.
			'does not understand: ' print.
			result printNl ].
	r = 4
		ifTrue: [ ^ result ]
		ifFalse: [ 'Backtrace:' printNl.
			context backtrace.
			^ nil ]
]
