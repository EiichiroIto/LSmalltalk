"
A LImageReaderTest is a test class for testing the behavior of LImageReader
"
Class {
	#name : #LImageReaderTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LImageReaderTest >> newReader: anArray [
	^ LImageReader new
		stream: (ReadStream on: anArray);
		yourself
]

{ #category : #test }
LImageReaderTest >> testReadInt32 [
	| r |
	r := self newReader: #(123 0 0 0).
	self assert: r readInt32 equals: 123.
	r := self newReader: #(0 1 0 0).
	self assert: r readInt32 equals: 256.
	r := self newReader: #(1 2 0 0).
	self assert: r readInt32 equals: 513.
	r := self newReader: #(1 0 1 0).
	self assert: r readInt32 equals: 65537
]

{ #category : #test }
LImageReaderTest >> testReadWord [
	| r |
	r := self newReader: #(10).
	self assert: r readWord equals: 10.
	r := self newReader: #(200).
	self assert: r readWord equals: 200.
	r := self newReader: #(255 0).
	self assert: r readWord equals: 255.
	r := self newReader: #(255 45).
	self assert: r readWord equals: 300
]
