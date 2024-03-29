Class {
	#name : #LSourceGenerator,
	#superclass : #Object,
	#traits : 'TLNames',
	#classTraits : 'TLNames classTrait',
	#instVars : [
		'builder',
		'specials',
		'classClassName'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #writing }
LSourceGenerator class >> writeSourceFileNamed: aString [
	"LSourceGenerator writeSourceFileNamed: 'out.txt'"

	| g fr |
	g := self new.
	g builder: LSourceBuilder new.
	g generateObject: LObject class: LClass.
	g generateAllClassesFrom: LObject.
	g generateAllMethodsFrom: LObject.
	fr := FileSystem workingDirectory / aString.
	fr isFile
		ifTrue: [ fr delete ].
	fr writeStreamDo: [ :s | g builder writeOn: s ]
]

{ #category : #accessing }
LSourceGenerator >> builder [
	^ builder
]

{ #category : #accessing }
LSourceGenerator >> builder: anObject [
	builder := anObject
]

{ #category : #accessing }
LSourceGenerator >> classClassName [
	^ classClassName
]

{ #category : #accessing }
LSourceGenerator >> classClassName: anObject [
	classClassName := anObject
]

{ #category : #api }
LSourceGenerator >> generateAllClassesFrom: aClass [
	self generateClass: aClass.
	aClass subclasses do: [ :each | self generateAllClassesFrom: each ]
]

{ #category : #api }
LSourceGenerator >> generateAllMethodsFrom: aClass [
	self generateMethodsInClass: aClass.
	aClass subclasses do: [ :each | self generateAllMethodsFrom: each ]
]

{ #category : #private }
LSourceGenerator >> generateClass: aClass [
	(specials includes: aClass)
		ifTrue: [ ^ self ].
	aClass class instVarNames isEmpty
		ifFalse: [ ^ self generateClass: aClass metaClass: aClass class ].
	builder
		class: aClass name
		superClass: aClass superclass name
		variables: aClass instVarNames
]

{ #category : #private }
LSourceGenerator >> generateClass: aClass metaClass: aMetaClass [
	| metaName |
	metaName := self metaName , aClass name.
	builder
		class: metaName
		isInstanceOf: classClassName
		andSubClassOf: self metaName , aClass superclass name
		withVariables: aMetaClass instVarNames.
	builder
		class: aClass name
		isInstanceOf: metaName
		andSubClassOf: aClass superclass name
		withVariables: aClass instVarNames
]

{ #category : #private }
LSourceGenerator >> generateClassMethod: aCompiledMethod inClass: aClass [
	builder
		class: self metaName , aClass name
		instanceMethod: aCompiledMethod sourceCode
]

{ #category : #private }
LSourceGenerator >> generateMethod: aCompiledMethod inClass: aClass [
	builder class: aClass name instanceMethod: aCompiledMethod sourceCode
]

{ #category : #private }
LSourceGenerator >> generateMethodsInClass: aClass [
	aClass class methods
		do: [ :each | self generateClassMethod: each inClass: aClass ].
	aClass methods
		do: [ :each | self generateMethod: each inClass: aClass ]
]

{ #category : #api }
LSourceGenerator >> generateObject: aClass class: aClass2 [
	specials add: aClass.
	specials add: aClass2.
	classClassName := aClass2 name.
	builder
		class: aClass2 name
		isInstanceOf: self metaName , aClass2 name
		andSubClassOf: aClass name
		withVariables: aClass2 instVarNames.
	builder
		class: self metaName , aClass name
		isInstanceOf: aClass2 name
		andSubClassOf: aClass2 name
		withVariables: aClass class instVarNames.
	builder
		class: self metaName , aClass2 name
		isInstanceOf: aClass2 name
		andSubClassOf: self metaName , aClass name
		withVariables: aClass2 class instVarNames
]

{ #category : #initialization }
LSourceGenerator >> initialize [
	specials := Set new
]

{ #category : #accessing }
LSourceGenerator >> specials [
	^ specials
]

{ #category : #accessing }
LSourceGenerator >> specials: anObject [
	specials := anObject
]
