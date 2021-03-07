Class {
	#name : #LArray,
	#superclass : #LCollection,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #'instance creation' }
LArray class >> new [
	^ self new: 0
]

{ #category : #'instance creation' }
LArray class >> new: sz [
	self primNo: 7 a: self b: sz
]

{ #category : #'instance creation' }
LArray class >> with: elemA [
 | ret |
	ret := self new: 1.
	ret at: 1 put: elemA.
	^ ret
]

{ #category : #'instance creation' }
LArray class >> with: elemA with: elemB [ | ret |
	ret := self new: 2.
	ret at: 1 put: elemA.
	ret at: 2 put: elemB.
	^ ret
]

{ #category : #'instance creation' }
LArray class >> with: elemA with: elemB with: elemC [ | ret |
	ret := self new: 3.
	ret at: 1 put: elemA.
	ret at: 2 put: elemB.
	ret at: 3 put: elemC.
	^ ret
]

{ #category : #arithmetic }
LArray >> + aValue [	| size1 size2 newValue |
	" catenate two strings together "
	size1 := self size.
	size2 := aValue size.
	newValue := self class new: (size1 + size2).
	newValue replaceFrom: 1 to: size1 with: self.
	newValue replaceFrom: size1+1 to: size1+size2 with: aValue.
	^ newValue
]

{ #category : #comparing }
LArray >> < arg [
	| selfsize argsize |
	selfsize := self size.
	argsize := arg size.
	1 to: (selfsize min: argsize) do: [ :i | 
		(self at: i) ~= (arg at: i)
			ifTrue: [ ^ (self at: i) < (arg at: i) ] ].
	^ selfsize < argsize
]

{ #category : #comparing }
LArray >> = anArray [
	self size = anArray size
		ifFalse: [ ^ false ].
	1 to: self size do: [ :i | 
		(self at: i) = (anArray at: i)
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #accessing }
LArray >> at: index [
	self primNo: 24 a: self b: index.
	(self includesKey: index) ifFalse: [ self badIndex ].
	self primitiveFailed
]

{ #category : #accessing }
LArray >> at: index ifAbsent: exceptionBlock [
	self primNo: 24 a: self b: index.
	exceptionBlock value
]

{ #category : #accessing }
LArray >> at: index put: value [
	self primNo: 5 a: value b: self c: index.
	(self includesKey: index) ifFalse: [ self badIndex ].
	self primitiveFailed
]

{ #category : #'as yet unclassified' }
LArray >> badIndex [
	self error: 'array indexing error'
]

{ #category : #copying }
LArray >> copy [
	^ self asArray
]

{ #category : #enumerating }
LArray >> do: aBlock [
	1 to: self size do: [:i | aBlock value: (self at: i)]
]

{ #category : #converting }
LArray >> elementsExchangeIdentityWith: otherArray [
	self primNo: 35 a: self b: otherArray.
	self primitiveFailed
]

{ #category : #accessing }
LArray >> first [
	^ self at: 1
]

{ #category : #'instance creation' }
LArray >> from: low to: high [
	| start stop size obj |
	start := low max: 0.
	stop := high min: self size.
	size := stop + 1 - start max: 0.
	obj := self species new: size.
	1 to: size do: [ :i | 
		obj at: i put: (self at: start).
		start := start + 1 ].
	^ obj
]

{ #category : #comparing }
LArray >> hash [
	| sz |
	sz := self size.
	sz < 2
		ifTrue: [ sz = 1
				ifTrue: [ ^ (self at: 1) hash + sz ].
			^ 0 ].
	^ (self at: 1) hash + (self at: sz) hash
]

{ #category : #testing }
LArray >> includes: aValue [
	self do: [ :element | element = aValue ifTrue: [ ^ true ]].
	^ false
]

{ #category : #testing }
LArray >> includesKey: index [
	^ index between: 1 and: self size
]

{ #category : #accessing }
LArray >> indexOf: aValue [
	1 to: self size do: [:idx|
		((self at: idx) == aValue) ifTrue: [ ^ idx ]
	].
	^ nil
]

{ #category : #accessing }
LArray >> indexOfVal: aValue [
	1 to: self size do: [ :idx | 
		(self at: idx) = aValue
			ifTrue: [ ^ idx ] ].
	^ nil
]

{ #category : #'spec protocol' }
LArray >> insert: value at: position [ | newArray newSize |
	newSize := self size + 1.
	newArray := self class new: newSize.
	newArray replaceFrom: 1 to: position-1 with: self.
	newArray at: position put: value.
	newArray replaceFrom: position+1 to: newSize with:
		self startingAt: position.
	^ newArray
]

{ #category : #removing }
LArray >> removeIndex: position [
	| newArray newSize |
	newSize := self size - 1.
	newArray := self class new: newSize.
	newArray replaceFrom: 1 to: position - 1 with: self.
	newArray
		replaceFrom: position
		to: newSize
		with: self
		startingAt: position + 1.
	^ newArray
]

{ #category : #editing }
LArray >> replaceFrom: start to: stop with: replacement [
	^ self replaceFrom: start to: stop with: replacement startingAt: 1
]

{ #category : #accessing }
LArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	| base |
	self
		primNo: 38
		a: start
		b: stop
		c: replacement
		d: repStart
		e: self.
	base := repStart - 1.
	0 to: stop - start do:
		[ :idx | self at: idx + start put: (replacement at: idx + repStart) ]
]

{ #category : #accessing }
LArray >> size [
	" compute number of elements "
	self primNo: 4 a: self
]

{ #category : #'instance creation' }
LArray >> with: newItem [	| newArray size |
	size := self size.
	newArray := self class new: size + 1.
	newArray replaceFrom: 1 to: size with: self.
	newArray at: size + 1 put: newItem.
	^ newArray
]
