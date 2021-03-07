Class {
	#name : #LFile,
	#superclass : #LObject,
	#instVars : [
		'fileID'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'as yet unclassified' }
LFile class >> doOpen: nm mode: mode [
	self primNo: 100 a: nm b: mode.
]

{ #category : #'as yet unclassified' }
LFile class >> fileIn: nm [
	| file |
	file := self openRead: nm.
	file opened ifFalse: [ ^ self error: 'cannot open file ' + nm ].
	file fileIn.
	file close.
	^ 'file in completed'
]

{ #category : #'as yet unclassified' }
LFile class >> image: nm [
	| file |
		" open a file, write the image, then close "
	file := self openWrite: nm.
	file opened ifFalse: [ ^ self error: 'cannot open file ' + nm ].
	file writeImage.
	file close
]

{ #category : #'as yet unclassified' }
LFile class >> openRead: nm [
		" open new file for reading "
	^ self in: (self new) at: 1 put: (self doOpen: nm mode: 'r')
]

{ #category : #'as yet unclassified' }
LFile class >> openUpdate: nm [
		" open new file for reading and writing "
	^ self in: (self new) at: 1 put: (self doOpen: nm mode: 'r+')
]

{ #category : #'as yet unclassified' }
LFile class >> openWrite: nm [
		" open new file for writing "
	^ self in: (self new) at: 1 put: (self doOpen: nm mode: 'w')
]

{ #category : #accessing }
LFile >> at: idx [
	self primNo: 108 a: fileID b: idx.
	self primitiveFailed
]

{ #category : #accessing }
LFile >> at: idx get: buf [
	| size |
	self at: idx.
	size := buf size.
	self primNo: 106 a: fileID b: buf c: size.
]

{ #category : #accessing }
LFile >> at: idx put: buf [
	self at: idx.
	self write: buf size: buf size
]

{ #category : #accessing }
LFile >> at: idx size: count [
	| buf res |
	buf := LByteArray new: count.
	res := self at: idx get: buf.
	(res < count) ifTrue: [ buf := buf from: 1 to: res ].
	^ buf
]

{ #category : #'initialize-release' }
LFile >> close [
		" close file, return file descriptor "
	fileID notNil ifTrue: [
		self close: fileID.
		fileID := nil
	]
]

{ #category : #'primitives-file' }
LFile >> close: id [
	self primNo: 103 a: id.
]

{ #category : #'as yet unclassified' }
LFile >> doRead [
	self primNo: 101 a: fileID.
	fileID isNil ifTrue: [ self notOpened ].
	self primitiveFailed
]

{ #category : #ToDeprecate }
LFile >> fileIn [
	| cmd |
	[ cmd := self readChar. cmd notNil ] whileTrue: [
		self fileInDispatch: cmd
	]
]

{ #category : #'as yet unclassified' }
LFile >> fileInDispatch: cmd [
	| c |
	" Immediate execte "
	cmd = $+
		ifTrue: [ self readLine doIt printNl.
			^ self ].

	" Method definition "
	(cmd = $! or: [ cmd = $= ])
		ifTrue: [ self methodCommand: cmd = $!.
			^ self ].

	" Comment enclosed in quotes... find matching quote "
	cmd = $"
		ifTrue: [ [ c := self readChar.
			c ~= $" ] whileTrue: [ " Consume chars until closing quote " nil ].
			^ self ].

	" Blank line, just return to process next line "
	cmd = LChar newline
		ifTrue: [ ^ self ].

	" It is random chars (treat as comment--discard) "
	self readLine
]

{ #category : #'as yet unclassified' }
LFile >> methodCommand: classCmd [
	| name aClass text line |
	name := self readLine asSymbol.
	aClass := LSmalltalk
		at: name
		ifAbsent:
			[ ^ self error: 'unknown class name in file-in: ' + name printString ].
	text := ''.
	[ line := self readLine.
	line isNil
		ifTrue: [ ^ self error: 'unexpected end of input during fileIn' ].
	line ~= '!' ] whileTrue: [ text := text + line + LString newline ].
	classCmd
		ifTrue: [ aClass addMethod: text ]
		ifFalse: [ aClass class addMethod: text ]
]

{ #category : #'as yet unclassified' }
LFile >> newline [
	^ self write: (LString newline)
]

{ #category : #'as yet unclassified' }
LFile >> notOpened [
	self error: 'file is not open'
]

{ #category : #testing }
LFile >> opened [
	^ fileID notNil
]

{ #category : #'as yet unclassified' }
LFile >> readChar [
	| c |
		" read a single character from a file "
	c := self doRead.
	c notNil ifTrue: [ ^ LChar new: c ].
	^ c
]

{ #category : #'as yet unclassified' }
LFile >> readLine [
	| value  c nl |
	" read a line from input "
	fileID isNil ifTrue: [ self error: 'cannot read from unopened file' ].
	value := ''.
	nl := LChar newline.
	[ c := self doRead.
	  c isNil ifTrue: [ ^ nil ].
	  c := LChar new: c.
	  c ~= nl ] whileTrue:
		[ value := value + c asString ].
	^ value
]

{ #category : #writing }
LFile >> write: buf [
	^ self write: buf size: (buf size)
]

{ #category : #writing }
LFile >> write: buf size: count [
	self primNo: 107 a: fileID b: buf c: count.
	self primitiveFailed
]

{ #category : #writing }
LFile >> writeCharValue: n [
	self primNo: 102 a: fileID b: n.
	fileID isNil ifTrue: [ self notOpened ].
	self primitiveFailed
]

{ #category : #writing }
LFile >> writeImage [
		" save the current image in a file "
	fileID notNil
		ifTrue: [ self primNo: 104 a: fileID ]
]
