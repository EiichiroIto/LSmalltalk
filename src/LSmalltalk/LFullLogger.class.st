Class {
	#name : #LFullLogger,
	#superclass : #LDummyLogger,
	#instVars : [
		'stream'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #initialization }
LFullLogger >> initialize [
	stream := WriteStream on: String new
]

{ #category : #api }
LFullLogger >> log [
	^ stream contents
]

{ #category : #api }
LFullLogger >> saveLogFileNamed: aString [
	| fr |
	fr := FileSystem workingDirectory / aString.
	fr isFile
		ifTrue: [ fr delete ].
	fr writeStreamDo: [ :st | st nextPutAll: stream contents ]
]

{ #category : #api }
LFullLogger >> trace: aString [
	stream nextPutAll: aString asString
]

{ #category : #api }
LFullLogger >> traceCr: aString [
	stream
		nextPutAll: aString asString;
		nextPutAll: String cr
]
