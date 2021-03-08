"
A LSourceGeneratorTest is a test class for testing the behavior of LSourceGenerator
"
Class {
	#name : #LSourceGeneratorTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LSourceGeneratorTest >> newGenerator [
	^ LSourceGenerator new
		builder: LSourceBuilder new;
		yourself
]

{ #category : #test }
LSourceGeneratorTest >> testBuilder [
	| g b |
	g := self newGenerator.
	self assert: g builder class equals: LSourceBuilder.
	b := LImageBuilder new.
	g builder: b.
	self assert: g builder identicalTo: b
]

{ #category : #test }
LSourceGeneratorTest >> testClassClassName [
	| g |
	g := self newGenerator.
	self assert: g classClassName isNil.
	g classClassName: 'abc'.
	self assert: g classClassName equals: 'abc'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateAllClassesFrom [
	| g s |
	g := self newGenerator.
	g
		specials:
			{LObject.
			LClass} asSet.
	g classClassName: 'LClass'.
	g generateAllClassesFrom: LObject.
	s := ReadStream on: g builder output.
	self
		assert: s next
		equals:
			'CLASS LMethod LObject name byteCodes literals stackSize temporarySize class text'.
	self
		assert: s next
		equals:
			'CLASS LParser LObject text index tokenType token argNames tempNames instNames maxTemps errBlock lineNum'.
	self assert: s next equals: 'CLASS LFile LObject fileID'.
	self assert: s next equals: 'CLASS LUndefined LObject '.
	self assert: s next equals: 'CLASS LBoolean LObject '.
	self assert: s next equals: 'CLASS LTrue LBoolean '.
	self assert: s next equals: 'CLASS LFalse LBoolean '.
	self
		assert: s next
		equals: 'CLASS LProcess LObject context state result'.
	self
		assert: s next
		equals:
			'CLASS LContext LObject method arguments temporaries stack bytePointer stackTop previousContext'.
	self
		assert: s next
		equals:
			'CLASS LBlock LContext argumentLocation creatingContext oldBytePointer'.
	self assert: s next equals: 'CLASS LMagnitude LObject '.
	self
		assert: s next
		equals: 'RAWCLASS MetaLSymbol LClass MetaLMagnitude symbols'.
	self
		assert: s next
		equals: 'RAWCLASS LSymbol MetaLSymbol LMagnitude '.
	self
		assert: s next
		equals: 'RAWCLASS MetaLChar LClass MetaLMagnitude chars'.
	self
		assert: s next
		equals: 'RAWCLASS LChar MetaLChar LMagnitude value'.
	self assert: s next equals: 'CLASS LCollection LMagnitude '.
	self assert: s next equals: 'CLASS LList LCollection elements'.
	self assert: s next equals: 'CLASS LArray LCollection '.
	self assert: s next equals: 'CLASS LOrderedArray LArray '.
	self assert: s next equals: 'CLASS LByteArray LArray '.
	self assert: s next equals: 'CLASS LString LArray '.
	self assert: s next equals: 'CLASS LSet LCollection members growth'.
	self assert: s next equals: 'CLASS LIdentitySet LSet '.
	self
		assert: s next
		equals: 'CLASS LInterval LCollection low high step'.
	self assert: s next equals: 'CLASS LTree LCollection root'.
	self
		assert: s next
		equals: 'CLASS LDictionary LCollection keys values'.
	self assert: s next equals: 'CLASS LNumber LMagnitude '.
	self assert: s next equals: 'CLASS LInteger LNumber '.
	self
		assert: s next
		equals: 'RAWCLASS MetaLSmallInt LClass MetaLNumber seed'.
	self
		assert: s next
		equals: 'RAWCLASS LSmallInt MetaLSmallInt LNumber '.
	self assert: s next equals: 'CLASS LAssociation LMagnitude key value'.
	self assert: s next equals: 'CLASS LLink LObject value next'.
	self assert: s next equals: 'CLASS LNode LObject value left right'.
	self assert: s next equals: 'CLASS LParserNode LObject lineNum'.
	self assert: s next equals: 'CLASS LBodyNode LParserNode statements'.
	self
		assert: s next
		equals: 'CLASS LReturnNode LParserNode expression'.
	self
		assert: s next
		equals: 'CLASS LAssignNode LParserNode target expression'.
	self assert: s next equals: 'CLASS LLiteralNode LParserNode value'.
	self
		assert: s next
		equals: 'CLASS LArgumentNode LParserNode position'.
	self
		assert: s next
		equals: 'CLASS LTemporaryNode LParserNode position'.
	self assert: s next equals: 'CLASS LInstNode LParserNode position'.
	self
		assert: s next
		equals: 'CLASS LPrimitiveNode LParserNode number arguments'.
	self
		assert: s next
		equals: 'CLASS LBlockNode LParserNode statements temporaryLocation'.
	self
		assert: s next
		equals: 'CLASS LCascadeNode LParserNode head list'.
	self
		assert: s next
		equals: 'CLASS LMessageNode LParserNode receiver name arguments'.
	self
		assert: s next
		equals:
			'CLASS LEncoder LObject name byteCodes index literals stackSize maxStack'.
	self assert: s atEnd
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateAllMethodsFrom [
	| g |
	g := self newGenerator.
	g generateAllMethodsFrom: LObject.
	self assert: g builder output size equals: 3271
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateClass [
	| g b |
	g := self newGenerator.
	b := g builder.
	g generateClass: LUndefined.
	g generateClass: LBoolean.
	g generateClass: LTrue.
	g generateClass: LFalse.
	g generateClass: LProcess.
	g generateClass: LContext.
	g generateClass: LBlock.
	g generateClass: LMethod.
	g generateClass: LMagnitude.
	g generateClass: LCollection.
	g generateClass: LList.
	g generateClass: LDictionary.
	g generateClass: LArray.
	g generateClass: LOrderedArray.
	g generateClass: LByteArray.
	g generateClass: LString.
	g generateClass: LSet.
	g generateClass: LIdentitySet.
	g generateClass: LNumber.
	g generateClass: LInteger.
	g generateClass: LLink.
	g generateClass: LNode.
	g generateClass: LInterval.
	g generateClass: LFile.
	g generateClass: LAssociation.
	g generateClass: LTree.
	g generateClass: LParser.
	g generateClass: LParserNode.
	g generateClass: LEncoder.
	g generateClass: LBodyNode.
	g generateClass: LReturnNode.
	g generateClass: LAssignNode.
	g generateClass: LLiteralNode.
	g generateClass: LArgumentNode.
	g generateClass: LTemporaryNode.
	g generateClass: LInstNode.
	g generateClass: LPrimitiveNode.
	g generateClass: LBlockNode.
	g generateClass: LCascadeNode.
	g generateClass: LMessageNode.
	self assert: (b output at: 1) equals: 'CLASS LUndefined LObject '.
	self assert: (b output at: 2) equals: 'CLASS LBoolean LObject '.
	self assert: (b output at: 3) equals: 'CLASS LTrue LBoolean '.
	self assert: (b output at: 4) equals: 'CLASS LFalse LBoolean '.
	self
		assert: (b output at: 5)
		equals: 'CLASS LProcess LObject context state result'.
	self
		assert: (b output at: 6)
		equals:
			'CLASS LContext LObject method arguments temporaries stack bytePointer stackTop previousContext'.
	self
		assert: (b output at: 7)
		equals:
			'CLASS LBlock LContext argumentLocation creatingContext oldBytePointer'.
	self
		assert: (b output at: 8)
		equals:
			'CLASS LMethod LObject name byteCodes literals stackSize temporarySize class text'.
	self assert: (b output at: 9) equals: 'CLASS LMagnitude LObject '.
	self
		assert: (b output at: 10)
		equals: 'CLASS LCollection LMagnitude '.
	self
		assert: (b output at: 11)
		equals: 'CLASS LList LCollection elements'.
	self
		assert: (b output at: 12)
		equals: 'CLASS LDictionary LCollection keys values'.
	self assert: (b output at: 13) equals: 'CLASS LArray LCollection '.
	self assert: (b output at: 14) equals: 'CLASS LOrderedArray LArray '.
	self assert: (b output at: 15) equals: 'CLASS LByteArray LArray '.
	self assert: (b output at: 16) equals: 'CLASS LString LArray '.
	self
		assert: (b output at: 17)
		equals: 'CLASS LSet LCollection members growth'.
	self assert: (b output at: 18) equals: 'CLASS LIdentitySet LSet '.
	self assert: (b output at: 19) equals: 'CLASS LNumber LMagnitude '.
	self assert: (b output at: 20) equals: 'CLASS LInteger LNumber '.
	self
		assert: (b output at: 21)
		equals: 'CLASS LLink LObject value next'.
	self
		assert: (b output at: 22)
		equals: 'CLASS LNode LObject value left right'.
	self
		assert: (b output at: 23)
		equals: 'CLASS LInterval LCollection low high step'.
	self assert: (b output at: 24) equals: 'CLASS LFile LObject fileID'.
	self
		assert: (b output at: 25)
		equals: 'CLASS LAssociation LMagnitude key value'.
	self assert: (b output at: 26) equals: 'CLASS LTree LCollection root'.
	self
		assert: (b output at: 27)
		equals:
			'CLASS LParser LObject text index tokenType token argNames tempNames instNames maxTemps errBlock lineNum'.
	self
		assert: (b output at: 28)
		equals: 'CLASS LParserNode LObject lineNum'.
	self
		assert: (b output at: 29)
		equals:
			'CLASS LEncoder LObject name byteCodes index literals stackSize maxStack'.
	self
		assert: (b output at: 30)
		equals: 'CLASS LBodyNode LParserNode statements'.
	self
		assert: (b output at: 31)
		equals: 'CLASS LReturnNode LParserNode expression'.
	self
		assert: (b output at: 32)
		equals: 'CLASS LAssignNode LParserNode target expression'.
	self
		assert: (b output at: 33)
		equals: 'CLASS LLiteralNode LParserNode value'.
	self
		assert: (b output at: 34)
		equals: 'CLASS LArgumentNode LParserNode position'.
	self
		assert: (b output at: 35)
		equals: 'CLASS LTemporaryNode LParserNode position'.
	self
		assert: (b output at: 36)
		equals: 'CLASS LInstNode LParserNode position'.
	self
		assert: (b output at: 37)
		equals: 'CLASS LPrimitiveNode LParserNode number arguments'.
	self
		assert: (b output at: 38)
		equals: 'CLASS LBlockNode LParserNode statements temporaryLocation'.
	self
		assert: (b output at: 39)
		equals: 'CLASS LCascadeNode LParserNode head list'.
	self
		assert: (b output at: 40)
		equals: 'CLASS LMessageNode LParserNode receiver name arguments'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateClassMetaClass [
	| g b |
	g := self newGenerator.
	g classClassName: 'LClass'.
	b := g builder.
	g generateClass: LSymbol metaClass: LSymbol class.
	g generateClass: LChar metaClass: LChar class.
	g generateClass: LSmallInt metaClass: LSmallInt class.
	self
		assert: b output first
		equals: 'RAWCLASS MetaLSymbol LClass MetaLMagnitude symbols'.
	self
		assert: b output second
		equals: 'RAWCLASS LSymbol MetaLSymbol LMagnitude '.
	self
		assert: b output third
		equals: 'RAWCLASS MetaLChar LClass MetaLMagnitude chars'.
	self
		assert: b output fourth
		equals: 'RAWCLASS LChar MetaLChar LMagnitude value'.
	self
		assert: b output fifth
		equals: 'RAWCLASS MetaLSmallInt LClass MetaLNumber seed'.
	self
		assert: b output sixth
		equals: 'RAWCLASS LSmallInt MetaLSmallInt LNumber '
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateClassMethodInClass [
	| g b |
	g := self newGenerator.
	b := g builder.
	g
		generateClassMethod: LUndefined class >> #new
		inClass: LUndefined.
	self assert: (b output at: 1) equals: 'METHOD MetaLUndefined'.
	self assert: (b output at: 2) equals: 'new'.
	self assert: (b output at: 3) equals: '	" there is only one nil object "'.
	self assert: (b output at: 4) equals: ''.
	self assert: (b output at: 5) equals: '	^ nil'.
	self assert: (b output at: 6) equals: '!'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateMethodInClass [
	| g b |
	g := self newGenerator.
	b := g builder.
	g
		generateMethod: LPrimitiveNode >> #number:arguments:
		inClass: LPrimitiveNode.
	self assert: (b output at: 1) equals: 'METHOD LPrimitiveNode'.
	self assert: (b output at: 2) equals: 'number: n arguments: a'.
	self assert: (b output at: 3) equals: '	number := n.'.
	self assert: (b output at: 4) equals: '	arguments := a.'.
	self assert: (b output at: 5) equals: '!'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateMethodsInClass [
	| g b |
	g := self newGenerator.
	b := g builder.
	g generateMethodsInClass: LPrimitiveNode.
	self assert: (b output at: 1) equals: 'METHOD LPrimitiveNode'.
	self
		assert: (b output at: 2)
		equals: 'compile: encoder block: inBlock | argsize |'.
	self assert: (b output at: 3) equals: '	argsize := arguments size.'.
	self assert: (b output at: 4) equals: '	super compile: encoder.'.
	self assert: (b output at: 5) equals: '	encoder pushArgs: argsize.'.
	self
		assert: (b output at: 6)
		equals: '	arguments reverseDo: [ :a | a compile: encoder block: inBlock ].'.
	self
		assert: (b output at: 7)
		equals: '	encoder genHigh: 13 low: argsize.'.
	self assert: (b output at: 8) equals: '	encoder genCode: number.'.
	self assert: (b output at: 9) equals: '	encoder popArgs: argsize'.
	self assert: (b output at: 10) equals: '!'.
	self assert: (b output at: 11) equals: 'METHOD LPrimitiveNode'.
	self assert: (b output at: 12) equals: 'number: n arguments: a'.
	self assert: (b output at: 13) equals: '	number := n.'.
	self assert: (b output at: 14) equals: '	arguments := a.'.
	self assert: (b output at: 15) equals: '!'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateMethodsInClass2 [
	| g b |
	g := self newGenerator.
	b := g builder.
	g generateMethodsInClass: LUndefined.
	self assert: (b output at: 1) equals: 'METHOD MetaLUndefined'.
	self assert: (b output at: 2) equals: 'new'.
	self
		assert: (b output at: 3)
		equals: '	" there is only one nil object "'.
	self assert: (b output at: 4) equals: ''.
	self assert: (b output at: 5) equals: '	^ nil'.
	self assert: (b output at: 6) equals: '!'.
	self assert: (b output at: 7) equals: 'METHOD LUndefined'.
	self assert: (b output at: 8) equals: 'isNil'.
	self assert: (b output at: 9) equals: '	" yes, we are nil "'.
	self assert: (b output at: 10) equals: '	^ true'.
	self assert: (b output at: 11) equals: '!'.
	self assert: (b output at: 12) equals: 'METHOD LUndefined'.
	self assert: (b output at: 13) equals: 'printString'.
	self assert: (b output at: 14) equals: '	^ ''nil'''.
	self assert: (b output at: 15) equals: '!'.
	self assert: (b output at: 16) equals: 'METHOD LUndefined'.
	self assert: (b output at: 17) equals: 'main'.
	self assert: (b output at: 18) equals: '	| command |'.
	self assert: (b output at: 19) equals: '	" initialize classes "'.
	self assert: (b output at: 20) equals: '	LChar init.'.
	self assert: (b output at: 21) equals: ''.
	self assert: (b output at: 22) equals: '	" main execution loop "'.
	self assert: (b output at: 23) equals: '	[ ''-> '' print.'.
	self assert: (b output at: 24) equals: '	command := LString input.'.
	self assert: (b output at: 25) equals: '	command notNil ]'.
	self
		assert: (b output at: 26)
		equals: '		whileTrue: [ command isEmpty'.
	self
		assert: (b output at: 27)
		equals: '				ifFalse: [ command doIt printNl ] ]'.
	self assert: (b output at: 28) equals: '!'.
	self assert: (b output at: 29) equals: 'METHOD LUndefined'.
	self assert: (b output at: 30) equals: 'notNil'.
	self assert: (b output at: 31) equals: '	" no, we are not not-nil "'.
	self assert: (b output at: 32) equals: ''.
	self assert: (b output at: 33) equals: '	^ false'.
	self assert: (b output at: 34) equals: '!'
]

{ #category : #test }
LSourceGeneratorTest >> testGenerateObjectClass [
	| g s |
	g := self newGenerator.
	g generateObject: LObject class: LClass.
	self assert: g classClassName equals: 'LClass'.
	s := ReadStream on: g builder output.
	self
		assert: s next
		equals:
			'RAWCLASS LClass MetaLClass LObject name parentClass methods size variables'.
	self assert: s next equals: 'RAWCLASS MetaLObject LClass LClass '.
	self assert: s next equals: 'RAWCLASS MetaLClass LClass MetaLObject '.
	self assert: s atEnd
]

{ #category : #test }
LSourceGeneratorTest >> testSpecials [
	| g |
	g := self newGenerator.
	self assert: g specials class equals: Set.
	g specials: #().
	self assert: g specials equals: #()
]
