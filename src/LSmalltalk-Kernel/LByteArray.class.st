Class {
	#name : #LByteArray,
	#superclass : #LArray,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LByteArray class >> new: size [
	self primNo: 20 a: self b: size
]

{ #category : #converting }
LByteArray >> asString [
	| str sz |
	sz := self size.
	str := LString new: sz.
	1 to: sz do: [ :i | str at: i put: (self at: i) asChar ].
	^ str
]

{ #category : #accessing }
LByteArray >> at: index [
	self primNo: 21 a: self b: index.
	(self includesKey: index)
		ifFalse: [ self badIndex ].
	self primitiveFailed
]

{ #category : #accessing }
LByteArray >> at: index ifAbsent: exceptionBlock [
	self primNo: 21 a: self b: index.
	exceptionBlock value
]

{ #category : #accessing }
LByteArray >> at: index put: aValue [
	self
		primNo: 22
		a: aValue
		b: self
		c: index.
	(self includesKey: index)
		ifFalse: [ self badIndex ].
	self primitiveFailed
]

{ #category : #accessing }
LByteArray >> basicAt: index [
	self primNo: 21 a: self b: index.
	^ nil
]
