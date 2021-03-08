Class {
	#name : #LProcessor,
	#superclass : #Object,
	#traits : 'TLProcessSize + TLMethodSize + TLInstructions + TLBlockSize',
	#classTraits : 'TLProcessSize classTrait + TLMethodSize classTrait + TLInstructions classTrait + TLBlockSize classTrait',
	#instVars : [
		'memory',
		'context',
		'method',
		'bp',
		'bytePointer',
		'stack',
		'stackTop',
		'literals',
		'arguments',
		'instanceVariables',
		'temporaries',
		'ticksStack',
		'registerStack'
	],
	#category : #'LSmalltalk-Core'
}

{ #category : #accessing }
LProcessor >> arguments [
	^ arguments
]

{ #category : #accessing }
LProcessor >> arguments: anObject [
	^ arguments := anObject
]

{ #category : #api }
LProcessor >> assignTemporary: anInteger [
	self assureTemporaries.
	memory objectAt: temporaries dataAt: anInteger put: self topOfStack
]

{ #category : #private }
LProcessor >> assureArguments [
	arguments = 0
		ifTrue: [ arguments := memory
				objectAt: context
				dataAt: self argumentsInContext ]
]

{ #category : #private }
LProcessor >> assureInstanceVariables [
	instanceVariables = 0
		ifTrue: [ instanceVariables := memory
				objectAt: arguments
				dataAt: self receiverInArguments ]
]

{ #category : #private }
LProcessor >> assureLiterals [
	literals = 0
		ifTrue: [ literals := memory
				objectAt: method
				dataAt: self literalsInMethod ]
]

{ #category : #private }
LProcessor >> assureTemporaries [
	temporaries = 0
		ifTrue: [ temporaries := memory
				objectAt: context
				dataAt: self temporariesInContext ]
]

{ #category : #accessing }
LProcessor >> bp [
	^ bp
]

{ #category : #accessing }
LProcessor >> bp: anObject [
	bp := anObject
]

{ #category : #accessing }
LProcessor >> bytePointer [
	^ bytePointer
]

{ #category : #accessing }
LProcessor >> bytePointer: anObject [
	bytePointer := anObject
]

{ #category : #api }
LProcessor >> clearBytePointerOfContext [
	memory
		objectAt: context
		dataAt: self bytePointerInContext
		put: (memory newSmallInteger: 0)
]

{ #category : #api }
LProcessor >> clearDouble [
	literals := instanceVariables := 0
]

{ #category : #api }
LProcessor >> clearQuad [
	arguments := instanceVariables := literals := temporaries := 0
]

{ #category : #api }
LProcessor >> clearStackTop [
	stackTop := 0
]

{ #category : #api }
LProcessor >> clearStackTopOfContext [
	memory
		objectAt: context
		dataAt: self stackTopInContext
		put: (memory newSmallInteger: 0)
]

{ #category : #api }
LProcessor >> clearTriplet [
	arguments := instanceVariables := literals := 0
]

{ #category : #api }
LProcessor >> clearTriplet2 [
	instanceVariables := temporaries := literals := 0
]

{ #category : #accessing }
LProcessor >> context [
	^ context
]

{ #category : #accessing }
LProcessor >> context: anObject [
	context := anObject
]

{ #category : #testing }
LProcessor >> existRegisters [
	^ registerStack notEmpty
]

{ #category : #api }
LProcessor >> fetch [
	| code |
	code := memory byteAt: bp + bytePointer.
	bytePointer := bytePointer + 1.
	^ code
]

{ #category : #api }
LProcessor >> fetchAddress [
	^ bp + bytePointer
]

{ #category : #api }
LProcessor >> fetchUint16 [
	| obj |
	obj := self uint16OfBytes.
	bytePointer := bytePointer + self valSize.
	^ obj
]

{ #category : #api }
LProcessor >> getHighLow [
	| op low high |
	op := self popStack.
	(memory isSmallInteger: op)
		ifFalse: [ self popStack.
			^ nil ].
	low := memory smallIntegerValue: op.
	op := self popStack.
	(memory isSmallInteger: op)
		ifFalse: [ ^ nil ].
	high := memory smallIntegerValue: op.
	^ {high.
	low}
]

{ #category : #api }
LProcessor >> getReceiverOfArguments [
	^ memory objectAt: arguments dataAt: self receiverInArguments
]

{ #category : #initialization }
LProcessor >> initialize [
	ticksStack := OrderedCollection new.
	registerStack := OrderedCollection new
]

{ #category : #accessing }
LProcessor >> instanceVariables [
	^ instanceVariables
]

{ #category : #accessing }
LProcessor >> instanceVariables: anObject [
	^ instanceVariables := anObject
]

{ #category : #accessing }
LProcessor >> literals [
	^ literals
]

{ #category : #accessing }
LProcessor >> literals: anObject [
	^ literals := anObject
]

{ #category : #accessing }
LProcessor >> memory [
	^ memory
]

{ #category : #accessing }
LProcessor >> memory: anObject [
	memory := anObject
]

{ #category : #accessing }
LProcessor >> method [
	^ method
]

{ #category : #accessing }
LProcessor >> method: anObject [
	method := anObject
]

{ #category : #api }
LProcessor >> popArguments [
	arguments := self popStack
]

{ #category : #api }
LProcessor >> popRegisters [
	| arr |
	arr := registerStack removeLast.
	context := arr first.
	method := arr second.
	bp := arr third.
	bytePointer := arr fourth.
	stack := arr fifth.
	stackTop := arr sixth.
	literals := arr seventh.
	arguments := arr eighth.
	instanceVariables := arr ninth.
	temporaries := arr at: 10
]

{ #category : #api }
LProcessor >> popStack [
	stackTop := stackTop - 1.
	^ memory objectAt: stack dataAt: stackTop
]

{ #category : #api }
LProcessor >> popTicks [
	ticksStack isEmpty
		ifTrue: [ ^ 0 ].
	^ ticksStack removeLast
]

{ #category : #api }
LProcessor >> preFetch [
	^ memory byteAt: bp + bytePointer
]

{ #category : #api }
LProcessor >> preFetchUint16 [
	| v |
	v := memory byteAt: bp + bytePointer.
	v := v bitOr: ((memory byteAt: bp + bytePointer + 1) << 8).
	^ v
]

{ #category : #api }
LProcessor >> previousContextOfContext [
	^ memory objectAt: context dataAt: self previousContextInContext
]

{ #category : #api }
LProcessor >> pushArguments [
	self pushStack: arguments
]

{ #category : #api }
LProcessor >> pushRegisters [
	registerStack
		add:
			{context.
			method.
			bp.
			bytePointer.
			stack.
			stackTop.
			literals.
			arguments.
			instanceVariables.
			temporaries}
]

{ #category : #api }
LProcessor >> pushStack: anInteger [
	memory objectAt: stack dataAt: stackTop put: anInteger.
	stackTop := stackTop + 1
]

{ #category : #api }
LProcessor >> pushTicks: anInteger [
	ticksStack add: anInteger
]

{ #category : #api }
LProcessor >> putArgumentsOfContext [
	memory
		objectAt: context
		dataAt: self argumentsInContext
		put: arguments
]

{ #category : #api }
LProcessor >> putBytePointerOfContext [
	memory
		objectAt: context
		dataAt: self bytePointerInContext
		put: (memory newSmallInteger: bytePointer)
]

{ #category : #api }
LProcessor >> putCreatingContextOfBlock [
	memory objectAt: context dataAt: self creatingContextInBlock
]

{ #category : #api }
LProcessor >> putMethodOfContext [
	memory objectAt: context dataAt: self methodInContext put: method
]

{ #category : #api }
LProcessor >> putStackOfContext [
	memory objectAt: context dataAt: self stackInContext put: stack
]

{ #category : #api }
LProcessor >> putStackTopOfContext [
	memory
		objectAt: context
		dataAt: self stackTopInContext
		put: (memory newSmallInteger: stackTop)
]

{ #category : #api }
LProcessor >> putTemporariesOfContext [
	memory
		objectAt: context
		dataAt: self temporariesInContext
		put: temporaries
]

{ #category : #accessing }
LProcessor >> registerStack [
	^ registerStack
]

{ #category : #accessing }
LProcessor >> registerStack: anObject [
	registerStack := anObject
]

{ #category : #api }
LProcessor >> rewindePreviousContext [
	context := memory
		objectAt: context
		dataAt: self previousContextInContext
]

{ #category : #api }
LProcessor >> secondOfStack [
	^ memory objectAt: stack dataAt: stackTop - 2
]

{ #category : #api }
LProcessor >> setBpOfMethod [
	| obj |
	obj := memory objectAt: method dataAt: self byteCodesInMethod.
	bp := memory byteAddressOfObjectAt: obj
]

{ #category : #api }
LProcessor >> setBytePointerOfBlock [
	| obj |
	obj := memory objectAt: context dataAt: self bytePointerInBlock.
	bytePointer := memory smallIntegerValue: obj
]

{ #category : #api }
LProcessor >> setBytePointerOfContext [
	| obj |
	obj := memory objectAt: context dataAt: self bytePointerInContext.
	bytePointer := memory smallIntegerValue: obj
]

{ #category : #api }
LProcessor >> setMethodOfBlock [
	method := memory objectAt: context dataAt: self methodInBlock
]

{ #category : #api }
LProcessor >> setMethodOfContext [
	method := memory objectAt: context dataAt: self methodInContext
]

{ #category : #api }
LProcessor >> setStackOfContext [
	stack := memory objectAt: context dataAt: self stackInContext
]

{ #category : #api }
LProcessor >> setStackTopOfContext [
	| obj |
	obj := memory objectAt: context dataAt: self stackTopInContext.
	stackTop := memory smallIntegerValue: obj
]

{ #category : #accessing }
LProcessor >> stack [
	^ stack
]

{ #category : #accessing }
LProcessor >> stack: anObject [
	stack := anObject
]

{ #category : #api }
LProcessor >> stackSizeOfMethod [
	| obj |
	obj := memory objectAt: method dataAt: self stackSizeInMethod.
	^ memory smallIntegerValue: obj
]

{ #category : #accessing }
LProcessor >> stackTop [
	^ stackTop
]

{ #category : #accessing }
LProcessor >> stackTop: anObject [
	stackTop := anObject
]

{ #category : #api }
LProcessor >> startProcess: anInteger [
	context := memory objectAt: anInteger dataAt: self contextInProcess.
	self setMethodOfContext.
	self setBpOfMethod.
	self setBytePointerOfContext.
	self setStackOfContext.
	self setStackTopOfContext.
	self clearQuad
]

{ #category : #accessing }
LProcessor >> temporaries [
	^ temporaries
]

{ #category : #accessing }
LProcessor >> temporaries: anObject [
	temporaries := anObject
]

{ #category : #api }
LProcessor >> temporarySizeOfMethod [
	| obj |
	obj := memory objectAt: method dataAt: self temporarySizeInMethod.
	^ memory smallIntegerValue: obj
]

{ #category : #accessing }
LProcessor >> ticksStack [
	^ ticksStack
]

{ #category : #accessing }
LProcessor >> ticksStack: anObject [
	ticksStack := anObject
]

{ #category : #private }
LProcessor >> topOfStack [
	^ memory objectAt: stack dataAt: stackTop - 1 
]

{ #category : #private }
LProcessor >> uint16OfBytes [
	| low high |
	low := memory byteAt: bp + bytePointer.
	high := memory byteAt: bp + bytePointer + 1.
	^ low bitOr: (high << 8)
]

{ #category : #constants }
LProcessor >> valSize [
	^ 2
]
