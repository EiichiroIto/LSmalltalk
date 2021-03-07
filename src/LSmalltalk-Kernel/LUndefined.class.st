Class {
	#name : #LUndefined,
	#superclass : #LObject,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LUndefined class >> new [
	" there is only one nil object "

	^ nil
]

{ #category : #testing }
LUndefined >> isNil [
	" yes, we are nil "
	^ true
]

{ #category : #accessing }
LUndefined >> main [
	| command |
	" initialize classes "
	LChar init.

	" main execution loop "
	[ '-> ' print.
	command := LString input.
	command notNil ]
		whileTrue: [ command isEmpty
				ifFalse: [ command doIt printNl ] ]
]

{ #category : #testing }
LUndefined >> notNil [
	" no, we are not not-nil "

	^ false
]

{ #category : #printing }
LUndefined >> printString [
	^ 'nil'
]
