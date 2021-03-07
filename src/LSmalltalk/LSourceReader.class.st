Class {
	#name : #LSourceReader,
	#superclass : #Object,
	#instVars : [
		'builder'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #accessing }
LSourceReader >> builder [
	^ builder
]

{ #category : #accessing }
LSourceReader >> builder: anObject [
	builder := anObject
]

{ #category : #private }
LSourceReader >> parse: anArray on: aStream [
	(anArray first beginsWith: 'COMMENT')
		ifTrue: [ ^ self ].
	anArray first = 'RAWCLASS'
		ifTrue: [ ^ self parseRawClass: anArray ].
	anArray first = 'CLASS'
		ifTrue: [ ^ self parseClass: anArray ].
	anArray first = 'METHOD'
		ifTrue: [ ^ self parseMethod: anArray on: aStream ].
	anArray first = 'BEGIN'
		ifTrue: [ ^ self parseBegin: anArray ].
	anArray first = 'END'
		ifTrue: [ ^ self ].
	self error: 'invalid keyword'
]

{ #category : #private }
LSourceReader >> parseBegin: anArray [
	| line |
	line := anArray copyWithoutFirst joinUsing: Character space.
	builder addBootMethod: line
]

{ #category : #private }
LSourceReader >> parseClass: anArray [
	builder
		class: anArray second
		superClass: anArray third
		variables: (anArray copyFrom: 4 to: anArray size)
]

{ #category : #private }
LSourceReader >> parseMethod: anArray on: aStream [
	| cl body line |
	cl := anArray second.
	line := ''.
	body := WriteStream on: String new.
	[ line = '!' ]
		whileFalse: [ body nextPutAll: line.
			body nextPutAll: String cr.
			line := aStream nextLine ].
	builder class: cl instanceMethod: body contents
]

{ #category : #private }
LSourceReader >> parseRawClass: anArray [
	builder
		class: anArray second
		isInstanceOf: anArray third
		andSubClassOf: anArray fourth
		withVariables: (anArray copyFrom: 5 to: anArray size)
]

{ #category : #api }
LSourceReader >> readSourceFileNamed: aString [
	| fr in line tokens |
	fr := FileSystem workingDirectory / aString.
	in := fr readStream.
	[ in atEnd ]
		whileFalse: [ line := in nextLine.
			line := line copyReplaceAll: Character tab asString with: Character space asString.
			tokens := line splitOn: Character space.
			tokens := tokens reject: #isEmpty.
			self parse: tokens on: in ]
]
