"
A LImageBuilderTest is a test class for testing the behavior of LImageBuilder
"
Class {
	#name : #LImageBuilderTest,
	#superclass : #TestCase,
	#category : #'LSmalltalk-Tests'
}

{ #category : #private }
LImageBuilderTest >> newBuilder [
	| m a |
	m := LObjectMemory new.
	a := LBuildingAllocator new.
	a
		memory: m;
		allocate: 1024.
	^ LImageBuilder new
		allocator: a;
		memory: m;
		yourself
]

{ #category : #test }
LImageBuilderTest >> testAddClassNamed [
	| b m cl r e |
	b := self newBuilder.
	e := b env.
	b setupNilObject.
	m := b memory.
	cl := b addClassNamed: 'OrderedArray'.
	self assert: (e globals includesKey: 'OrderedArray').
	r := m objectAt: cl dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: r) equals: 'OrderedArray'.
	r := m sizeOfObjectAt: cl.
	self assert: r equals: m classSize
]

{ #category : #test }
LImageBuilderTest >> testAddClassNamedAdding [
	| b m cl r e |
	b := self newBuilder.
	e := b env.
	b setupNilObject.
	m := b memory.
	cl := b addClassNamed: 'OrderedArray' adding: 5.
	self assert: (e globals includesKey: 'OrderedArray').
	r := m objectAt: cl dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: r) equals: 'OrderedArray'.
	r := m sizeOfObjectAt: cl.
	self assert: r equals: m classSize + 5
]

{ #category : #test }
LImageBuilderTest >> testAllInstanceVariablesOfClassAt [
	| b cl e |
	b := self newBuilder.
	e := b env.
	b memory initialAllocate: 4096.
	b bigBang.
	b setup2.
	b class: 'Test' superClass: b objectClassName variables: #(a b c).
	b class: 'Test2' superClass: 'Test' variables: #(d e).
	b class: 'Test3' superClass: 'Test2' variables: #(f g h).
	cl := e globalNamed: 'Test'.
	self assert: (b allInstanceVariablesOfClassAt: cl) equals: #(a b c).
	cl := e globalNamed: 'Test2'.
	self assert: (b allInstanceVariablesOfClassAt: cl) equals: #(a b c d e).
	cl := e globalNamed: 'Test3'.
	self assert: (b allInstanceVariablesOfClassAt: cl) equals: #(a b c d e f g h)
]

{ #category : #test }
LImageBuilderTest >> testAllocator [
	| b a |
	b := LImageBuilder new.
	self assert: b allocator isNil.
	a := LBuildingAllocator new.
	b allocator: a.
	self assert: b allocator identicalTo: a
]

{ #category : #test }
LImageBuilderTest >> testBigBang [
	| b m c1 c2 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b bigBang.
	self assert: e nilObject equals: 0.
	self assert: (e globalNamed: 'nil') equals: e nilObject.
	c1 := e globalNamed: 'LSymbol'.
	c2 := m objectAt: c1 dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: c2) equals: 'LSymbol'.
	c1 := e globalNamed: 'LUndefined'.
	c2 := m objectAt: c1 dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: c2) equals: 'LUndefined'.
	c2 := m classOfObjectAt: e nilObject.
	self assert: c2 equals: c1.
	c1 := e globalNamed: b objectClassName.
	c2 := e globalNamed: b metaObjectClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2.
	self assert: (m parentClassOfClassAt: c1) equals: e nilObject.
	c1 := e globalNamed: b classClassName.
	c2 := e globalNamed: b metaClassClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2.
	c1 := e globalNamed: b trueObjectName.
	c2 := e globalNamed: b trueClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2.
	c1 := e globalNamed: b falseObjectName.
	c2 := e globalNamed: b falseClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2.
	c1 := e globalNamed: b objectClassName.
	c2 := m methodsOfClassAt: c1.
	self
		assert: (m classOfObjectAt: c2)
		equals: (e globalNamed: b dictionaryClassName).
	c2 := m instanceSizeOfClassAt: c1.
	self assert: c2 equals: 0.
	c1 := e globalNamed: b classClassName.
	c2 := m instanceSizeOfClassAt: c1.
	self assert: c2 equals: 0.
	c1 := e globalNamed: b globalsObjectName.
	self assert: c1 > 0
]

{ #category : #test }
LImageBuilderTest >> testClassInstanceMethod [
	| b m cl a code dict keys vals method e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 4096.
	b bigBang.
	b setup2.
	b class: 'Test' superClass: b objectClassName variables: #(a b).
	b class: 'Test' instanceMethod: 'test1 ^ a + b'.
	cl := e globalNamed: 'Test'.
	dict := m methodsOfClassAt: cl.
	keys := m objectAt: dict dataAt: 0.
	vals := m objectAt: dict dataAt: 1.
	self assert: (m sizeOfObjectAt: keys) equals: 1.
	self assert: (m sizeOfObjectAt: vals) equals: 1.
	a := m objectAt: keys dataAt: 0.
	self assert: (m stringOfObjectAt: a) equals: 'test1'.
	method := m objectAt: vals dataAt: 0.
	a := m objectAt: method dataAt: b byteCodesInMethod.
	code := m byteArrayOfObjectAt: a.
	self
		assertCollection: code
		equals: #[16r10 16r11 16rB2 16rF2 16rF5 16rF1]
]

{ #category : #test }
LImageBuilderTest >> testClassIsInstanceOfAndSubClassOfWithVariables [
	| b m c1 c2 c3 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b bigBang.
	b
		class: 'LClass'
		isInstanceOf: 'MetaLClass'
		andSubClassOf: 'LObject'
		withVariables: #(name parentClass methods size variables).
	b
		class: 'MetaLObject'
		isInstanceOf: 'LClass'
		andSubClassOf: 'LClass'
		withVariables: #().
	b
		class: 'MetaLClass'
		isInstanceOf: 'LClass'
		andSubClassOf: 'MetaLObject'
		withVariables: #().
	c1 := e globalNamed: 'LClass'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'MetaLClass').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'LObject').
	self assert: (m instanceSizeOfClassAt: c1) equals: 5 + (m instanceSizeOfClassAt: (e globalNamed: 'LObject')).
	c1 := e globalNamed: 'MetaLObject'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'LClass').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'LClass').
	c1 := e globalNamed: 'MetaLClass'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'LClass').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'MetaLObject')
]

