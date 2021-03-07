Class {
	#name : #LInterpreter,
	#superclass : #Object,
	#traits : 'TLProcessSize + TLMethodSize + TLInstructions + TLNames + TLBlockSize + TLClassSize + TLReturnCode',
	#classTraits : 'TLProcessSize classTrait + TLMethodSize classTrait + TLInstructions classTrait + TLNames classTrait + TLBlockSize classTrait + TLClassSize classTrait + TLReturnCode classTrait',
	#instVars : [
		'pc',
		'memory',
		'allocator',
		'dispatchTable',
		'messageSelector',
		'primitiveDispatchTable',
		'ioSystem',
		'env',
		'cache',
		'returnedValue',
		'specialDispatchTable',
		'ticks',
		'exitBlock',
		'logger'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #examples }
LInterpreter class >> example1 [
	| s a arr i io p |
	Transcript clear.
	s := LImageBuilder example2.
	s env bootMethod.	"139208"
	arr := s createInitialProcess.
	a := s allocator asDynamicAllocator.
	io := LIOSystem new.
	i := LInterpreter new.
	i allocator: a.
	i memory: s memory.
	i env: s env.
	i ioSystem: io.
	p := i createInitialContextFrom: arr.
	i startProcess: p.
	29 timesRepeat: [ i doOneCycle ].
	51 * 257 timesRepeat: [ i doOneCycle ].
	282 timesRepeat: [ i doOneCycle ].
	i gc.
	i pc.
	i doOneCycle.
	^ i
]

{ #category : #accessing }
LInterpreter >> allocator [
	^ allocator
]

{ #category : #accessing }
LInterpreter >> allocator: anObject [
	allocator := anObject.
	allocator
		whenCompleted: [ :gc | 
			gc checkMemory.
			gc clearOldSpace.
			self checkGlobals: gc.
			cache flush ]
]

{ #category : #'dispatch primitives' }
LInterpreter >> arrayAt [
	| low |
	low := (memory smallIntegerValue: pc popStack) - 1.
	returnedValue := pc popStack.
	(low < 0 or: [ low >= (memory sizeOfObjectAt: returnedValue) ])
		ifTrue: [ ^ self failPrimitive ].
	returnedValue := memory objectAt: returnedValue dataAt: low.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> arrayAtPut [
	| op low size tmp obj |
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ pc popStack.
			pc popStack.
			^ self failPrimitive ].
	low := (memory smallIntegerValue: op) - 1.
	returnedValue := pc popStack.
	size := memory sizeOfObjectAt: returnedValue.
	(low < 0 or: [ low >= size ])
		ifTrue: [ pc popStack.
			^ self failPrimitive ].
	tmp := pc popStack.
	memory objectAt: returnedValue dataAt: low put: tmp.
	((allocator isDynamicMemory: returnedValue) not
		and: [ allocator isDynamicMemory: tmp ])
		ifTrue: [ obj := memory addressOfObjectAt: returnedValue dataAt: low.
			allocator addStaticRoot: obj ].
	self doReturn
]

{ #category : #dispatching }
LInterpreter >> assignInstance: anInteger [
	| obj |
	pc assureArguments.
	pc assureInstanceVariables.
	memory
		objectAt: pc instanceVariables
		dataAt: anInteger
		put: pc topOfStack.
	((allocator isDynamicMemory: pc instanceVariables) not
		and: [ allocator isDynamicMemory: pc topOfStack ])
		ifTrue: [ obj := memory addressOfObjectAt: pc instanceVariables dataAt: anInteger.
			allocator addStaticRoot: obj ]
]

{ #category : #dispatching }
LInterpreter >> assignTemporary: anInteger [
	pc assignTemporary: anInteger
]

{ #category : #private }
LInterpreter >> binaryMessageAt: anInteger [
	^ env symbolNamed: (#(< <= +) at: anInteger + 1)
]

{ #category : #'dispatch primitives' }
LInterpreter >> bitAnd [
	| op high |
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ pc popStack.
			^ self failPrimitive ].
	high := memory smallIntegerValue: op.
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := (memory smallIntegerValue: op) bitAnd: high.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> bitOr [
	| op high |
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ pc popStack.
			^ self failPrimitive ].
	high := memory smallIntegerValue: op.
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := (memory smallIntegerValue: op) bitOr: high.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> bitShift [
	| op low high |
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ pc popStack.
			^ self failPrimitive ].
	low := memory smallIntegerValue: op.
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ ^ self failPrimitive ].
	high := memory smallIntegerValue: op.
	low := low < 0
		ifTrue: [ high >> low negated ]
		ifFalse: [ high << low ].
	(memory fitsSmallInteger: low)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := memory newSmallInteger: low.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> blockInvocation: anInteger [
	| obj high low x |
	returnedValue := pc popStack.
	obj := memory
		objectAt: returnedValue
		dataAt: self argumentLocationInBlock.
	high := memory smallIntegerValue: obj.
	pc temporaries: (memory
		objectAt: returnedValue
		dataAt: self temporariesInBlock).
	low := anInteger - 2.
	x := pc temporaries = 0
		ifTrue: [ 0 ]
		ifFalse: [ (memory sizeOfObjectAt: pc temporaries) - high ].
	low >= x
		ifTrue: [ low + 1 timesRepeat: [ pc popStack ].
			self failPrimitive ].
	low to: 0 by: -1 do:
		[ :each | memory objectAt: pc temporaries dataAt: high + each put: pc popStack ].
	obj := pc previousContextOfContext.
	memory
		objectAt: returnedValue
		dataAt: self previousContextInBlock
		put: obj.
	pc context: returnedValue.
	pc clearTriplet.
	pc setStackOfContext.
	pc clearStackTop.
	pc setMethodOfBlock.
	pc setBpOfMethod.
	pc setBytePointerOfBlock.
	allocator popRoot
]

{ #category : #'dispatch primitives' }
LInterpreter >> bulkObjectExchange [
	| op |
	op := pc popStack.
	(self classOfObjectAt: op isNamed: self arrayClassName)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := pc popStack.
	(self classOfObjectAt: returnedValue isNamed: self arrayClassName)
		ifFalse: [ ^ self failPrimitive ].
	self exchangeObjects: op and: returnedValue.
	self doReturn
]

{ #category : #private }
LInterpreter >> bulkReplace: anInteger from: anInteger2 to: anInteger3 with: anInteger4 startingAt: anInteger5 [
	| iRepStart iStart iStop count srcIsBinary destIsBinary |
	(memory isSmallInteger: anInteger2)
		ifFalse: [ ^ false ].
	(memory isSmallInteger: anInteger3)
		ifFalse: [ ^ false ].
	(memory isSmallInteger: anInteger5)
		ifFalse: [ ^ false ].
	iRepStart := (memory smallIntegerValue: anInteger5) - 1.
	iStart := (memory smallIntegerValue: anInteger2) - 1.
	iStop := (memory smallIntegerValue: anInteger3) - 1.
	count := iStop - iStart + 1.
	(iRepStart < 0 or: [ iStart < 0 or: [ iStop < 0 or: [ count < 1 ] ] ])
		ifTrue: [ ^ true ].
	((memory sizeOfObjectAt: anInteger) < iStop
		or: [ (memory sizeOfObjectAt: anInteger4) < (iRepStart + count) ])
		ifTrue: [ ^ true ].
	destIsBinary := memory isBinaryAt: anInteger.
	srcIsBinary := memory isBinaryAt: anInteger4.
	(srcIsBinary and: [ destIsBinary ])
		ifTrue: [ memory
				bCopyFrom: (memory byteAddressOfObjectAt: anInteger4) + iRepStart
				to: (memory byteAddressOfObjectAt: anInteger) + iStart
				count: count.
			^ true ].
	(srcIsBinary or: [ destIsBinary ])
		ifTrue: [ ^ false ].
	(allocator isDynamicMemory: anInteger)
		= (allocator isDynamicMemory: anInteger4)
		ifFalse: [ ^ false ].
	memory
		bCopyFrom: (memory addressOfObjectAt: anInteger4 dataAt: iRepStart)
		to: (memory addressOfObjectAt: anInteger dataAt: iStart)
		count: memory bytesPerWord * count.
	^ true
]

{ #category : #'dispatch primitives' }
LInterpreter >> byteArrayAllocation [
	| low |
	low := memory smallIntegerValue: pc popStack.
	allocator pushRoot: pc popStack.
	returnedValue := allocator gcIAlloc: low.
	memory objectAt: returnedValue class: allocator popRoot.
	memory clearObjectAt: returnedValue.
	self doReturn
]

{ #category : #accessing }
LInterpreter >> cache [
	^ cache
]

{ #category : #accessing }
LInterpreter >> cache: anObject [
	cache := anObject
]

{ #category : #private }
LInterpreter >> checkCache: anInteger [
	| low badMethodSym obj x high m |
	badMethodSym := env symbolNamed: #doesNotUnderstand:.
	m := cache
		methodAtMessageSelector: messageSelector
		receiverClass: anInteger
		ifAbsent: [ self lookupMethod: messageSelector inClass: anInteger ].
	m
		ifNil: [ messageSelector = badMethodSym
				ifTrue: [ self error: 'doesNotUnderstand: missing' ].
			allocator pushRoot: pc arguments.
			allocator pushRoot: messageSelector.
			allocator pushRoot: pc context.
			pc arguments: self newArguments.
			messageSelector := badMethodSym.
			^ self findMethodFromSymbol ].
	pc method: m.
	high := pc preFetch = (self doSpecial * 16 + self stackReturn)
		ifTrue: [ 1 ]
		ifFalse: [ pc preFetch = (self doSpecial * 16 + self blockReturn)
				ifTrue: [ 2 ]
				ifFalse: [ 0 ] ].
	allocator pushRoot: pc arguments.
	allocator pushRoot: pc method.
	allocator pushRoot: pc context.
	low := pc temporarySizeOfMethod.
	x := pc stackSizeOfMethod.
	allocator pushRoot: (self newArray: x).
	low > 0
		ifTrue: [ obj := self newArray: low.
			pc temporaries: obj.
			allocator pushRoot: obj ]
		ifFalse: [ allocator pushRoot: 0 ].
	pc context: allocator thirdOfRoot.
	pc putStackTopOfContext.
	pc putBytePointerOfContext.
	obj := allocator gcAlloc: self contextSize.
	self objectAt: obj classNamed: self contextClassName.
	pc context: obj.
	pc temporaries: allocator popRoot.
	pc putTemporariesOfContext.
	pc stack: allocator popRoot.
	pc putStackOfContext.
	self objectAt: pc stack classNamed: self arrayClassName.
	pc clearStackTopOfContext.
	pc clearStackTop.
	memory
		objectAt: pc context
		dataAt: self previousContextInContext
		put: allocator popRoot.
	high = 1
		ifTrue: [ obj := pc previousContextOfContext.
			obj := memory objectAt: obj dataAt: self previousContextInContext.
			memory
				objectAt: pc context
				dataAt: self previousContextInContext
				put: obj ]
		ifFalse: [ high = 2
				ifTrue: [ obj := pc previousContextOfContext.
					obj := memory objectAt: obj dataAt: self creatingContextInBlock.
					obj := memory objectAt: obj dataAt: self previousContextInContext.
					memory
						objectAt: pc context
						dataAt: self previousContextInContext
						put: obj ] ].
	pc method: allocator popRoot.
	pc putMethodOfContext.
	pc arguments: allocator popRoot.
	pc putArgumentsOfContext.
	pc instanceVariables: 0.
	pc literals: 0.
	pc clearBytePointerOfContext.
	pc bytePointer: 0.
	pc setBpOfMethod
]

{ #category : #private }
LInterpreter >> checkGlobals: aGarbageCollector [
	env globalsDo: [ :each | aGarbageCollector checkValidObject: each ]
]

{ #category : #private }
LInterpreter >> checkTicks [
	| process context |
	ticks = 0
		ifTrue: [ ^ self ].
	ticks := ticks - 1.
	ticks > 0
		ifTrue: [ ^ self ].
	process := allocator popRoot.
	context := pc context.
	memory objectAt: process dataAt: self contextInProcess put: context.
	memory
		objectAt: process
		dataAt: self resultInProcess
		put: returnedValue.
	memory
		objectAt: context
		dataAt: self bytePointerInContext
		put: (memory newSmallInteger: pc bytePointer).
	memory
		objectAt: context
		dataAt: self stackTopInContext
		put: (memory newSmallInteger: pc stackTop).
	self exit: self returnTimeExpired process: process
]

{ #category : #private }
LInterpreter >> classOf: anInteger [
	(memory isSmallInteger: anInteger)
		ifTrue: [ ^ env globalNamed: self smallIntegerClassName ].
	^ memory classOfObjectAt: anInteger
]

{ #category : #private }
LInterpreter >> classOfObjectAt: anInteger isNamed: aString [
	^ (memory classOfObjectAt: anInteger) = (env globalNamed: aString)
]

{ #category : #api }
LInterpreter >> createInitialContextFrom: anArray [
	| process initialStack initialTempraries obj |
	process := anArray first.
	initialStack := anArray second.
	initialTempraries := anArray third.
	obj := allocator gcAlloc: self contextSize.
	self objectAt: obj classNamed: self contextClassName.
	memory objectAt: process dataAt: self contextInProcess put: obj.
	memory objectAt: obj dataAt: self stackInContext put: initialStack.
	memory objectAt: obj dataAt: self argumentsInContext put: env nilObject.
	memory objectAt: obj dataAt: self temporariesInContext put: initialTempraries.
	memory objectAt: obj dataAt: self bytePointerInContext put: (memory newSmallInteger: 0).
	memory objectAt: obj dataAt: self stackTopInContext put: (memory newSmallInteger: 0).
	memory objectAt: obj dataAt: self previousContextInContext put: env nilObject.
	memory objectAt: obj dataAt: self methodInContext put: env bootMethod.
	pc context: obj.
	allocator pushRoot: process.
	^ process
]

{ #category : #accessing }
LInterpreter >> dispatchTable [
	^ dispatchTable
]

{ #category : #accessing }
LInterpreter >> dispatchTable: anObject [
	dispatchTable := anObject
]

{ #category : #'dispatch specials' }
LInterpreter >> doBlockReturn [
	| obj |
	returnedValue := pc popStack.
	obj := memory
		objectAt: pc context
		dataAt: self creatingContextInBlock.
	obj := memory objectAt: obj dataAt: self previousContextInContext.
	pc context: obj.
	self doReturn2
]

{ #category : #'dispatch specials' }
LInterpreter >> doBranch [
	pc bytePointer: pc preFetchUint16
]

{ #category : #'dispatch specials' }
LInterpreter >> doBranchIfFalse [
	| low |
	low := pc preFetchUint16.
	returnedValue := pc popStack.
	pc
		bytePointer:
			(returnedValue = env falseObject
				ifTrue: [ low ]
				ifFalse: [ pc bytePointer + self valSize ])
]

{ #category : #'dispatch specials' }
LInterpreter >> doBranchIfTrue [
	| low |
	low := pc preFetchUint16.
	returnedValue := pc popStack.
	pc
		bytePointer:
			(returnedValue = env trueObject
				ifTrue: [ low ]
				ifFalse: [ pc bytePointer + self valSize ])
]

{ #category : #'dispatch specials' }
LInterpreter >> doBreakpoint [
	| process |
	pc bytePointer: pc bytePointer - 1.
	process := allocator popRoot.
	memory
		objectAt: process
		dataAt: self contextInProcess
		put: pc context.
	memory
		objectAt: process
		dataAt: self resultInProcess
		put: returnedValue.
	memory
		objectAt: pc context
		dataAt: self bytePointerInContext
		put: (memory newSmallInteger: pc bytePointer).
	memory
		objectAt: pc context
		dataAt: self stackTopInContext
		put: (memory newSmallInteger: pc stackTop).
	self exit: self returnBreak process: process
]

{ #category : #'dispatch specials' }
LInterpreter >> doDuplicate [
	returnedValue := pc popStack.
	pc pushStack: returnedValue
]

{ #category : #private }
LInterpreter >> doInteger: aSymbol [
	| op |
	op := pc popStack.
	(self classOfObjectAt: op isNamed: self integerClassName)
		ifFalse: [ pc popStack.
			^ self failPrimitive ].
	returnedValue := pc popStack.
	(self classOfObjectAt: returnedValue isNamed: self integerClassName)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := self doInteger: aSymbol with: returnedValue and: op.
	returnedValue ifNil: [ ^ self failPrimitive ].
	self doReturn
]

{ #category : #private }
LInterpreter >> doInteger: aSymbol with: anInteger and: anInteger2 [
	| x y |
	x := memory byteArrayOfObjectAt: anInteger.
	x := self largeIntegerFrom: x.
	y := memory byteArrayOfObjectAt: anInteger2.
	y := self largeIntegerFrom: x.
	^ self perform: aSymbol with: x with: y
]

{ #category : #api }
LInterpreter >> doOneCycle [
	| low high selector |
	exitBlock := [ :v | ^ v ].
	self checkTicks.
	high := pc fetch.
	low := high bitAnd: 16r0F.
	high := high >> 4.
	high = self extended
		ifTrue: [ high := low.
			low := pc fetch ].
	selector := dispatchTable at: high.
	self log: {'high='. high. ' low='. low. ' $'. pc fetchAddress. ':'. selector}.
	self perform: selector with: low.
	^ self returnContinue
]

{ #category : #'dispatch specials' }
LInterpreter >> doPopTop [
	pc popStack
]

{ #category : #dispatching }
LInterpreter >> doPrimitive: anInteger [
	| high selector |
	high := pc fetch.
	allocator pushRoot: pc context.
	(high < 1 or: [high > primitiveDispatchTable size])
		ifTrue: [ ^ self error ].
	selector := primitiveDispatchTable at: high.
	self info: selector.
	selector numArgs = 0
		ifTrue: [ ^ self perform: selector ].
	selector numArgs = 1
		ifTrue: [ ^ self perform: selector with: anInteger ].
	self error
]

{ #category : #'dispatch primitives' }
LInterpreter >> doPrimitive: anInteger arguments: anInteger2 [
	self shouldBeImplemented
]

{ #category : #private }
LInterpreter >> doReturn [
	pc context: allocator popRoot.
	self doReturn1
]

{ #category : #private }
LInterpreter >> doReturn1 [
	pc rewindePreviousContext.
	self doReturn2
]

{ #category : #private }
LInterpreter >> doReturn2 [
	| process |
	(pc context = 0 or: [ pc context = env nilObject ])
		ifTrue: [ process := allocator popRoot.
			memory objectAt: process dataAt: self contextInProcess put: pc context.
			memory
				objectAt: process
				dataAt: self resultInProcess
				put: returnedValue.
			^ self exit: self returnReturned process: process ].
	pc clearQuad.
	pc setStackOfContext.
	pc setStackTopOfContext.
	pc pushStack: returnedValue.
	pc setMethodOfContext.
	pc setBpOfMethod.
	pc setBytePointerOfContext
]

{ #category : #'dispatch specials' }
LInterpreter >> doSelfReturn [
	pc assureArguments.
	returnedValue := pc getReceiverOfArguments.
	self doReturn1
]

{ #category : #'dispatch specials' }
LInterpreter >> doSendToSuper [
	| low receiverClass obj |
	low := pc fetch.
	pc assureLiterals.
	messageSelector := (memory objectAt: pc literals dataAt: low).
	obj := memory objectAt: pc method dataAt: self classInMethod.
	receiverClass := memory objectAt: obj dataAt: self parentClassInClass.
	pc arguments: pc popStack.
	self checkCache: receiverClass
]

{ #category : #dispatching }
LInterpreter >> doSpecial: anInteger [
	| selector |
	selector := specialDispatchTable at: anInteger.
	self info: selector.
	selector numArgs = 0
		ifTrue: [ ^ self perform: selector ].
	self error
]

{ #category : #'dispatch specials' }
LInterpreter >> doStackReturn [
	returnedValue := pc popStack.
	self doReturn1
]

{ #category : #accessing }
LInterpreter >> env [
	^ env
]

{ #category : #accessing }
LInterpreter >> env: anObject [
	env := anObject
]

{ #category : #'dispatch primitives' }
LInterpreter >> errorTrap [
	| process |
	allocator popRoot.
	process := allocator popRoot.
	memory objectAt: process dataAt: self contextInProcess put: pc context.
	self exit: self returnError process: process
]

{ #category : #private }
LInterpreter >> exchangeObjects: a and: b [
	(memory sizeOfObjectAt: a) = (memory sizeOfObjectAt: b)
		ifFalse: [ ^ self failPrimitive ].
	self shouldBeImplemented
]

{ #category : #api }
LInterpreter >> execute: anInteger ticks: anInteger2 [
	pc pushTicks: ticks.
	ticks := anInteger2.
	self startProcess: anInteger
]

{ #category : #private }
LInterpreter >> exit: anInteger process: anInteger2 [
	ticks := pc popTicks.
	(anInteger = self returnReturned and: [ pc existRegisters ])
		ifTrue: [ pc popRegisters.
			returnedValue := memory newSmallInteger: anInteger.
			^ self doReturn ].
	exitBlock cull: anInteger
]

{ #category : #accessing }
LInterpreter >> exitBlock [
	^ exitBlock
]

{ #category : #accessing }
LInterpreter >> exitBlock: anObject [
	exitBlock := anObject
]

{ #category : #'dispatch primitives' }
LInterpreter >> failPrimitive [
	| tmp |
	self info: 'primitive failed'.
	returnedValue := env nilObject.
	tmp := allocator popRoot.
	pc context = tmp
		ifFalse: [ pc context: tmp.
			pc setMethodOfContext.
			pc setStackOfContext.
			pc setBpOfMethod.
			pc clearQuad ].
	pc pushStack: env nilObject
]

{ #category : #private }
LInterpreter >> findMethodFromSymbol [
	| receiverClass |
	receiverClass := self classOf: pc getReceiverOfArguments.
	self checkCache: receiverClass
]

{ #category : #'dispatch primitives' }
LInterpreter >> flushMethodCache [
	cache flush.
	self doReturn
]

{ #category : #private }
LInterpreter >> info: aCollection [
	logger trace: '# '.
	logger
		traceCr:
			(aCollection isString
				ifTrue: [ aCollection ]
				ifFalse: [ aCollection joinUsing: Character space ])
]

{ #category : #initialization }
LInterpreter >> initialize [
	self setupDispatchTable.
	self setupPrimitiveDispatchTable.
	self setupSpecialDispatchTable.
	cache := LMethodCache new.
	pc := LProcessor new.
	ticks := 0.
	logger := LDummyLogger new
]

{ #category : #private }
LInterpreter >> integer: a lessThan: b [
	^ a < b
		ifTrue: [ env trueObject ]
		ifFalse: [ env falseObject ]
]

{ #category : #private }
LInterpreter >> integerAdd: a with: b [
	^ self newLargeInteger: a + b
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerAddition [
	self doInteger: #integerAdd:with:
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerAllocation [
	| op |
	op := pc popStack.
	(memory isSmallInteger: op)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := self newLargeInteger: op.
	self doReturn
]

{ #category : #private }
LInterpreter >> integerDivide: a by: b [
	b = 0
		ifTrue: [ ^ nil ].
	^ self newLargeInteger:a // b
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerDivision [
	self doInteger: #integerDivide:by:
]

{ #category : #private }
LInterpreter >> integerEqual: a to: b [
	^ a = b
		ifTrue: [ env trueObject ]
		ifFalse: [ env falseObject ]
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerEquality [
	self doInteger: #integerEqual:to:
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerLessThan [
	self doInteger: #integer:lessThan:
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerMultiplication [
	self doInteger: #integerMultiply:by:
]

{ #category : #private }
LInterpreter >> integerMultiply: a by: b [
	^ self newLargeInteger: a * b
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerRemainder [
	self doInteger: #integerRemainder:of:
]

{ #category : #private }
LInterpreter >> integerRemainder: a of: b [
	b = 0
		ifTrue: [ ^ nil ].
	^ self newLargeInteger: a \\ b
]

{ #category : #private }
LInterpreter >> integerSubtract: a by: b [
	^ self newLargeInteger: a - b
]

{ #category : #'dispatch primitives' }
LInterpreter >> integerSubtraction [
	self doInteger: #integerSubtract:by:
]

{ #category : #accessing }
LInterpreter >> ioSystem [
	^ ioSystem
]

{ #category : #accessing }
LInterpreter >> ioSystem: anObject [
	ioSystem := anObject
]

{ #category : #private }
LInterpreter >> largeIntegerFrom: aByteString [
	self shouldBeImplemented
]

{ #category : #private }
LInterpreter >> log: aCollection [
	logger
		traceCr:
			(aCollection isString
				ifTrue: [ aCollection ]
				ifFalse: [ (aCollection collect: #asString) joinUsing: '' ])
]

{ #category : #accessing }
LInterpreter >> logger [
	^ logger
]

{ #category : #accessing }
LInterpreter >> logger: anObject [
	logger := anObject
]

{ #category : #private }
LInterpreter >> lookupMethod: anInteger inClass: anInteger2 [
	| cl dict keys low high mid val vals |
	cl := anInteger2.
	[ cl = env nilObject ]
		whileFalse: [ dict := memory methodsOfClassAt: cl.
			keys := memory objectAt: dict dataAt: 0.
			low := 0.
			high := memory sizeOfObjectAt: keys.
			[ low < high ]
				whileTrue: [ mid := (low + high) // 2.
					val := memory objectAt: keys dataAt: mid.
					val = anInteger
						ifTrue: [ vals := memory objectAt: dict dataAt: 1.
							^ memory objectAt: vals dataAt: mid ].
					(memory compareString: anInteger with: val) < 0
						ifTrue: [ high := mid ]
						ifFalse: [ low := mid + 1 ] ].
			cl := memory parentClassOfClassAt: cl ].
	^ nil
]

{ #category : #'dispatch primitives' }
LInterpreter >> lowOrderOfInteger [
	| op arr x l |
	op := pc popStack.
	arr := memory byteArrayOfObjectAt: op.
	l := self largeIntegerFrom: arr.
	x := l bitAnd: 16rFFFFFFFF.
	(memory fitsSmallInteger: x)
		ifFalse: [ ^ self failPrimitive ].
	returnedValue := memory newSmallInteger: x.
	self doReturn
]

{ #category : #dispatching }
LInterpreter >> markArguments: anInteger [
	| obj tmp |
	self info: anInteger asString.
	allocator pushRoot: pc context.
	obj := allocator gcAlloc: anInteger.
	self objectAt: obj classNamed: self arrayClassName.
	pc arguments: obj.
	tmp := allocator popRoot.
	pc context ~= tmp
		ifTrue: [ pc clearTriplet2.
			pc context: tmp.
			pc setMethodOfContext.
			pc setBpOfMethod.
			pc setStackOfContext ].
	anInteger - 1 to: 0 by: -1 do:
		[ :each | memory objectAt: pc arguments dataAt: each put: pc popStack ].
	pc pushArguments.
	pc arguments: 0
]

{ #category : #accessing }
LInterpreter >> memory [
	^ memory
]

{ #category : #accessing }
LInterpreter >> memory: anObject [
	memory := anObject.
	"gc memory: anObject."
	pc memory: anObject
]

{ #category : #accessing }
LInterpreter >> messageSelector [
	^ messageSelector
]

{ #category : #accessing }
LInterpreter >> messageSelector: anObject [
	messageSelector := anObject
]

{ #category : #private }
LInterpreter >> newArguments [
	| op obj |
	op := allocator gcAlloc: 2.
	self objectAt: op classNamed: self arrayClassName.
	pc context: allocator popRoot.
	messageSelector := allocator popRoot.
	pc arguments: allocator popRoot.
	obj := memory objectAt: pc arguments dataAt: self receiverInArguments.
	memory objectAt: op dataAt: self receiverInArguments put: obj.
	memory objectAt: op dataAt: 1 put: messageSelector.
	^ obj
]

{ #category : #private }
LInterpreter >> newArray: anInteger [
	| obj |
	obj := allocator gcAlloc: anInteger.
	self objectAt: obj classNamed: self arrayClassName.
	memory clearObjectAt: obj.
	^ obj
]

{ #category : #private }
LInterpreter >> newLargeInteger: anInteger [
	| obj arr |
	obj := allocator gcIAlloc: 8.
	self objectAt: obj classNamed: self integerClassName.
	arr := anInteger asByteArray reversed.
	arr := arr grownBy: 8 - arr size.
	memory objectAt: obj byteArray: arr
]

{ #category : #'dispatch primitives' }
LInterpreter >> newObjectAllocation [
	| low |
	low := memory smallIntegerValue: pc popStack.
	allocator pushRoot: pc popStack.
	returnedValue := allocator gcAlloc: low.
	memory objectAt: returnedValue class: allocator popRoot.
	memory clearObjectAt: returnedValue.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> newProcessExecute [
	| low op |
	low := memory smallIntegerValue: pc popStack.
	op := pc popStack.
	pc pushRegisters.
	self execute: op ticks: low
]

{ #category : #private }
LInterpreter >> objectAt: anInteger classNamed: aString [
	| cl |
	cl := env globalNamed: aString.
	^ memory objectAt: anInteger class: cl
]

{ #category : #'dispatch primitives' }
LInterpreter >> objectClass [
	returnedValue := self classOf: pc popStack.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> objectIdentity [
	returnedValue := pc popStack = pc popStack
		ifTrue: [ env trueObject ]
		ifFalse: [ env falseObject ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> objectSize [
	returnedValue := pc popStack.
	returnedValue := (memory isSmallInteger: returnedValue)
		ifTrue: [ 0 ]
		ifFalse: [ memory sizeOfObjectAt: returnedValue ].
	returnedValue := memory newSmallInteger: returnedValue.
	self doReturn
]

{ #category : #accessing }
LInterpreter >> pc [
	^ pc
]

{ #category : #accessing }
LInterpreter >> pc: anObject [
	pc := anObject
]

{ #category : #accessing }
LInterpreter >> primitiveDispatchTable [
	^ primitiveDispatchTable
]

{ #category : #accessing }
LInterpreter >> primitiveDispatchTable: anObject [
	primitiveDispatchTable := anObject
]

{ #category : #'dispatch primitives' }
LInterpreter >> printSingleCharacter [
	| low |
	low := pc popStack.
	low := memory smallIntegerValue: low.
	ioSystem putChar: low.
	returnedValue := env nilObject.
	self doReturn
]

{ #category : #dispatching }
LInterpreter >> pushArgument: anInteger [
	| obj |
	pc assureArguments.
	obj := memory objectAt: pc arguments dataAt: anInteger.
	pc pushStack: obj
]

{ #category : #dispatching }
LInterpreter >> pushBlock: anInteger [
	| high op obj |
	high := pc fetchUint16.
	allocator pushRoot: pc context.
	op := allocator gcAlloc: pc stackSizeOfMethod.
	self objectAt: op classNamed: self arrayClassName.
	allocator pushRoot: op.
	memory clearObjectAt: op.
	returnedValue := allocator gcAlloc: self blockSize.
	self objectAt: returnedValue classNamed: self blockClassName.
	memory objectAt: returnedValue dataAt: self bytePointerInContext put: 0.
	memory objectAt: returnedValue dataAt: self stackTopInBlock put: 0.
	memory objectAt: returnedValue dataAt: self previousContextInBlock put: 0.
	obj := memory newSmallInteger: pc bytePointer.
	memory objectAt: returnedValue dataAt: self bytePointerInBlock put: obj.
	obj := memory newSmallInteger: anInteger.
	memory objectAt: returnedValue dataAt: self argumentLocationInBlock put: obj.
	memory objectAt: returnedValue dataAt: self stackInBlock put: allocator popRoot.
	pc context: allocator popRoot.
	obj := (self classOfObjectAt: pc context isNamed: self blockClassName)
		ifTrue: [ pc putCreatingContextOfBlock ]
		ifFalse: [ pc context ].
	memory objectAt: returnedValue dataAt: self creatingContextInBlock put: obj.
	obj := memory objectAt: pc context dataAt: self methodInBlock.
	memory objectAt: returnedValue dataAt: self methodInBlock put: obj.
	pc method: obj.
	obj := memory objectAt: pc context dataAt: self argumentsInBlock.
	memory objectAt: returnedValue dataAt: self argumentsInBlock put: obj.
	pc arguments: obj.
	obj := memory objectAt: pc context dataAt: self temporariesInBlock.
	memory objectAt: returnedValue dataAt: self temporariesInBlock put: obj.
	pc temporaries: obj.
	pc setStackOfContext.
	pc setBpOfMethod.
	pc pushStack: returnedValue.
	pc clearDouble.
	pc bytePointer: high
]

{ #category : #dispatching }
LInterpreter >> pushConstant: anInteger [
	(anInteger between: 0 and: 9)
		ifTrue: [ self info: anInteger asString.
			^ pc pushStack: (memory newSmallInteger: anInteger) ].
	anInteger = self nilConst
		ifTrue: [ self info: 'nil'.
			^ pc pushStack: env nilObject ].
	anInteger = self trueConst
		ifTrue: [ self info: 'true'.
			^ pc pushStack: env trueObject ].
	anInteger = self falseConst
		ifTrue: [ self info: 'false'.
			^ pc pushStack: env falseObject ].
	self error: 'unknown push constant'
]

{ #category : #dispatching }
LInterpreter >> pushInstance: anInteger [
	| obj |
	pc assureArguments.
	pc assureInstanceVariables.
	obj := memory objectAt: pc instanceVariables dataAt: anInteger.
	pc pushStack: obj
]

{ #category : #dispatching }
LInterpreter >> pushLiteral: anInteger [
	| obj |
	pc assureLiterals.
	obj := memory objectAt: pc literals dataAt: anInteger.
	pc pushStack: obj
]

{ #category : #dispatching }
LInterpreter >> pushTemporary: anInteger [
	| obj |
	pc assureTemporaries.
	obj := memory objectAt: pc temporaries dataAt: anInteger.
	pc pushStack: obj
]

{ #category : #'dispatch primitives' }
LInterpreter >> readCharFromInput [
	| low |
	low := ioSystem getChar.
	returnedValue := low = ioSystem eof
		ifTrue: [ env nilObject ]
		ifFalse: [ memory newSmallInteger: low ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> replaceFrom [
	| a b c d |
	returnedValue := pc popStack.
	a := pc popStack.
	b := pc popStack.
	c := pc popStack.
	d := pc popStack.
	(self bulkReplace: returnedValue from: d to: c with: b startingAt: a)
		ifFalse: [ ^ self failPrimitive ].
	self doReturn
	"self failPrimitive"
]

{ #category : #accessing }
LInterpreter >> returnedValue [
	^ returnedValue
]

{ #category : #accessing }
LInterpreter >> returnedValue: anObject [
	returnedValue := anObject
]

{ #category : #dispatching }
LInterpreter >> sendBinary: anInteger [
	| i j obj tmp |
	((memory isSmallInteger: pc topOfStack)
		and: [ memory isSmallInteger: pc secondOfStack ])
		ifTrue: [ j := memory smallIntegerValue: pc popStack.
			i := memory smallIntegerValue: pc popStack.
			returnedValue := nil.
			self info: (#('<' '<=' '+') at: anInteger + 1).
			anInteger = 0
				ifTrue: [ returnedValue := i < j
						ifTrue: [ env trueObject ]
						ifFalse: [ env falseObject ] ].
			anInteger = 1
				ifTrue: [ returnedValue := i <= j
						ifTrue: [ env trueObject ]
						ifFalse: [ env falseObject ] ].
			anInteger = 2
				ifTrue: [ returnedValue := memory newSmallInteger: i + j ].
			returnedValue ifNil: [ self error ].
			^ pc pushStack: returnedValue ].
	allocator pushRoot: pc context.
	obj := allocator gcAlloc: 2.
	self objectAt: obj classNamed: self arrayClassName.
	pc arguments: obj.
	tmp := allocator popRoot.
	pc context = tmp
		ifFalse: [ pc clearTriplet2.
			pc context: tmp.
			pc setMethodOfContext.
			pc setBpOfMethod.
			pc setStackOfContext ].
	memory objectAt: pc arguments dataAt: 1 put: pc popStack.
	memory objectAt: pc arguments dataAt: 0 put: pc popStack.
	messageSelector := self binaryMessageAt: anInteger.
	self info: (memory printObjectAt: messageSelector).
	self findMethodFromSymbol
]

{ #category : #dispatching }
LInterpreter >> sendMessage: anInteger [
	pc assureLiterals.
	messageSelector := memory objectAt: pc literals dataAt: anInteger.
	self info: (memory printObjectAt: messageSelector).
	pc popArguments.
	self findMethodFromSymbol
]

{ #category : #dispatching }
LInterpreter >> sendUnary: anInteger [
	returnedValue := pc popStack.
	self info: (#(isNil notNil) at: anInteger + 1).
	anInteger = 0
		ifTrue: [ returnedValue := returnedValue = env nilObject
				ifTrue: [ env trueObject ]
				ifFalse: [ env falseObject ] ]
		ifFalse: [ anInteger = 1
				ifTrue: [ returnedValue := returnedValue = env nilObject
						ifTrue: [ env falseObject ]
						ifFalse: [ env trueObject ] ]
				ifFalse: [ self error: 'unimplemented SendUnary' ] ].
	pc pushStack: returnedValue
]

{ #category : #private }
LInterpreter >> setupDispatchTable [
	dispatchTable := Array new: 16.
	dispatchTable at: self pushInstance put: #pushInstance:.
	dispatchTable at: self pushArgument put: #pushArgument:.
	dispatchTable at: self pushTemporary put: #pushTemporary:.
	dispatchTable at: self pushLiteral put: #pushLiteral:.
	dispatchTable at: self pushConstant put: #pushConstant:.
	dispatchTable at: self assignInstance put: #assignInstance:.
	dispatchTable at: self assignTemporary put: #assignTemporary:.
	dispatchTable at: self markArguments put: #markArguments:.
	dispatchTable at: self sendMessage put: #sendMessage:.
	dispatchTable at: self sendUnary put: #sendUnary:.
	dispatchTable at: self sendBinary put: #sendBinary:.
	dispatchTable at: self pushBlock put: #pushBlock:.
	dispatchTable at: self doPrimitive put: #doPrimitive:.
	dispatchTable at: self doSpecial put: #doSpecial:
]

{ #category : #private }
LInterpreter >> setupPrimitiveDispatchTable [
	| dict |
	dict := Array new: 256.
	dict at: 1 put: #objectIdentity.
	dict at: 2 put: #objectClass.
	dict at: 3 put: #printSingleCharacter.
	dict at: 4 put: #objectSize.
	dict at: 5 put: #arrayAtPut.
	dict at: 6 put: #newProcessExecute.
	dict at: 7 put: #newObjectAllocation.
	dict at: 8 put: #blockInvocation:.
	dict at: 9 put: #readCharFromInput.
	dict at: 10 put: #smallIntegerAddition.
	dict at: 11 put: #smallIntegerDivision.
	dict at: 12 put: #smallIntegerRemainder.
	dict at: 13 put: #smallIntegerLessThan.
	dict at: 14 put: #smallIntegerEquality.
	dict at: 15 put: #smallIntegerMultiplication.
	dict at: 16 put: #smallIntegerSubtraction.
	dict at: 18 put: #turnOnDebugging.
	dict at: 19 put: #errorTrap.
	dict at: 20 put: #byteArrayAllocation.
	dict at: 21 put: #stringAt.
	dict at: 22 put: #stringAtPut.
	dict at: 23 put: #stringClone.
	dict at: 24 put: #arrayAt.
	dict at: 25 put: #integerDivision.
	dict at: 26 put: #integerRemainder.
	dict at: 27 put: #integerAddition.
	dict at: 28 put: #integerMultiplication.
	dict at: 29 put: #integerSubtraction.
	dict at: 30 put: #integerLessThan.
	dict at: 31 put: #integerEquality.
	dict at: 32 put: #integerAllocation.
	dict at: 33 put: #lowOrderOfInteger.
	dict at: 34 put: #flushMethoCache.
	dict at: 35 put: #bulkObjectExchange.
	dict at: 36 put: #bitOr.
	dict at: 37 put: #bitAnd.
	dict at: 38 put: #replaceFrom.
	dict at: 39 put: #bitShift.
	dict at: 40 put: #truncateInteger.
	primitiveDispatchTable := dict
]

{ #category : #private }
LInterpreter >> setupSpecialDispatchTable [
	| dict |
	dict := Array new: 256.
	dict at: self selfReturn put: #doSelfReturn.
	dict at: self stackReturn put: #doStackReturn.
	dict at: self blockReturn put: #doBlockReturn.
	dict at: self duplicate put: #doDuplicate.
	dict at: self popTop put: #doPopTop.
	dict at: self branch put: #doBranch.
	dict at: self branchIfTrue put: #doBranchIfTrue.
	dict at: self branchIfFalse put: #doBranchIfFalse.
	dict at: self sendToSuper put: #doSendToSuper.
	dict at: self breakpoint put: #doBreakPoint.
	specialDispatchTable := dict
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerAddition [
	| r x |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	x := r first + r second.
	returnedValue := (memory fitsSmallInteger: x)
		ifTrue: [ memory newSmallInteger: x ]
		ifFalse: [ self newLargeInteger: x ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerDivision [
	| r low high |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	high := r first.
	low := r second.
	low = 0
		ifTrue: [ ^ self failPrimitive ].
	high := high // low.
	returnedValue := memory newSmallInteger: high.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerEquality [
	| r low high |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	high := r first.
	low := r second.
	returnedValue := high = low
		ifTrue: [ env trueObject ]
		ifFalse: [ env falseObject ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerLessThan [
	| r low high |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	high := r first.
	low := r second.
	returnedValue := high < low
		ifTrue: [ env trueObject ]
		ifFalse: [ env falseObject ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerMultiplication [
	| r x |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	x := r first * r second.
	returnedValue := (memory fitsSmallInteger: x)
		ifTrue: [ memory newSmallInteger: x ]
		ifFalse: [ self newLargeInteger: x ].
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerRemainder [
	| r low high |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	high := r first.
	low := r second.
	low = 0
		ifTrue: [ ^ self failPrimitive ].
	high := high \\ low.
	returnedValue := memory newSmallInteger: high.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> smallIntegerSubtraction [
	| r x |
	r := pc getHighLow.
	r ifNil: [ ^ self failPrimitive ].
	x := r first - r second.
	returnedValue := (memory fitsSmallInteger: x)
		ifTrue: [ memory newSmallInteger: x ]
		ifFalse: [ self newLargeInteger: x ].
	self doReturn
]

{ #category : #accessing }
LInterpreter >> specialDispatchTable [
	^ specialDispatchTable
]

{ #category : #accessing }
LInterpreter >> specialDispatchTable: anObject [
	specialDispatchTable := anObject
]

{ #category : #api }
LInterpreter >> startProcess: anInteger [
	allocator pushRoot: anInteger.
	pc startProcess: anInteger.
	returnedValue := env nilObject
]

{ #category : #'dispatch primitives' }
LInterpreter >> stringAt [
	| low |
	low := (memory smallIntegerValue: pc popStack) - 1.
	returnedValue := pc popStack.
	(low < 0 or: [ low >= (memory sizeOfObjectAt: returnedValue) ])
		ifTrue: [ ^ self failPrimitive ].
	low := memory objectAt: returnedValue byteAt: low.
	returnedValue := memory newSmallInteger: low.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> stringAtPut [
	| low |
	low := (memory smallIntegerValue: pc popStack) - 1.
	returnedValue := pc popStack.
	(low < 0 or: [ low >= (memory sizeOfObjectAt: returnedValue) ])
		ifTrue: [ pc popStack.
			^ self failPrimitive ].
	memory
		objectAt: returnedValue
		byteAt: low
		put: (memory smallIntegerValue: pc popStack).
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> stringClone [
	| low x |
	allocator pushRoot: pc popStack.
	returnedValue := pc popStack.
	allocator pushRoot: returnedValue.
	low := memory sizeOfObjectAt: returnedValue.
	returnedValue := allocator gcIAlloc: low.
	messageSelector := allocator popRoot.
	0 to: low - 1 do: [ :each | 
		x := memory objectAt: messageSelector byteAt: each.
		memory objectAt: returnedValue byteAt: each put: x ].
	memory objectAt: returnedValue class: allocator popRoot.
	self doReturn
]

{ #category : #accessing }
LInterpreter >> ticks [
	^ ticks
]

{ #category : #accessing }
LInterpreter >> ticks: anObject [
	ticks := anObject
]

{ #category : #'dispatch primitives' }
LInterpreter >> truncateInteger [
	| op arr x |
	op := pc popStack.
	arr := memory byteArrayOfObjectAt: op.
	x := self largeIntegerFrom: arr.
	x := x bitAnd: 16rFFFF.
	returnedValue := memory newSmallInteger: x.
	self doReturn
]

{ #category : #'dispatch primitives' }
LInterpreter >> turnOnDebugging [
	"debugging := true."
	returnedValue := env nilObject.
	self doReturn
]

{ #category : #constants }
LInterpreter >> valSize [
	^ 2
]
