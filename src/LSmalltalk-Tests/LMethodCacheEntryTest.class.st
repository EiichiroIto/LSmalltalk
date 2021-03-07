"
A LMethodCacheEntryTest is a test class for testing the behavior of LMethodCacheEntry
"
Class {
	#name : #LMethodCacheEntryTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LMethodCacheEntryTest >> newEntry [
	^ LMethodCacheEntry new
]

{ #category : #test }
LMethodCacheEntryTest >> testClassOfMethod [
	| e |
	e := self newEntry.
	self assert: e classOfMethod equals: 0.
	e classOfMethod: 123.
	self assert: e classOfMethod equals: 123
]

{ #category : #test }
LMethodCacheEntryTest >> testInitialize [
	| e |
	e := self newEntry.
	self assert: e classOfMethod equals: 0.
	self assert: e method equals: 0.
	self assert: e name equals: 0
]

{ #category : #test }
LMethodCacheEntryTest >> testMethod [
	| e |
	e := self newEntry.
	self assert: e method equals: 0.
	e method: 123.
	self assert: e method equals: 123
]

{ #category : #test }
LMethodCacheEntryTest >> testName [
	| e |
	e := self newEntry.
	self assert: e name equals: 0.
	e name: 123.
	self assert: e name equals: 123
]
