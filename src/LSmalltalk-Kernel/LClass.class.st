Class {
	#name : #LClass,
	#superclass : #LObject,
	#instVars : [
		'name',
		'parentClass',
		'methods',
		'size',
		'variables'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #adding }
LClass >> addMethod [
	| text |
	text := ' ' edit.
	(self question: 'compile method?')
		ifTrue: [ self addMethod: text ]
]

{ #category : #adding }
LClass >> addMethod: text [
	| meth |
	meth := self parseMethod: text.
	meth notNil
		ifTrue: [ methods at: meth name put: meth.
			LMethod flushCache.
			'ok' printNl.
			^ meth ].
	^ nil
]

{ #category : #'method accessing' }
LClass >> allMethods [
	| allMethods |
	parentClass isNil
		ifTrue: [ allMethods := LDictionary new ]
		ifFalse: [ allMethods := parentClass allMethods ].
	methods binaryDo: [ :n :m | allMethods at: n put: m ].
	^ allMethods
]

{ #category : #'instance creation' }
LClass >> basicNew [
	" Like new "
	self primNo: 7 a: self b: size
]

{ #category : #'as yet unclassified' }
LClass >> editMethod: nm [
	| meth text |
	meth := methods at: nm ifAbsent: [ ^ self error: 'no such method' ].
	text := meth text edit.
	(self question: 'compile method?')
		ifTrue: [ self addMethod: text ]
]

{ #category : #'file in/out' }
LClass >> fileOut [
	| f |
	f := LFile openWrite: name printString + '.st'.
	f isNil
		ifTrue: [ self error: 'File creation failed' ].
	self isMeta
		ifFalse: [ self class fileOut: f ].
	self fileOut: f.
	f close
]

{ #category : #tests }
LClass >> fileOut: f [
	| tag |
	self isMeta
		ifTrue: [ tag := '=' + (name asString from: 5 to: 99) ]
		ifFalse: [ tag := '!' + name asString ].
	tag := tag + LString newline.
	methods
		do: [ :m | 
			f write: tag.
			f write: m text printString.
			f write: '!' + LString newline ]
]

{ #category : #accessing }
LClass >> instanceVariables [
	| names |
	" return all our variable names "
	parentClass notNil
		ifTrue: [ names := parentClass instanceVariables ]
		ifFalse: [ names := LArray new: 0 ].
	(variables isNil or: [ variables isEmpty ])
		ifFalse: [ names := names + variables ].
	^ names
]

{ #category : #testing }
LClass >> isMeta [
	^ (name asString from: 1 to: 4) = 'Meta'
]

{ #category : #'as yet unclassified' }
LClass >> listAllMethods [
	self allMethods keysDo: [ :n | n printNl ]
]

{ #category : #'as yet unclassified' }
LClass >> listMethods [
	methods keysDo: [ :each | each printNl ]
]

{ #category : #accessing }
LClass >> methods [
	" return the tree of methods "
	^ methods
]

{ #category : #'as yet unclassified' }
LClass >> name: n parent: c variables: v [
	" create a new class with the given characteristics "

	name := n.
	parentClass := c.
	methods := LDictionary new.
	size := v size + c size.
	variables := v
]

{ #category : #'instance creation' }
LClass >> new [
	" return a new instance of ourselves "
	self primNo: 7 a: self b: size
]

{ #category : #parsing }
LClass >> parseMethod: text [
	^ (LParser new text: text instanceVars: self instanceVariables)
		parse: self
]

{ #category : #printing }
LClass >> printString [
	" just return our name "
	^ name printString
]

{ #category : #removing }
LClass >> removeMethod: methName [
	methods
		removeKey: methName
		ifAbsent: [ self error: 'Method not present: ' + methName printString ].
	LMethod flushCache
]

{ #category : #accessing }
LClass >> size [
	^ size
]

{ #category : #'subclass creation' }
LClass >> subclass: nm [
	^ self
		subclass: nm
		variables: (LArray new: 0)
		classVariables: (LArray new: 0)
]

{ #category : #'as yet unclassified' }
LClass >> subclass: nm variables: v [
	^ self subclass: nm variables: v classVariables: (LArray new: 0)
]

{ #category : #'as yet unclassified' }
LClass >> subclass: nm variables: v classVariables: cv [
	| meta |
	meta := LClass new
		name: ('Meta' + nm asString) asSymbol
		parent: self class
		variables: cv.
	LSmalltalk at: nm put: (meta new name: nm parent: self variables: v).
	^ 'subclass created: ' + nm printString
]

{ #category : #'class hierarchy' }
LClass >> subclasses [
	self subclasses: 0
]

{ #category : #'accessing class hierarchy' }
LClass >> subclasses: indent [
	LSmalltalk
		do: [ :obj | 
			((obj isKindOf: LClass) and: [ obj superclass == self ])
				ifTrue: [ 1 to: indent do: [ :ignore | $  print ].
					obj printNl.
					obj subclasses: indent + 4 ] ]
]

{ #category : #accessing }
LClass >> superclass [
	^ parentClass
]

{ #category : #accessing }
LClass >> variables [
	^ variables
]

{ #category : #accessing }
LClass >> view: methodName [
	" print the text of the given method "

	(methods at: methodName ifAbsent: [ ^ self error: 'no such method' ])
		text print
]

{ #category : #'as yet unclassified' }
LClass >> viewMethod: nm [
	| meth |
	meth := self allMethods
		at: nm
		ifAbsent: [ ^ self error: 'no such method' ].
	meth text print.
	^ ''
]