{ #category : #test }
LImageBuilderTest >> testClassSuperClassVariables [
	| b m c1 c2 c3 r e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b bigBang.
	b class: 'LUndefined' superClass: 'LObject' variables: #().
	b class: 'LProcess' superClass: 'LObject' variables: #(context state result).
	c1 := e globalNamed: 'LUndefined'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'MetaLUndefined').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'LObject').
	c1 := e globalNamed: 'MetaLUndefined'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'LClass').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'MetaLObject').
	c1 := e globalNamed: 'LProcess'.
	self assert: (m instanceSizeOfClassAt: c1) equals: 3.
	r := m variablesOfClassAt: c1.
	self assert: (m classOfObjectAt: r) equals: (e globalNamed: 'LArray').
	self assert: (m sizeOfObjectAt: r) equals: 3.
	c2 := m objectAt: r dataAt: 0.
	self assert: (m classOfObjectAt: c2) equals: (e globalNamed: 'LSymbol').
	self assert: (m stringOfObjectAt: c2) equals: 'context'.
	c2 := m objectAt: r dataAt: 1.
	self assert: (m classOfObjectAt: c2) equals: (e globalNamed: 'LSymbol').
	self assert: (m stringOfObjectAt: c2) equals: 'state'.
	c2 := m objectAt: r dataAt: 2.
	self assert: (m classOfObjectAt: c2) equals: (e globalNamed: 'LSymbol').
	self assert: (m stringOfObjectAt: c2) equals: 'result'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'MetaLProcess').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'LObject').
	c1 := e globalNamed: 'MetaLProcess'.
	c2 := m classOfObjectAt: c1.
	self assert: c2 equals: (e globalNamed: 'LClass').
	c3 := m parentClassOfClassAt: c1.
	self assert: c3 equals: (e globalNamed: 'MetaLObject')
]

