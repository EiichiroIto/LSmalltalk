Class {
	#name : #LCompiler,
	#superclass : #Object,
	#traits : 'TLInstructions',
	#classTraits : 'TLInstructions classTrait',
	#instVars : [
		'source',
		'bytes',
		'returnOp',
		'literals',
		'maxTemp',
		'temporaries',
		'blockBackup',
		'arguments',
		'superMessage',
		'globals',
		'instanceVariables'
	],
	#category : #'LSmalltalk-Tools'
}

{ #category : #private }
LCompiler >> addArgument: aString [
	arguments add: aString
]

{ #category : #private }
LCompiler >> addLiteral: anObject [
	| i |
	i := literals indexOf: anObject.
	i > 0
		ifTrue: [ ^ i - 1 ].
	literals add: anObject.
	^ literals size - 1
]

{ #category : #private }
LCompiler >> addTemporary: aString [
	(self isIdentifier: aString)
		ifFalse: [ self error: 'illegal identifier' ].
	temporaries add: aString.
	maxTemp := temporaries size max: maxTemp
]

{ #category : #accessing }
LCompiler >> arguments [
	^ arguments
]

{ #category : #accessing }
LCompiler >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
LCompiler >> blockBackup [
	^ blockBackup
]

{ #category : #accessing }
LCompiler >> blockBackup: anObject [
	blockBackup := anObject
]

{ #category : #private }
LCompiler >> byteTop [
	^ bytes size
]

{ #category : #accessing }
LCompiler >> bytes [
	^ bytes
]

{ #category : #accessing }
LCompiler >> bytes: anObject [
	bytes := anObject
]

{ #category : #private }
LCompiler >> clearTemporaries [
	temporaries := OrderedCollection new.
	maxTemp := 0
]

{ #category : #api }
LCompiler >> compile [
	| n |
	n := self parserClass parseMethod: source.
	self parseArguments: n arguments.
	self parseTemporaries: n temporaries.
	(self parseBody: n)
		ifFalse: [ ^ nil ].
	^ {n selector.
	literals asArray.
	bytes asArray.
	19.
	maxTemp}
]

{ #category : #api }
LCompiler >> compileExpression [
	| n |
	n := self parserClass parseExpression: source.
	self parseArguments: n arguments.
	(self parseExpression: n)
		ifFalse: [ ^ nil ].
	self genInstruction: self doSpecial and: self selfReturn.
	^ {n selector.
	literals asArray.
	bytes asArray.
	19.
	maxTemp}
]

{ #category : #generating }
LCompiler >> controlFlow: aNode op: anInteger with: anInteger4 [
	| save1 save2 |
	self genInstruction: self doSpecial and: anInteger.
	save1 := self byteTop.
	self genVal: 0.
	(self optimizeBlock: aNode arguments first body)
		ifFalse: [ self error: 'syntax error in control flow' ].
	self genInstruction: self doSpecial and: self branch.
	save2 := self byteTop.
	self genVal: 0.
	self genVal: self byteTop at: save1.
	aNode arguments size > 1
		ifTrue: [ (self optimizeBlock: aNode arguments second body)
				ifFalse: [ self error: 'syntax error in control cascade' ] ]
		ifFalse: [ self genInstruction: self pushConstant and: anInteger4 ].
	self genVal: self byteTop at: save2.
	^ true
]

{ #category : #generating }
LCompiler >> doAssignment: aString [
	| i |
	i := temporaries indexOf: aString.
	i > 0
		ifTrue: [ self genInstruction: self assignTemporary and: i - 1.
			^ true ].
	i := self lookupInstance: aString.
	i > 0
		ifTrue: [ self genInstruction: self assignInstance and: i - 1.
			^ true ].
	self error: 'unknown target of assignment"'
]

{ #category : #accessing }
LCompiler >> failBlock: aBlock [
	"do nothing"
]

{ #category : #generating }
LCompiler >> genByte: anInteger [
	bytes add: (anInteger bitAnd: 16rFF)
]

{ #category : #generating }
LCompiler >> genInstruction: anInteger and: anInteger2 [
	anInteger2 < 16
		ifTrue: [ self genByte: anInteger * 16 + anInteger2 ]
		ifFalse: [ self genInstruction: 0 and: anInteger.
			self genByte: anInteger2 ]
]

{ #category : #generating }
LCompiler >> genLiteral: anObject [
	| v |
	anObject
		ifNil: [ ^ self genInstruction: self pushConstant and: self nilConst ].
	(anObject isKindOf: Boolean)
		ifTrue: [ anObject
				ifTrue: [ self genInstruction: self pushConstant and: self trueConst ]
				ifFalse: [ self genInstruction: self pushConstant and: self falseConst ].
			^ self ].
	(anObject isNumber and: [ anObject between: 0 and: 9 ])
		ifTrue: [ ^ self genInstruction: self pushConstant and: anObject ].
	v := self addLiteral: anObject.
	self genInstruction: self pushLiteral and: v
]

{ #category : #generating }
LCompiler >> genVal: anInteger [
	(anInteger < 0 or: [ anInteger > 16rFFFF ])
		ifTrue: [ self error: 'illegal value' ].
	self genByte: (anInteger bitAnd: 16rFF).
	self genByte: anInteger >> 8
]

{ #category : #generating }
LCompiler >> genVal: anInteger at: anInteger2 [
	(anInteger < 0 or: [ anInteger > 16rFFFF ])
		ifTrue: [ self error: 'illegal value' ].
	bytes at: anInteger2 + 1 put: (anInteger bitAnd: 16rFF).
	bytes at: anInteger2 + 2 put: ((anInteger >> 8) bitAnd: 16rFF)
]

{ #category : #accessing }
LCompiler >> globals [
	^ globals
]

{ #category : #accessing }
LCompiler >> globals: anObject [
	globals := anObject
]

{ #category : #initialization }
LCompiler >> initialize [
	literals := OrderedCollection new.
	bytes := OrderedCollection new.
	arguments := OrderedCollection new.
	self addArgument: 'self'.
	self clearTemporaries
]

{ #category : #accessing }
LCompiler >> instanceVariables [
	^ instanceVariables
]

{ #category : #accessing }
LCompiler >> instanceVariables: anObject [
	instanceVariables := anObject
]

{ #category : #testing }
LCompiler >> isIdentifier: aString [
	^ aString asSymbol isKeyword not
]

{ #category : #accessing }
LCompiler >> literals [
	^ literals
]

{ #category : #accessing }
LCompiler >> literals: anObject [
	literals := anObject
]

{ #category : #private }
LCompiler >> lookupGlobal: aString [
	^ globals at: aString asSymbol
]

{ #category : #private }
LCompiler >> lookupInstance: aString [
	^ instanceVariables indexOf: aString
]

{ #category : #accessing }
LCompiler >> maxTemp [
	^ maxTemp
]

{ #category : #accessing }
LCompiler >> maxTemp: anObject [
	maxTemp := anObject
]

{ #category : #generating }
LCompiler >> nameTerm: aString [
	| i v |
	i := temporaries indexOf: aString.
	i > 0
		ifTrue: [ self genInstruction: self pushTemporary and: i - 1.
			^ true ].
	i := arguments indexOf: aString.
	i > 0
		ifTrue: [ self genInstruction: self pushArgument and: i - 1.
			^ true ].
	i := self lookupInstance: aString.
	i > 0
		ifTrue: [ self genInstruction: self pushInstance and: i - 1.
			^ true ].
	i := self lookupGlobal: aString.
	i > 0
		ifTrue: [ v := self addLiteral: aString.
			self genInstruction: self pushLiteral and: v.
			^ true ].
	self error: 'unknown identifier'
]

{ #category : #generating }
LCompiler >> optimizeBlock: aNode [
	aNode statements isEmpty
		ifTrue: [ self genInstruction: self pushConstant and: 0.
			^ true ].
	aNode statements
		do: [ :each | self parseStatement: each ]
		separatedBy: [ self genInstruction: self doSpecial and: self popTop ].
	^ true
]

{ #category : #generating }
LCompiler >> optimizeLoop: aNode op: anInteger [
	| l1 l2 |
	l1 := self byteTop.
	self optimizeBlock: blockBackup.
	self genInstruction: self doSpecial and: anInteger.
	l2 := self byteTop.
	self genVal: 0.
	self optimizeBlock: aNode arguments first body.
	self genInstruction: self doSpecial and: self popTop.
	self genInstruction: self doSpecial and: self branch.
	self genVal: l1.
	self genVal: self byteTop at: l2.
	self genInstruction: self pushConstant and: 0.
	^ true
]

{ #category : #parsing }
LCompiler >> parseArguments: aCollection [
	aCollection do: [ :each | self addArgument: each value name ].
	^ true
]

{ #category : #parsing }
LCompiler >> parseAssignment: aNode [
	(self parseExpression: aNode value)
		ifFalse: [ ^ false ].
	^ self doAssignment: aNode variable name
]

{ #category : #parsing }
LCompiler >> parseBinaryMessage: aNode [
	| litNumber |
	self parseExpression: aNode receiver.
	self parseExpression: aNode arguments first.
	aNode selector = #<
		ifTrue: [ self genInstruction: self sendBinary and: self lessThanConst.
			^ true ].
	aNode selector = #<=
		ifTrue: [ self genInstruction: self sendBinary and: self lessEqualConst.
			^ true ].
	aNode selector = #+
		ifTrue: [ self genInstruction: self sendBinary and: self plusConst.
			^ true ].
	self genInstruction: self markArguments and: 2.
	litNumber := self addLiteral: aNode selector.
	superMessage
		ifTrue: [ self genInstruction: self doSpecial and: self sendToSuper.
			self genByte: litNumber.
			superMessage := 0 ]
		ifFalse: [ self genInstruction: self sendMessage and: litNumber ].
	^ true
]

{ #category : #parsing }
LCompiler >> parseBlock: aNode [
	| savedLocation saveTop saveReturnOp |
	self genInstruction: self pushBlock and: self tempTop.
	savedLocation := self byteTop.
	self genVal: 0.
	saveTop := self tempTop.
	aNode arguments do: [ :each | self addTemporary: each name ].
	aNode body statements isEmpty
		ifTrue: [ self genInstruction: self pushConstant and: self nilConst ]
		ifFalse: [ saveReturnOp := returnOp.
			returnOp := self blockReturn.
			aNode body statements
				do: [ :each | 
					(self parseStatement: each)
						ifFalse: [ self error: 'Statement syntax inside block' ] ]
				separatedBy: [ self genInstruction: self doSpecial and: self popTop ].
			returnOp := saveReturnOp ].
	self genInstruction: self doSpecial and: self stackReturn.
	self genVal: self byteTop at: savedLocation.
	self tempTop: saveTop.
	blockBackup := aNode.
	^ true
]

{ #category : #parsing }
LCompiler >> parseBody: aNode [
	returnOp := self stackReturn.
	aNode statements
		do: [ :each | 
			(self parseStatement: each)
				ifFalse: [ ^ false ].
			self genInstruction: self doSpecial and: self popTop ].
	self genInstruction: self doSpecial and: self selfReturn.
	^ true
]

{ #category : #parsing }
LCompiler >> parseExpression: aNode [
	(self parseTerm: aNode)
		ifTrue: [ ^ true ].
	aNode isAssignment
		ifTrue: [ ^ self parseAssignment: aNode ].
	aNode isMessage
		ifTrue: [ ^ self parseMessage: aNode ].
	self error
]

{ #category : #parsing }
LCompiler >> parseKeywordMessage: aNode [
	| litNumber |
	self parseExpression: aNode receiver.
	aNode selector = 'ifTrue:'
		ifTrue:
			[ ^ self controlFlow: aNode op: self branchIfFalse with: self nilConst ].
	aNode selector = 'ifTrue:ifFalse:'
		ifTrue:
			[ ^ self controlFlow: aNode op: self branchIfFalse with: self nilConst ].
	aNode selector = 'ifFalse:'
		ifTrue:
			[ ^ self controlFlow: aNode op: self branchIfTrue with: self nilConst ].
	aNode selector = 'ifFalse:ifTrue:'
		ifTrue:
			[ ^ self controlFlow: aNode op: self branchIfTrue with: self nilConst ].
	aNode selector = 'and:'
		ifTrue: [ ^ self
				controlFlow: aNode
				op: self branchIfFalse
				with: self falseConst ].
	aNode selector = 'or:'
		ifTrue:
			[ ^ self controlFlow: aNode op: self branchIfTrue with: self trueConst ].
	(aNode selector = 'whileTrue:' and: [ blockBackup notNil ])
		ifTrue: [ ^ self optimizeLoop: aNode op: self branchIfFalse ].
	(aNode selector = 'whileFalse:' and: [ blockBackup notNil ])
		ifTrue: [ ^ self optimizeLoop: aNode op: self branchIfTrue ].
	aNode arguments do: [ :each | self parseExpression: each ].
	self genInstruction: self markArguments and: aNode arguments size + 1.
	litNumber := self addLiteral: aNode selector.
	superMessage
		ifTrue: [ self genInstruction: self doSpecial and: self sendToSuper.
			self genByte: litNumber.
			superMessage := 0 ]
		ifFalse: [ self genInstruction: self sendMessage and: litNumber ].
	^ true
]

{ #category : #parsing }
LCompiler >> parseMessage: aNode [
	aNode selector isUnary
		ifTrue: [ ^ self parseUnaryMessage: aNode ].
	aNode selector isBinary
		ifTrue: [ ^ self parseBinaryMessage: aNode ].
	(aNode selector beginsWith: 'primNo:')
		ifTrue: [ ^ self parsePrimitive: aNode ].
	^ self parseKeywordMessage: aNode
]

{ #category : #parsing }
LCompiler >> parsePrimitive: aNode [
	| primitiveNumber argumentCount |
	aNode arguments isEmpty
		ifTrue: [ self error: 'missing primitive number' ].
	primitiveNumber := aNode arguments first value.
	argumentCount := aNode arguments size - 1.
	2 to: aNode arguments size do: [ :index | 
		(self parseTerm: (aNode arguments at: index))
			ifFalse: [ ^ false ] ].
	self genInstruction: self doPrimitive and: argumentCount.
	self genByte: primitiveNumber.
	^ true
]

{ #category : #parsing }
LCompiler >> parseStatement: aNode [
	aNode isReturn
		ifTrue: [ (self parseExpression: aNode value)
				ifFalse: [ ^ false ].
			self genInstruction: self doSpecial and: returnOp.
			^ true ].
	^ self parseExpression: aNode
]

{ #category : #parsing }
LCompiler >> parseTemporaries: aCollection [
	self clearTemporaries.
	aCollection do: [ :each | self addTemporary: each value name ].
	^ true
]

{ #category : #parsing }
LCompiler >> parseTerm: aNode [
	blockBackup := nil.
	superMessage := false.
	aNode isLiteralNode
		ifTrue: [ self genLiteral: aNode value.
			^ true ].
	aNode isBlock
		ifTrue: [ ^ self parseBlock: aNode ].
	aNode isVariable
		ifTrue: [ aNode isSuper
				ifTrue: [ self genInstruction: self pushArgument and: 0.
					superMessage := true ]
				ifFalse: [ self nameTerm: aNode value name ].
			^ true ].
	^ false
]

{ #category : #parsing }
LCompiler >> parseUnaryMessage: aNode [
	| litNumber |
	self parseExpression: aNode receiver.
	aNode selector = #isNil
		ifTrue: [ self genInstruction: self sendUnary and: self isNilConst.
			^ true ].
	aNode selector = #notNil
		ifTrue: [ self genInstruction: self sendUnary and: self notNilConst.
			^ true ].
	self genInstruction: self markArguments and: 1.
	litNumber := self addLiteral: aNode selector.
	superMessage
		ifTrue: [ self genInstruction: self doSpecial and: self sendToSuper.
			self genByte: litNumber.
			superMessage := false ]
		ifFalse: [ self genInstruction: self sendMessage and: litNumber ].
	^ true
]

{ #category : #private }
LCompiler >> parserClass [
	^ RBParser
]

{ #category : #accessing }
LCompiler >> requestor: anObject [
	"do nothing"
]

{ #category : #accessing }
LCompiler >> returnOp [
	^ returnOp
]

{ #category : #accessing }
LCompiler >> returnOp: anObject [
	returnOp := anObject
]

{ #category : #accessing }
LCompiler >> source [
	^ source
]

{ #category : #accessing }
LCompiler >> source: anObject [
	source := anObject
]

{ #category : #accessing }
LCompiler >> superMessage [
	^ superMessage
]

{ #category : #accessing }
LCompiler >> superMessage: anObject [
	superMessage := anObject
]

{ #category : #private }
LCompiler >> tempTop [
	^ temporaries size
]

{ #category : #private }
LCompiler >> tempTop: anInteger [
	temporaries := temporaries copyFrom: 1 to: anInteger
]

{ #category : #accessing }
LCompiler >> temporaries [
	^ temporaries
]

{ #category : #accessing }
LCompiler >> temporaries: anObject [
	temporaries := anObject
]
