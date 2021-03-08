Class {
	#name : #LImageBuilder,
	#superclass : #Object,
	#traits : 'TLNames + TLProcessSize + TLMethodSize',
	#classTraits : 'TLNames classTrait + TLProcessSize classTrait + TLMethodSize classTrait',
	#instVars : [
		'memory',
		'globalValues',
		'allocator',
		'env',
		'options',
		'classNames'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #private }
LImageBuilder class >> buildFromClassTree [
	| m1 a1 s r |
	m1 := LObjectMemory new.
	a1 := LBuildingAllocator new.
	a1 memory: m1.
	a1 allocateMemory: 65536 * 4.
	s := self new.
	s classNames: LClassNames new.
	s memory: m1.
	s allocator: a1.
	s bigBang.
	s excludeSources: true.
	r := LSourceGenerator new.
	r builder: s.
	r generateObject: LObject class: LClass.
	r generateAllClassesFrom: LObject.
	r generateAllMethodsFrom: LObject.
	s addBootMethod: 'nil main'.
	s setupSymbolsAndGlobals.
	^ s
]

{ #category : #private }
LImageBuilder class >> buildFromImageSource [
	| m1 a1 s r |
	m1 := LObjectMemory new.
	a1 := LBuildingAllocator new.
	a1 memory: m1.
	a1 allocateMemory: 65536 * 4.
	s := self new.
	s classNames: LClassNames new.
	s memory: m1.
	s allocator: a1.
	s bigBang.
	r := LSourceReader new.
	r builder: s.
	r readSourceFileNamed: 'imageSource.txt'.
	s setupSymbolsAndGlobals.
	^ s
]

{ #category : #examples }
LImageBuilder class >> example1 [
	| s |
	s := self buildFromImageSource.
	s writeImageFileNamed: 'test1.image'
]

{ #category : #examples }
LImageBuilder class >> example2 [
	| m2 a2 s s2 r w |
	s := self buildFromImageSource.
	w := LImageWriter new.
	w memory: s memory.
	w stream: (WriteStream on: ByteArray new).
	s imageOutTo: w.
	w stream contents.
	m2 := LObjectMemory new.
	a2 := LStaticAllocator new.
	a2 memory: m2.
	a2 allocateMemory: 65536 * 16.
	r := LImageReader new.
	r memory: m2.
	r allocator: a2.
	r stream: (ReadStream on: w stream contents).
	s2 := self new.
	s2 classNames: s classNames.
	s2 memory: m2.
	s2 allocator: a2.
	s2 imageInFrom: r.
	^ s2
]

{ #category : #examples }
LImageBuilder class >> example3 [
	| s arr a i io p |
	s := self example2.
	s env bootMethod.	"139208"
	arr := s createInitialProcess.
	a := s allocator asDynamicAllocator.
	a
		gc:
			(LGarbageCollector new
				allocator: a;
				yourself).
	io := LIOSystem new.
	i := LInterpreter new.
	i classNames: s classNames.
	i allocator: a.
	i memory: s memory.
	i env: s env.
	i ioSystem: io.
	p := i createInitialContextFrom: arr.
	i startProcess: p.
	i logger: LFullLogger new.
	29 timesRepeat: [ i doOneCycle ].
	51 * 257 timesRepeat: [ i doOneCycle ].
	282 timesRepeat: [ i doOneCycle ].
	29 + (51 * 257) + 282.
	"13418"
	i pc.
	i doOneCycle.
	7835 timesRepeat: [ i doOneCycle ].
	5000 timesRepeat: [ i doOneCycle ].
	5000 timesRepeat: [ i doOneCycle ].
	5000 timesRepeat: [ i doOneCycle ].
	5000 timesRepeat: [ i doOneCycle ].
	1897 timesRepeat: [ i doOneCycle ].
	800 timesRepeat: [ i doOneCycle ].
	30 timesRepeat: [ i doOneCycle ].
	i logger saveLogFileNamed: 'log1.txt'
]

{ #category : #examples }
LImageBuilder class >> example4 [
	| s arr a i io p gc |
	s := self example2.
	s env bootMethod.	"139208"
	arr := s createInitialProcess.
	a := s allocator asDynamicAllocator.
	gc := LCopyingGC new.
	a gc: gc.
	gc allocator: a.
	gc setupSpaces.
	io := LIOSystem new.
	i := LInterpreter new.
	i classNames: s classNames.
	i inspect.
	i allocator: a.
	i memory: s memory.
	i env: s env.
	i ioSystem: io.
	p := i createInitialContextFrom: arr.
	i startProcess: p.
	i logger: LFullLogger new.
	[ i doOneCycle = 0 ] whileTrue
]

{ #category : #examples }
LImageBuilder class >> example5 [
	| s w |
	s := self buildFromClassTree.
	w := LImageWriter new.
	w memory: s memory.
	w stream: (WriteStream on: ByteArray new).
	s imageOutTo: w.
	^ w stream contents
]

{ #category : #examples }
LImageBuilder class >> example6 [
	| image s arr a i io p gc r |
	image := self example5.
	a := LStaticAllocator new.
	a memory: LObjectMemory new.
	a allocateMemory: 65536 * 16.
	r := LImageReader new.
	r memory: a memory.
	r allocator: a.
	r stream: (ReadStream on: image).
	s := self new.
	s classNames: LClassNames new.
	s memory: a memory.
	s allocator: a.
	s imageInFrom: r.
	arr := s createInitialProcess.
	a := s allocator asDynamicAllocator.
	gc := LCopyingGC new.
	a gc: gc.
	gc allocator: a.
	gc setupSpaces.
	io := LIOSystem new.
	i := LInterpreter new.
	i classNames: LClassNames new.
	i inspect.
	i allocator: a.
	i memory: s memory.
	i env: s env.
	i ioSystem: io.
	p := i createInitialContextFrom: arr.
	i startProcess: p.
	i logger: LFullLogger new.
	[ i doOneCycle = 0 ] whileTrue
]

{ #category : #examples }
LImageBuilder class >> example7 [
	| s |
	s := self buildFromClassTree.
	s writeImageFileNamed: 'test2.image'
]

{ #category : #api }
LImageBuilder >> addBootMethod: aString [
	| obj |
	obj := self createBootMethod: aString.
	env bootMethod: obj
]

{ #category : #api }
LImageBuilder >> addClassNamed: aString [
	^ self addClassNamed: aString adding: 0
]

{ #category : #api }
LImageBuilder >> addClassNamed: aString adding: anInteger [
	| addr |
	addr := self newClassNamed: aString adding: anInteger.
	env addGlobal: addr named: aString.
	^ addr
]

{ #category : #private }
LImageBuilder >> allInstanceVariablesOfClassAt: anInteger [
	| parentClass |
	parentClass := memory parentClassOfClassAt: anInteger.
	parentClass = env nilObject
		ifTrue: [ ^ self instanceVariablesOfClassAt: anInteger ].
	^ (self allInstanceVariablesOfClassAt: parentClass)
		, (self instanceVariablesOfClassAt: anInteger)
]

{ #category : #accessing }
LImageBuilder >> allocator [
	^ allocator
]

{ #category : #accessing }
LImageBuilder >> allocator: anObject [
	allocator := anObject
]

{ #category : #api }
LImageBuilder >> bigBang [
	self
		setupNilObject;
		setupObjectClass;
		setupMetaClass;
		setupMiscClasses;
		finalizeBigBang
]

{ #category : #private }
LImageBuilder >> checkGlobals [
	| o cl |
	env globalKeys
		do: [ :each | 
			o := env globalNamed: each.
			cl := memory classOfObjectAt: o.
			cl = env nilObject
				ifTrue: [ self error: 'Never defined' ] ]
]

{ #category : #api }
LImageBuilder >> class: aString instanceMethod: aString2 [
	| compiler a r method cl |
	cl := env globalNamed: aString.
	compiler := self compilerClass new.
	r := compiler
		source: aString2;
		globals: env globals;
		instanceVariables: (self allInstanceVariablesOfClassAt: cl);
		compile.
	method := self newMethod.
	a := self newLiteralArray: r second.
	memory objectAt: method dataAt: self literalsInMethod put: a.
	a := self newByteArray: r third.
	memory objectAt: method dataAt: self byteCodesInMethod put: a.
	a := memory newSmallInteger: r fourth.
	memory objectAt: method dataAt: self stackSizeInMethod put: a.
	a := memory newSmallInteger: r fifth.
	memory objectAt: method dataAt: self temporarySizeInMethod put: a.
	memory objectAt: method dataAt: self classInMethod put: cl.
	a := self excludeSources
		ifTrue: [ 0 ]
		ifFalse: [ self newString: aString2 ].
	memory objectAt: method dataAt: self textInMethod put: a.
	a := self newSymbol: r first.
	memory objectAt: method dataAt: self nameInMethod put: a.
	allocator
		dictionary: (memory methodsOfClassAt: cl)
		insertAt: a
		put: method
]

{ #category : #api }
LImageBuilder >> class: aString isInstanceOf: aString2 andSubClassOf: aString3 withVariables: anArray [
	| nClass supClass instSize |
	nClass := env
		globalNamed: aString
		ifAbsent: [ self addClassNamed: aString ].
	self objectAt: nClass classNamed: aString2.
	supClass := env globalNamed: aString3.
	memory classAt: nClass parentClass: supClass.
	instSize := anArray size.
	supClass = env nilObject
		ifFalse: [ instSize := instSize + (memory instanceSizeOfClassAt: supClass) ].
	memory classAt: nClass instanceSize: instSize.
	memory classAt: nClass variables: (self newLiteralArray: anArray).
	memory classAt: nClass methods: self newDictionary
]

{ #category : #api }
LImageBuilder >> class: aString superClass: aString2 variables: anArray [
	self
		class: self metaName , aString
		isInstanceOf: classNames classClassName
		andSubClassOf: self metaName , aString2
		withVariables: #().
	self
		class: aString
		isInstanceOf: self metaName , aString
		andSubClassOf: aString2
		withVariables: anArray
]

{ #category : #accessing }
LImageBuilder >> classNames [
	^ classNames
]

{ #category : #accessing }
LImageBuilder >> classNames: anObject [
	classNames := anObject
]

{ #category : #private }
LImageBuilder >> compilerClass [
	^ LCompiler
]

{ #category : #private }
LImageBuilder >> createBootMethod: aString [
	| compiler a r method |
	compiler := self compilerClass new.
	r := compiler
		source: aString;
		globals: env globals;
		instanceVariables: #();
		compileExpression.
	method := self newMethod.
	a := self newLiteralArray: r second.
	memory objectAt: method dataAt: self literalsInMethod put: a.
	a := self newByteArray: r third.
	memory objectAt: method dataAt: self byteCodesInMethod put: a.
	a := memory newSmallInteger: r fourth.
	memory objectAt: method dataAt: self stackSizeInMethod put: a.
	a := self newString: self startUpMethodName.
	memory objectAt: method dataAt: self nameInMethod put: a.
	^ method
]

{ #category : #api }
LImageBuilder >> createInitialProcess [
	| process size initialStack initialTempraries |
	process := allocator staticAlloc: 3.
	size := memory objectAt: env bootMethod dataAt: self stackSizeInMethod.
	size := memory smallIntegerValue: size.
	initialStack := allocator staticAlloc: size.
	initialTempraries := allocator staticAlloc: 19.
	^ {process.
	initialStack.
	initialTempraries}
]

{ #category : #accessing }
LImageBuilder >> env [
	^ env
]

{ #category : #accessing }
LImageBuilder >> env: anObject [
	env := anObject
]

{ #category : #api }
LImageBuilder >> excludeSources [
	^ options includes: #excludeSources
]

{ #category : #api }
LImageBuilder >> excludeSources: aBoolean [
	aBoolean
		ifTrue: [ options add: #excludeSources ]
		ifFalse: [ options remove: #excludeSources ifAbsent: [  ] ]
]

{ #category : #private }
LImageBuilder >> finalizeBigBang [
	| objectClass classClass |
	objectClass := env globalNamed: classNames objectClassName.
	memory classAt: objectClass methods: self newDictionary.
	memory classAt: objectClass instanceSize: 0.
	classClass := env globalNamed: classNames classClassName.
	memory classAt: classClass instanceSize: 0.
	globalValues := self gcAlloc: 2.
	env addGlobal: globalValues named: self globalsObjectName
]

{ #category : #private }
LImageBuilder >> fixGlobales [
	| t v o |
	t := globalValues.
	self objectAt: t classNamed: classNames dictionaryClassName.
	memory
		objectAt: t
		dataAt: memory keysInDictionary
		put: self newOrderedArray.
	memory
		objectAt: t
		dataAt: memory valuesInDictionary
		put: (self newArray: 0).
	env globalKeys
		do: [ :each | 
			(each beginsWith: 'Meta')
				ifFalse: [ v := self newSymbol: each.
					o := env globalNamed: each.
					allocator dictionary: t insertAt: v put: o ] ].
	"v := self newSymbol: self smalltalkName.
	allocator dictionary: t insertAt: v put: t"
]

{ #category : #private }
LImageBuilder >> fixSymbols [
	| t v n a |
	t := self newTree.
	env symbolValues
		do: [ :each | 
			n := self newNode: each left: env nilObject right: env nilObject.
			a := memory objectAt: t dataAt: memory rootInTree.
			v := self symbolTree: a insert: n.
			memory objectAt: t dataAt: memory rootInTree put: v ].
	^ t
]

{ #category : #private }
LImageBuilder >> gcAlloc: anInteger [
	| obj |
	obj := allocator gcAlloc: anInteger.
	0 to: anInteger - 1 do: [ :each | memory objectAt: obj dataAt: each put: env nilObject ].
	^ obj
]

{ #category : #accessing }
LImageBuilder >> globalValues [
	^ globalValues
]

{ #category : #accessing }
LImageBuilder >> globalValues: anObject [
	globalValues := anObject
]

{ #category : #'image manipulation' }
LImageBuilder >> imageInFrom: aReader [
	env nilObject: aReader objectRead.
	env addGlobal: env nilObject named: self nilObjectName.
	env trueObject: aReader objectRead.
	env addGlobal: env trueObject named: self trueObjectName.
	env falseObject: aReader objectRead.
	env addGlobal: env falseObject named: self falseObjectName.
	globalValues := aReader objectRead.
	env addGlobal: aReader objectRead named: classNames smallIntegerClassName.
	env addGlobal: aReader objectRead named: classNames integerClassName.
	env addGlobal: aReader objectRead named: classNames arrayClassName.
	env addGlobal: aReader objectRead named: classNames blockClassName.
	env addGlobal: aReader objectRead named: classNames contextClassName.
	env bootMethod: aReader objectRead.
	env addSymbol: aReader objectRead named: #<.
	env addSymbol: aReader objectRead named: #<=.
	env addSymbol: aReader objectRead named: #+.
	env addSymbol: aReader objectRead named: #doesNotUnderstand:
]

{ #category : #'image manipulation' }
LImageBuilder >> imageOutTo: aWriter [
	aWriter imageOut: env nilObject.
	aWriter imageOut: (env globalNamed: self trueObjectName).
	aWriter imageOut: (env globalNamed: self falseObjectName).
	aWriter imageOut: globalValues.
	aWriter imageOut: (env globalNamed: classNames smallIntegerClassName).
	aWriter imageOut: (env globalNamed: classNames integerClassName).
	aWriter imageOut: (env globalNamed: classNames arrayClassName).
	aWriter imageOut: (env globalNamed: classNames blockClassName).
	aWriter imageOut: (env globalNamed: classNames contextClassName).
	aWriter imageOut: env bootMethod.
	aWriter imageOut: (self newSymbol: #<).
	aWriter imageOut: (self newSymbol: #<=).
	aWriter imageOut: (self newSymbol: #+).
	aWriter imageOut: (self newSymbol: #doesNotUnderstand:)
]

{ #category : #initialization }
LImageBuilder >> initialize [
	env := LEnvironment new.
	options := Set new
]

{ #category : #private }
LImageBuilder >> instanceVariablesOfClassAt: anInteger [
	| v size s |
	v := memory variablesOfClassAt: anInteger.
	size := memory sizeOfObjectAt: v.
	^ (0 to: size - 1)
		collect: [ :each | 
			s := memory objectAt: v dataAt: each.
			memory stringOfObjectAt: s ]
]

{ #category : #accessing }
LImageBuilder >> memory [
	^ memory
]

{ #category : #accessing }
LImageBuilder >> memory: anObject [
	memory := anObject
]

{ #category : #'instance creation' }
LImageBuilder >> newArray: anInteger [
	| obj |
	obj := self gcAlloc: anInteger.
	self objectAt: obj classNamed: classNames arrayClassName.
	1 to: anInteger do:
		[ :each | memory objectAt: obj dataAt: each - 1 put: env nilObject ].
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newByteArray: anArray [
	| obj |
	obj := allocator newByteArray: anArray.
	self objectAt: obj classNamed: classNames byteArrayClassName.
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newCharacter: aCharacter [
	| obj |
	obj := self gcAlloc: 1.
	self objectAt: obj classNamed: classNames characterClassName.
	memory objectAt: obj dataAt: 0 put: (memory newSmallInteger: aCharacter asciiValue).
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newClassNamed: aString adding: anInteger [
	| sym |
	sym := self newSymbol: aString.
	^ allocator newClass: sym adding: anInteger
]

{ #category : #'instance creation' }
LImageBuilder >> newDictionary [
	| obj |
	obj := self gcAlloc: 2.
	self objectAt: obj classNamed: classNames dictionaryClassName.
	memory
		objectAt: obj
		dataAt: memory keysInDictionary
		put: self newOrderedArray.
	memory
		objectAt: obj
		dataAt: memory valuesInDictionary
		put: (self newArray: 0).
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newLiteral: anObject [
	anObject isSymbol
		ifTrue: [ (env includesGlobal: anObject)
				ifTrue: [ ^ env globalNamed: anObject ].
			^ self newSymbol: anObject ].
	anObject isString
		ifTrue: [ ^ self newString: anObject ].
	anObject isNumber
		ifTrue: [ ^ memory newSmallInteger: anObject asInteger ].
	anObject isCharacter
		ifTrue: [ ^ self newCharacter: anObject ].
	self error: 'not literal'
]

{ #category : #'instance creation' }
LImageBuilder >> newLiteralArray: anArray [
	| obj |
	anArray isEmpty
		ifTrue: [ ^ env nilObject ].
	obj := self gcAlloc: anArray size.
	self objectAt: obj classNamed: classNames arrayClassName.
	anArray
		withIndexDo:
			[ :each :index | memory objectAt: obj dataAt: index - 1 put: (self newLiteral: each) ].
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newMethod [
	| obj |
	obj := self gcAlloc: self methodSize.
	self objectAt: obj classNamed: classNames methodClassName.
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newNode: v left: l right: r [
	| obj |
	obj := self gcAlloc: 3.
	self objectAt: obj classNamed: classNames nodeClassName.
	memory objectAt: obj dataAt: memory valueInNode put: v.
	memory objectAt: obj dataAt: memory leftInNode put: l.
	memory objectAt: obj dataAt: memory rightInNode put: r.
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newOrderedArray [
	| obj |
	obj := self gcAlloc: 0.
	self objectAt: obj classNamed: classNames orderedArrayClassName.
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newString: aString [
	| obj |
	obj := allocator newString: aString.
	self objectAt: obj classNamed: classNames stringClassName.
	^ obj
]

{ #category : #'instance creation' }
LImageBuilder >> newSymbol: aString [
	| addr cl |
	(env includesSymbol: aString)
		ifTrue: [ ^ env symbolNamed: aString ].
	addr := allocator newString: aString.
	cl := env
		globalNamed: classNames symbolClassName
		ifAbsent: [ env nilObject ].
	memory objectAt: addr class: cl.
	env addSymbol: addr named: aString.
	^ addr
]

{ #category : #'instance creation' }
LImageBuilder >> newTree [
	| obj |
	obj := self gcAlloc: 1.
	self objectAt: obj classNamed: classNames treeClassName.
	^ obj
]

{ #category : #api }
LImageBuilder >> objectAt: anInteger classNamed: aString [
	| cl |
	cl := env globalNamed: aString.
	^ memory objectAt: anInteger class: cl
]

{ #category : #accessing }
LImageBuilder >> options [
	^ options
]

{ #category : #accessing }
LImageBuilder >> options: anObject [
	options := anObject
]

{ #category : #api }
LImageBuilder >> setup2 [
	self
		class: classNames classClassName
		isInstanceOf: classNames metaClassClassName
		andSubClassOf: classNames objectClassName
		withVariables: #(name parentClass methods size variables).
	self
		class: classNames metaObjectClassName
		isInstanceOf: classNames classClassName
		andSubClassOf: classNames classClassName
		withVariables: #().
	self
		class: classNames metaClassClassName
		isInstanceOf: classNames classClassName
		andSubClassOf: classNames metaObjectClassName
		withVariables: #().
	self
		class: classNames methodClassName
		superClass: classNames objectClassName
		variables: #(name byteCodes literals stackSize temporarySize class text)
]

{ #category : #private }
LImageBuilder >> setupMetaClass [
	| classClass metaClassClass |
	classClass := self addClassNamed: classNames classClassName.
	metaClassClass := self addClassNamed: classNames metaClassClassName.
	memory objectAt: classClass class: metaClassClass
]

{ #category : #private }
LImageBuilder >> setupMiscClasses [
	| trueClass falseClass trueObject falseObject |
	self addClassNamed: classNames blockClassName.
	self addClassNamed: classNames characterClassName adding: 1.
	self addClassNamed: classNames smallIntegerClassName adding: 1.
	self addClassNamed: classNames integerClassName.
	trueClass := self addClassNamed: classNames trueClassName.
	trueObject := self gcAlloc: 0.
	memory objectAt: trueObject class: trueClass.
	env addGlobal: trueObject named: self trueObjectName.
	falseClass := self addClassNamed: classNames falseClassName.
	falseObject := self gcAlloc: 0.
	memory objectAt: falseObject class: falseClass.
	env addGlobal: falseObject named: self falseObjectName.
	self addClassNamed: classNames arrayClassName.
	self addClassNamed: classNames byteArrayClassName.
	self addClassNamed: classNames orderedArrayClassName.
	self addClassNamed: classNames stringClassName.
	self addClassNamed: classNames treeClassName.
	self addClassNamed: classNames dictionaryClassName
]

{ #category : #private }
LImageBuilder >> setupNilObject [
	| symbolClass undefinedClass s |
	env nilObject: (self gcAlloc: 0).
	symbolClass := self gcAlloc: memory classSize + 1.
	env addGlobal: symbolClass named: classNames symbolClassName.
	s := self newSymbol: classNames symbolClassName.
	memory classAt: symbolClass name: s.
	undefinedClass := self addClassNamed: classNames undefinedClassName.
	memory objectAt: env nilObject class: undefinedClass.
	env addGlobal: env nilObject named: 'nil'
]

{ #category : #private }
LImageBuilder >> setupObjectClass [
	| objectClass metaObjectClass |
	objectClass := self addClassNamed: classNames objectClassName.
	metaObjectClass := self addClassNamed: classNames metaObjectClassName.
	memory objectAt: objectClass class: metaObjectClass.
	memory classAt: objectClass parentClass: env nilObject
]

{ #category : #private }
LImageBuilder >> setupSymbolsAndGlobals [
	| v cl |
	v := self fixSymbols.
	cl := env globalNamed: classNames symbolClassName.
	memory objectAt: cl dataAt: memory symbolsInSymbol put: v.
	self fixGlobales.
	self checkGlobals
]

{ #category : #private }
LImageBuilder >> symbolTree: base insert: symNode [
	| s1 s2 v |
	base = env nilObject
		ifTrue: [ ^ symNode ].
	s1 := memory objectAt: symNode dataAt: memory valueInNode.
	s2 := memory objectAt: base dataAt: memory valueInNode.
	(memory compareString: s1 with: s2) < 0
		ifTrue: [ v := self
				symbolTree: (memory objectAt: base dataAt: memory leftInNode)
				insert: symNode.
			memory objectAt: base dataAt: memory leftInNode put: v ]
		ifFalse: [ v := self
				symbolTree: (memory objectAt: base dataAt: memory rightInNode)
				insert: symNode.
			memory objectAt: base dataAt: memory rightInNode put: v ].
	^ base
]

{ #category : #'image manipulation' }
LImageBuilder >> writeImageFileNamed: aString [
	| w fr |
	w := LImageWriter new
		memory: memory;
		stream: (WriteStream on: ByteArray new).
	self imageOutTo: w.
	fr := FileSystem workingDirectory / aString.
	fr isFile
		ifTrue: [ fr delete ].
	fr binaryWriteStreamDo: [ :st | st nextPutAll: w stream contents ]
]
