"
A LImageWriterTest is a test class for testing the behavior of LImageWriter
"
Class {
	#name : #LImageWriterTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LImageWriterTest >> newWriter [
	^ LImageWriter new
		stream: (WriteStream on: Array new);
		yourself
]

{ #category : #test }
LImageWriterTest >> testWriteInt32 [
	| w |
	w := self newWriter.
	w writeInt32: 123.
	self assertCollection: w stream contents equals: #(123 0 0 0).
	w := self newWriter.
	w writeInt32: 256.
	self assertCollection: w stream contents equals: #(0 1 0 0).
	w := self newWriter.
	w writeInt32: 513.
	self assertCollection: w stream contents equals: #(1 2 0 0).
	w := self newWriter.
	w writeInt32: 65537.
	self assertCollection: w stream contents equals: #(1 0 1 0)
]

{ #category : #test }
LImageWriterTest >> testWriteWord [
	| w |
	w := self newWriter.
	w writeWord: 10.
	self assertCollection: w stream contents equals: #(10).
	w := self newWriter.
	w writeWord: 200.
	self assertCollection: w stream contents equals: #(200).
	w := self newWriter.
	w writeWord: 255.
	self assertCollection: w stream contents equals: #(255 0).
	w := self newWriter.
	w writeWord: 300.
	self assertCollection: w stream contents equals: #(255 45)
]
