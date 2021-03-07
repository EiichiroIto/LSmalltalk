"
A TLMethodSizeTest is a test class for testing the behavior of TLMethodSize
"
Class {
	#name : #TLMethodSizeTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
TLMethodSizeTest >> newConstant [
	^ LImageBuilder new
]

{ #category : #test }
TLMethodSizeTest >> testByteCodesInMethod [
	self assert: self newConstant byteCodesInMethod isNumber
]

{ #category : #test }
TLMethodSizeTest >> testClassInMethod [
	self assert: self newConstant classInMethod isNumber
]

{ #category : #test }
TLMethodSizeTest >> testLiteralsInMethod [
	self assert: self newConstant literalsInMethod isNumber
]

{ #category : #test }
TLMethodSizeTest >> testMethodSize [
	self assert: self newConstant methodSize isNumber
]

{ #category : #test }
TLMethodSizeTest >> testNameInMethod [
	self assert: self newConstant nameInMethod isNumber
]

{ #category : #test }
TLMethodSizeTest >> testStackSizeInMethod [
	self assert: self newConstant stackSizeInMethod isNumber
]

{ #category : #test }
TLMethodSizeTest >> testTemporarySizeInMethod [
	self assert: self newConstant temporarySizeInMethod equals: 4
]

{ #category : #test }
TLMethodSizeTest >> testTextInMethod [
	self assert: self newConstant textInMethod isNumber
]