{ #category : #test }
LImageBuilderTest >> testCompilerClass [
	self assert: self newBuilder compilerClass equals: LCompiler
]

{ #category : #test }
LImageBuilderTest >> testEnv [
	| b e |
	b := self newBuilder.
	self assert: b env class equals: LEnvironment.
	e := LEnvironment new.
	b env: e.
	self assert: b env identicalTo: e
]

{ #category : #test }
LImageBuilderTest >> testFinalizeBigBang [
	| b m c1 c2 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	b finalizeBigBang.
	c1 := e globalNamed: b objectClassName.
	c2 := m methodsOfClassAt: c1.
	self
		assert: (m classOfObjectAt: c2)
		equals: (e globalNamed: b dictionaryClassName).
	c2 := m instanceSizeOfClassAt: c1.
	self assert: c2 equals: 0.
	c1 := e globalNamed: b classClassName.
	c2 := m instanceSizeOfClassAt: c1.
	self assert: c2 equals: 0.
	c1 := e globalNamed: b globalsObjectName.
	self assert: c1 > 0
]

{ #category : #test }
LImageBuilderTest >> testGlobalValues [
	| b |
	b := self newBuilder.
	self assert: b globalValues isNil.
	b globalValues: 123.
	self assert: b globalValues equals: 123
]

{ #category : #test }
LImageBuilderTest >> testInstanceVariablesOfClassAt [
	| b cl e |
	b := self newBuilder.
	e := b env.
	b memory initialAllocate: 4096.
	b bigBang.
	b setup2.
	b class: 'Test' superClass: b objectClassName variables: #(a b c).
	b class: 'Test2' superClass: 'Test' variables: #(d e).
	b class: 'Test3' superClass: 'Test2' variables: #(f g h).
	cl := e globalNamed: 'Test'.
	self assert: (b instanceVariablesOfClassAt: cl) equals: #(a b c).
	cl := e globalNamed: 'Test2'.
	self assert: (b instanceVariablesOfClassAt: cl) equals: #(d e).
	cl := e globalNamed: 'Test3'.
	self assert: (b instanceVariablesOfClassAt: cl) equals: #(f g h)
]

{ #category : #test }
LImageBuilderTest >> testMemory [
	| b m |
	b := self newBuilder.
	self assert: (b memory isKindOf: LObjectMemory).
	m := LObjectMemory new initialAllocate: 123.
	b memory: m.
	self assert: b memory identicalTo: m
]

{ #category : #test }
LImageBuilderTest >> testNewArray [
	| b m r c e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	r := b newArray: 5.
	c := m classOfObjectAt: r.
	self assert: c equals: (e globalNamed: b arrayClassName).
	1 to: 5 do: [ :each | 
		c := m objectAt: r dataAt: each - 1.
		self assert: c equals: e nilObject ]
]

{ #category : #test }
LImageBuilderTest >> testNewByteArray [
	| b s1 s2 m e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	e addGlobal: 999 named: b byteArrayClassName.
	s1 := b newByteArray: #[10 11 12].
	s2 := b newByteArray: #[99 88].
	self assert: (m classOfObjectAt: s1) equals: 999.
	self assert: (m core at: s1 + 9) equals: 10.
	self assert: (m core at: s1 + 10) equals: 11.
	self assert: (m core at: s1 + 11) equals: 12.
	self assert: (m classOfObjectAt: s2) equals: 999.
	self assert: (m core at: s2 + 9) equals: 99.
	self assert: (m core at: s2 + 10) equals: 88
]

{ #category : #test }
LImageBuilderTest >> testNewCharacter [
	| b s1 s2 m e |
	b := self newBuilder.
	e := b env.
	b setupNilObject.
	m := b memory.
	e addGlobal: 999 named: #LChar.
	s1 := b newCharacter: $x.
	s2 := b newCharacter: $1.
	self assert: (m classOfObjectAt: s1) equals: 999.
	self assert: (m objectAt: s1 dataAt: 0) equals: (m newSmallInteger: $x asciiValue).
	self assert: (m classOfObjectAt: s2) equals: 999.
	self assert: (m objectAt: s2 dataAt: 0) equals: (m newSmallInteger: $1 asciiValue)
]

{ #category : #test }
LImageBuilderTest >> testNewClassNamedAdding [
	| b c1 c2 s1 s2 m e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	e addGlobal: 999 named: #LSymbol.
	c1 := b newClassNamed: 'abc' adding: 0.
	c2 := b newClassNamed: 'defg' adding: 0.
	self assert: (e includesSymbol: #abc).
	self assert: (e includesSymbol: #defg).
	s1 := m objectAt: c1 dataAt: m nameInClass.
	s2 := m objectAt: c2 dataAt: m nameInClass.
	self assert: (m core at: s1 + 9) equals: $a asciiValue.
	self assert: (m core at: s1 + 10) equals: $b asciiValue.
	self assert: (m core at: s1 + 11) equals: $c asciiValue.
	self assert: (m core at: s2 + 9) equals: $d asciiValue.
	self assert: (m core at: s2 + 10) equals: $e asciiValue.
	self assert: (m core at: s2 + 11) equals: $f asciiValue.
	self assert: (m core at: s2 + 12) equals: $g asciiValue
]

{ #category : #test }
LImageBuilderTest >> testNewDictionary [
	| b m r c e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	r := b newDictionary.
	c := m classOfObjectAt: r.
	self assert: c equals: (e globalNamed: b dictionaryClassName).
	c := m objectAt: r dataAt: 0.
	self
		assert: (m classOfObjectAt: c)
		equals: (e globalNamed: b orderedArrayClassName).
	c := m objectAt: r dataAt: 1.
	self
		assert: (m classOfObjectAt: c)
		equals: (e globalNamed: b arrayClassName)
]

{ #category : #test }
LImageBuilderTest >> testNewLiteral [
	| b s1 s2 s3 s4 m e |
	b := self newBuilder.
	e := b env.
	b setupNilObject.
	m := b memory.
	e addGlobal: 10 named: #LSymbol.
	e addGlobal: 20 named: #LString.
	e addGlobal: 30 named: #LChar.
	s1 := b newLiteral: 'abc'.
	s2 := b newLiteral: #defg.
	s3 := b newLiteral: $X.
	s4 := b newLiteral: 123.
	self assert: (m classOfObjectAt: s1) equals: 20.
	self assert: (m stringOfObjectAt: s1) equals: 'abc'.
	self assert: (m classOfObjectAt: s2) equals: 10.
	self assert: (m stringOfObjectAt: s2) equals: 'defg'.
	self assert: (m classOfObjectAt: s3) equals: 30.
	self assert: (m objectAt: s3 dataAt: 0) equals: (m newSmallInteger: $X asciiValue).
	self assert: (m isSmallInteger: s4).
	self assert: (m smallIntegerValue: s4) equals: 123
]

{ #category : #test }
LImageBuilderTest >> testNewLiteralArray [
	| b m a r e |
	b := self newBuilder.
	e := b env.
	b setupNilObject.
	m := b memory.
	e addGlobal: 10 named: #LSymbol.
	e addGlobal: 20 named: #LString.
	e addGlobal: 30 named: #LChar.
	e addGlobal: 40 named: #LArray.
	a := b newLiteralArray: {'abc' . #defg . $X . 123}.
	self assert: (m classOfObjectAt: a) equals: 40.
	r := m objectAt: a dataAt: 0.
	self assert: (m classOfObjectAt: r) equals: 20.
	self assert: (m stringOfObjectAt: r) equals: 'abc'.
	r := m objectAt: a dataAt: 1.
	self assert: (m classOfObjectAt: r) equals: 10.
	self assert: (m stringOfObjectAt: r) equals: 'defg'.
	r := m objectAt: a dataAt: 2.
	self assert: (m classOfObjectAt: r) equals: 30.
	self assert: (m objectAt: r dataAt: 0) equals: (m newSmallInteger: $X asciiValue).
	r := m objectAt: a dataAt: 3.
	self assert: (m isSmallInteger: r).
	self assert: (m smallIntegerValue: r) equals: 123
]

{ #category : #test }
LImageBuilderTest >> testNewMethod [
	| b m r c e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	b addClassNamed: b methodClassName.
	r := b newMethod.
	c := m classOfObjectAt: r.
	self assert: c equals: (e globalNamed: b methodClassName)
]

{ #category : #test }
LImageBuilderTest >> testNewOrderedArray [
	| b m r c e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	m initialAllocate: 32768.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	r := b newOrderedArray.
	c := m classOfObjectAt: r.
	self assert: c equals: (e globalNamed: b orderedArrayClassName)
]

{ #category : #test }
LImageBuilderTest >> testNewString [
	| b s1 s2 m e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	e addGlobal: 999 named: #LString.
	s1 := b newString: 'abc'.
	s2 := b newString: 'defg'.
	self assert: (m classOfObjectAt: s1) equals: 999.
	self assert: (m core at: s1 + 9) equals: $a asciiValue.
	self assert: (m core at: s1 + 10) equals: $b asciiValue.
	self assert: (m core at: s1 + 11) equals: $c asciiValue.
	self assert: s2 equals: s1 + 16.
	self assert: (m classOfObjectAt: s2) equals: 999.
	self assert: (m core at: s2 + 9) equals: $d asciiValue.
	self assert: (m core at: s2 + 10) equals: $e asciiValue.
	self assert: (m core at: s2 + 11) equals: $f asciiValue.
	self assert: (m core at: s2 + 12) equals: $g asciiValue
]

{ #category : #test }
LImageBuilderTest >> testNewSymbol [
	| b s1 s2 s3 m e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	e addGlobal: 999 named: #LSymbol.
	s1 := b newSymbol: 'abc'.
	s2 := b newSymbol: 'defg'.
	self assert: (m core at: s1 + 9) equals: $a asciiValue.
	self assert: (m core at: s1 + 10) equals: $b asciiValue.
	self assert: (m core at: s1 + 11) equals: $c asciiValue.
	self assert: s2 equals: s1 + 16.
	s3 := b newSymbol: 'hi'.
	self assert: s3 equals: s2 + 16.
	self assert: (b newSymbol: 'abc') equals: s1.
	self assert: (b newSymbol: 'defg') equals: s2.
	self assert: (m core at: s1 + 9) equals: $a asciiValue.
	self assert: (m core at: s1 + 10) equals: $b asciiValue.
	self assert: (m core at: s1 + 11) equals: $c asciiValue.
	self assert: (m core at: s2 + 9) equals: $d asciiValue.
	self assert: (m core at: s2 + 10) equals: $e asciiValue.
	self assert: (m core at: s2 + 11) equals: $f asciiValue.
	self assert: (m core at: s2 + 12) equals: $g asciiValue
]

{ #category : #test }
LImageBuilderTest >> testObjectAtClassNamed [
	| b c1 c2 e |
	b := self newBuilder.
	e := b env.
	e addGlobal: 123 named: 'Test1'.
	e addGlobal: 456 named: 'Test2'.
	c1 := b gcAlloc: 0.
	c2 := b gcAlloc: 0.
	b objectAt: c1 classNamed: 'Test2'.
	b objectAt: c2 classNamed: 'Test1'.
	self assert: (b memory classOfObjectAt: c1) equals: 456.
	self assert: (b memory classOfObjectAt: c2) equals: 123
]

{ #category : #test }
LImageBuilderTest >> testOptions [
	| b s |
	b := self newBuilder.
	self assert: b options class equals: Set.
	self assert: b options isEmpty.
	s := Set new.
	b options: s.
	self assert: b options identicalTo: s
]

{ #category : #test }
LImageBuilderTest >> testSetupMetaClass [
	| b m c1 c2 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	c1 := e globalNamed: b classClassName.
	c2 := e globalNamed: b metaClassClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2
]

{ #category : #test }
LImageBuilderTest >> testSetupMiscClasses [
	| b m c1 c2 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	b setupNilObject.
	b setupObjectClass.
	b setupMetaClass.
	b setupMiscClasses.
	c1 := e globalNamed: b trueObjectName.
	c2 := e globalNamed: b trueClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2.
	c1 := e globalNamed: b falseObjectName.
	c2 := e globalNamed: b falseClassName.
	self assert: c1 > 0.
	self assert: c2 > 0.
	self assert: (m classOfObjectAt: c1) equals: c2
]

{ #category : #test }
LImageBuilderTest >> testSetupNilObject [
	| b m r1 r2 e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	b setupNilObject.
	self assert: e nilObject equals: 0.
	self assert: (e globalNamed: 'nil') equals: e nilObject.
	r1 := e globalNamed: 'LSymbol'.
	r2 := m objectAt: r1 dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: r2) equals: 'LSymbol'.
	r1 := e globalNamed: 'LUndefined'.
	r2 := m objectAt: r1 dataAt: m nameInClass.
	self assert: (m stringOfObjectAt: r2) equals: 'LUndefined'.
	r2 := m classOfObjectAt: e nilObject.
	self assert: r2 equals: r1
]

{ #category : #test }
LImageBuilderTest >> testSetupObjectClass [
	| b m c mc e |
	b := self newBuilder.
	e := b env.
	m := b memory.
	b setupNilObject.
	b setupObjectClass.
	c := e globalNamed: b objectClassName.
	mc := e globalNamed: b metaObjectClassName.
	self assert: c > 0.
	self assert: mc > 0.
	self assert: (m classOfObjectAt: c) equals: mc.
	self assert: (m parentClassOfClassAt: c) equals: e nilObject
]
