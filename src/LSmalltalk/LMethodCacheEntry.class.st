Class {
	#name : #LMethodCacheEntry,
	#superclass : #Object,
	#instVars : [
		'name',
		'classOfMethod',
		'method'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #accessing }
LMethodCacheEntry >> classOfMethod [
	^ classOfMethod
]

{ #category : #accessing }
LMethodCacheEntry >> classOfMethod: anObject [
	classOfMethod := anObject
]

{ #category : #initialization }
LMethodCacheEntry >> initialize [
	name := classOfMethod := method := 0
]

{ #category : #accessing }
LMethodCacheEntry >> method [
	^ method
]

{ #category : #accessing }
LMethodCacheEntry >> method: anObject [
	method := anObject
]

{ #category : #accessing }
LMethodCacheEntry >> name [
	^ name
]

{ #category : #accessing }
LMethodCacheEntry >> name: anObject [
	name := anObject
]
