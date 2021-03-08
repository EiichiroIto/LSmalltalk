Class {
	#name : #LProtoObject,
	#superclass : #Object,
	#category : #'LSmalltalk-Tools'
}

{ #category : #primitives }
LProtoObject class >> primNo: anInteger a: anInteger2 [
	self shouldBeImplemented
]

{ #category : #primitives }
LProtoObject class >> primNo: anInteger a: anInteger2 b: anInteger3 [
	self shouldBeImplemented
]

{ #category : #primitives }
LProtoObject class >> primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4 [
	self shouldBeImplemented
]

{ #category : #primitives }
LProtoObject class >> primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4 d: anInteger5 e: anInteger6 [
	self shouldBeImplemented
]

{ #category : #primitives }
LProtoObject >> primNo: anInteger a: anInteger2 [
	^ self class primNo: anInteger a: anInteger2
]

{ #category : #primitives }
LProtoObject >> primNo: anInteger a: anInteger2 b: anInteger3 [
	^ self class primNo: anInteger a: anInteger2 b: anInteger3
]

{ #category : #primitives }
LProtoObject >> primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4 [
	^ self class primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4
]

{ #category : #primitives }
LProtoObject >> primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4 d: anInteger5 e: anInteger6 [
	^ self class primNo: anInteger a: anInteger2 b: anInteger3 c: anInteger4 d: anInteger5 e: anInteger6
]
