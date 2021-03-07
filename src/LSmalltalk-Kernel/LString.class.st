Class {
	#name : #LString,
	#superclass : #LArray,
	#category : #'LSmalltalk-Kernel'
}

{ #category : #accessing }
LString class >> input [
	| value c nl |
	" read a line from input "
	value := ''.
	nl := LChar newline.
	[ c := LChar input.
	c isNil
		ifTrue: [ ^ nil ].
	c ~= nl ] whileTrue: [ value := value + c asString ].
	^ value
]

{ #category : #'instance creation' }
LString class >> new: size [
	self primNo: 20 a: self b: size
]

{ #category : #'as yet unclassified' }
LString class >> newline [
	^ LChar newline asString
]

{ #category : #'stop conditions' }
LString class >> tab [
	^ LChar tab asString
]

{ #category : #converting }
LString >> asNumber [
	| val |
	" parse a base-10 ASCII number, return nil on failure "
	val := 0.
	self
		do: [ :c | 
			c isDigit
				ifFalse: [ ^ nil ].
			val := val * 10 + (c value - 48) ].
	^ val
]

{ #category : #converting }
LString >> asSymbol [
	^ LSymbol new: self
]

{ #category : #accessing }
LString >> at: index [
	^ self at: index ifAbsent: [ self badIndex ]
]

{ #category : #accessing }
LString >> at: index ifAbsent: exceptionBlock [
	| c |
	c := self basicAt: index.
	c isNil
		ifTrue: [ ^ exceptionBlock value ]
		ifFalse: [ ^ LChar new: c ]
]

{ #category : #accessing }
LString >> at: index put: aValue [
	(self basicAt: index put: aValue value) isNil
		ifTrue: [ self badIndex ]
]

{ #category : #accessing }
LString >> basicAt: index [
	self primNo: 21 a: self b: index.
	^ nil
]

{ #category : #accessing }
LString >> basicAt: index put: value [
	self
		primNo: 22
		a: value
		b: self
		c: index.
	^ nil
]

{ #category : #'as yet unclassified' }
LString >> break: separators [
	| words word |
	" break string into words, using separators "
	word := ''.
	words := LList new.
	self
		do: [ :c | 
			(separators includes: c)
				ifTrue: [ word size > 0
						ifTrue: [ words addLast: word.
							word := '' ]	" found a word " ]
				ifFalse: [ word := word + c asString ] ].
	" maybe a last word "
	word size > 0
		ifTrue: [ words addLast: word ].
	^ words
]

{ #category : #enumerating }
LString >> collect: transformationBlock [
	^ (super collect: transformationBlock) asString
]

{ #category : #copying }
LString >> copy [
	" make a clone of ourself "

	self primNo: 23 a: self b: LString
]

{ #category : #'menu commands' }
LString >> doIt [
	| meth |
	meth := LUndefined parseMethod: 'doItCommand ^' + self.
	^ meth notNil
		ifTrue: [ ^ LContext new perform: meth withArguments: (LArray new: 1) ]
]

{ #category : #actions }
LString >> edit [
	self primNo: 105 a: self
]

{ #category : #comparing }
LString >> hash [
	| sz |
	sz := self size.
	sz < 2
		ifTrue: [ sz = 1
				ifTrue: [ ^ (self at: 1) value ].
			^ 0 ].
	^ (self at: 1) value + (self at: sz) value
]

{ #category : #accessing }
LString >> indexOf: val [
	| c s |
	" For non-strings, search scalar LArray elements "
	(val isKindOf: LString)
		ifFalse: [ ^ super indexOf: val ].

	" Otherwise look for substring match "
	c := val at: 1.
	s := val size.
	1 to: self size - s + 1 do: [ :idx | 
		" Cheap check for initial char equality "
		(self at: idx) = c
			ifTrue: [ (self from: idx to: idx + s - 1) = val
					ifTrue: [ ^ idx ] ] ].
	^ nil
]

{ #category : #'as yet unclassified' }
LString >> lowerCase [
	| ret c |
	ret := LString new: self size.
	1 to: self size do: [ :x | 
		c := self at: x.
		c isUpperCase
			ifTrue: [ c := c lowerCase ].
		ret at: x put: c ].
	^ ret
]

{ #category : #printing }
LString >> printString [
	^ self
]

{ #category : #printing }
LString >> printWidth: width [
	| ret |
	self size >= width absolute
		ifTrue: [ ^ self ].
	ret := self.
	width negative
		ifTrue:
			[ self size + 1 to: width negated do: [ :ignore | ret := ' ' + ret ] ]
		ifFalse:
			[ self size + 1 to: width do: [ :ignore | ret := ret + ' ' ] ].
	^ ret
]

{ #category : #highlighting }
LString >> reverse [
	^ self asList reverse asString
]

{ #category : #enumerating }
LString >> select: testBlock [
	^ (super select: testBlock) asString
]
