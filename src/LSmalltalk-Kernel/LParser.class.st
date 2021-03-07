Class {
	#name : #LParser,
	#superclass : #LObject,
	#instVars : [
		'text',
		'index',
		'tokenType',
		'token',
		'argNames',
		'tempNames',
		'instNames',
		'maxTemps',
		'errBlock',
		'lineNum'
	],
	#category : #'LSmalltalk-Kernel'
}

{ #category : #adding }
LParser >> addArgName: name [
	((instNames includes: name)
		or: [ argNames includes: name ])
		ifTrue: [ self error: 'doubly defined argument name: ' +
			name asString].
	argNames := argNames with: name
]

{ #category : #adding }
LParser >> addTempName: name [
	(((argNames includes: name)
		or: [ instNames includes: name ] )
		or: [ tempNames includes: name ] )
		ifTrue: [ self error: 'doubly defined name '].
	tempNames := tempNames with: name.
	maxTemps := maxTemps max: tempNames size
]

{ #category : #'as yet unclassified' }
LParser >> arrayLiteral [	| node |
	tokenType isAlphabetic
		ifTrue: [ node := LSymbol new: token. self nextLex. ^ node ].
	^ self readLiteral
]

{ #category : #'as yet unclassified' }
LParser >> binaryContinuation: base [ | receiver name lnum |
	receiver := self unaryContinuation: base.
	[ self tokenIsBinary]
		whileTrue: [ lnum := lineNum.
			name := token asSymbol. self nextLex.
			receiver := (LMessageNode at: lnum)
				receiver: receiver name: name arguments:
					(LList with:
						(self unaryContinuation: self readTerm)) ].
	^ receiver
]

{ #category : #'as yet unclassified' }
LParser >> charIsSyntax: c [
	^ ('.()[]#^$;' includes: c) or: [ c = $' ]
]

{ #category : #'as yet unclassified' }
LParser >> currentChar [
	^ text at: index ifAbsent: [ LChar eof ]
]

{ #category : #'error handling' }
LParser >> error: aString [
	'Compile error near line ' print.
	lineNum printString print.
	': ' print.
	aString printNl.
	errBlock value
]

{ #category : #'as yet unclassified' }
LParser >> keywordContinuation: base [  | receiver name args lnum |
	receiver := self binaryContinuation: base.
	self tokenIsKeyword
		ifFalse: [ ^ receiver ].
	name := ''.
	args := LList new.
	lnum := lineNum.
	[ self tokenIsKeyword ]
		whileTrue: [ name := name + token. self nextLex.
			args add:
				(self binaryContinuation: self readTerm) ].
	^ (LMessageNode at: lnum) receiver:
		receiver name: name asSymbol arguments: args
]

{ #category : #'as yet unclassified' }
LParser >> lexAlnum [ | cc start |
	start := index.
	[ ((cc := self nextChar) isAlphanumeric) or: [ cc = $: ] ]
			whileTrue: [ nil ].
		" add any trailing colons "
	token := text from: start to: index - 1
]

{ #category : #'as yet unclassified' }
LParser >> lexBinary [	| c d |
	c := self currentChar.
	token := c asString.
	d := self nextChar.
	(self charIsSyntax: c) ifTrue: [ ^ token ].
	(((d isBlank
		or: [ d isDigit])
		or: [ d isAlphabetic ])
		or: [ self charIsSyntax: d])
			ifTrue: [ ^ token ].
	token := token + d asString.
	self nextChar
]

{ #category : #'as yet unclassified' }
LParser >> lexInteger [	| start |
	start := index.
	[ self nextChar isDigit ]
		whileTrue: [ nil ].
	token := text from: start to: index - 1
]

{ #category : #'as yet unclassified' }
LParser >> nameNode: name [
	" make a new name node "
	| tmp |
	name == #super
		ifTrue: [ ^ (LArgumentNode at: lineNum) position: 0 ].
	(1 to: tempNames size) do: [:i |
		(name == (tempNames at: i))
			ifTrue: [ ^ (LTemporaryNode at: lineNum)
				position: i ] ].
	(1 to: argNames size) do: [:i |
		(name == (argNames at: i))
			ifTrue: [ ^ (LArgumentNode at: lineNum) position: i ] ].
	(1 to: instNames size) do: [:i |
		(name == (instNames at: i))
			ifTrue: [ ^ (LInstNode at: lineNum) position: i ] ].
	tmp := (LLiteralNode at: lineNum).
	^ tmp
		value: (LSmalltalk at: name
			ifAbsent: [ ^ self error:
				'unrecognized name: ' + name printString ])
]

{ #category : #utilities }
LParser >> nextChar [
	(self currentChar = LChar newline) ifTrue: [
		lineNum := lineNum + 1
	].
	index := index + 1.
	^ self currentChar
]

{ #category : #'as yet unclassified' }
LParser >> nextLex [	
	self skipBlanks.
	tokenType := self currentChar.
	tokenType isEOF   " end of input "
		ifTrue: [ tokenType := $  . token := nil. ^ nil ].
	tokenType isDigit ifTrue: [ ^ self lexInteger ].
	tokenType isAlphabetic ifTrue: [ ^ self lexAlnum ].
	^ self lexBinary
]

{ #category : #parsing }
LParser >> parse: c [
	^ self parse: c with: LEncoder
]

{ #category : #parsing }
LParser >> parse: c with: encoderClass [	| encoder meth name |
	" note -- must call text:instanceVars: first "
	errBlock := [ ^ nil ].
	self nextLex.
	encoder := encoderClass new.
	name := self readMethodName.
	(c ~= LUndefined) ifTrue: [
		'Compiling ' print. c print. ':' print.
		name print. '... ' print
	].
	encoder name: name.
	self readMethodVariables.
	self readBody compile: encoder block: false.
	meth := encoder method: maxTemps class: c text: text.
	meth args: argNames inst: instNames temp: tempNames.
	^ meth
]

{ #category : #'write and read' }
LParser >> readArray [	| value |
	self nextChar. self nextLex. value := LArray new: 0.
	[ tokenType ~= $) ]
		whileTrue: [ value := value with: self arrayLiteral ].
	self nextLex.
	^ value
]

{ #category : #'as yet unclassified' }
LParser >> readBlock [    | stmts saveTemps lnum |
	saveTemps := tempNames.
	lnum := lineNum.
	self nextLex.
	tokenType = $:
		ifTrue: [ self readBlockTemporaries ].
	stmts := self readStatementList.
	tempNames := saveTemps.
	tokenType = $]
		ifTrue: [ self nextLex.
			^ (LBlockNode at: lnum) statements: stmts
				temporaryLocation: saveTemps size ]
		ifFalse: [ self error: 'unterminated block']
]

{ #category : #'as yet unclassified' }
LParser >> readBlockTemporaries [
	[ tokenType = $: ]
		whileTrue: [ self currentChar isAlphabetic
			ifFalse: [ self error: 'ill formed block argument'].
			self nextLex.
			self tokenIsName
				ifTrue: [ self addTempName: token asSymbol ]
				ifFalse: [ self error: 'invalid block argument list '].
			self nextLex ].
	tokenType = $|
		ifTrue: [ self nextLex ]
		ifFalse: [ self error: 'invalid block argument list ']
]

{ #category : #'private-decoding' }
LParser >> readBody [ | lnum |
	lnum := lineNum.
	^ (LBodyNode at: lnum) statements: self readStatementList
]

{ #category : #'as yet unclassified' }
LParser >> readCascade: base [   | node list |
	node := self keywordContinuation: base.
	tokenType = $;
		ifTrue: [ node := (LCascadeNode at: lineNum) head: node.
			list := LList new.
			[ tokenType = $; ]
				whileTrue: [ self nextLex.
					list add:
						(self keywordContinuation: nil ) ].
			node list: list ].
	^ node
]

{ #category : #'as yet unclassified' }
LParser >> readExpression [   | node lnum |
	self tokenIsName ifFalse: [ ^ self readCascade: self readTerm ].
	node := self nameNode: token asSymbol. self nextLex.
	self tokenIsArrow
		ifTrue: [ node assignable
				ifFalse: [ self error: 'illegal assignment'].
			lnum := lineNum.
			self nextLex.
			^ (LAssignNode at: lnum) target:
				node expression: self readExpression ].
	^ self readCascade: node
]

{ #category : #private }
LParser >> readInteger [  | value |
	value := token asNumber.
	value isNil ifTrue: [ self error: 'integer expected' ].
	self nextLex.
	^ value
]

{ #category : #'as yet unclassified' }
LParser >> readLiteral [   | node |
	tokenType = $$
		ifTrue: [ node := self currentChar.
			self nextChar. self nextLex. ^ node ].
	tokenType isDigit
		ifTrue: [ ^ self readInteger ].
	token = '-'
		ifTrue: [ self nextLex. ^ self readInteger negated ].
	tokenType = $'
		ifTrue: [ ^ self readString ].
	tokenType = $#
		ifTrue: [ ^ self readSymbol ].
	self error: 'invalid literal: ' + token
]

{ #category : #'as yet unclassified' }
LParser >> readMethodName [   | name |
	self tokenIsName	" unary method "
		ifTrue: [ name := token. self nextLex. ^ name ].
	self tokenIsBinary	" binary method "
		ifTrue: [ name := token. self nextLex.
			self tokenIsName
				ifFalse: [ self error: 'missing argument'].
				self addArgName: token asSymbol.
				self nextLex. ^ name ].
	self tokenIsKeyword
		ifFalse: [ self error: 'invalid method header'].
	name := ''.
	[ self tokenIsKeyword ]
		whileTrue: [ name := name + token. self nextLex.
			self tokenIsName
				ifFalse: [ self error: 'missing argument'].
				self addArgName: token asSymbol.
				self nextLex ].
	^ name
]

{ #category : #'as yet unclassified' }
LParser >> readMethodVariables [
	tokenType = $| ifFalse: [ ^ nil ].
	self nextLex.
	[ self tokenIsName ]
		whileTrue: [ self addTempName: token asSymbol. self nextLex ].
	tokenType = $|
		ifTrue: [ self nextLex ]
		ifFalse: [ self error: 'illegal method variable declaration']
]

{ #category : #'as yet unclassified' }
LParser >> readPrimitive [  | num args lnum |
	lnum := lineNum.
	self nextLex.
	num := self readInteger.
	args := LList new.
	[ tokenType ~= $> ]
		whileTrue: [ args add: self readTerm ].
	self nextLex.
	^ (LPrimitiveNode at: lnum) number: num arguments: args
]

{ #category : #'as yet unclassified' }
LParser >> readStatement [ | lnum |
	tokenType = $^
		ifTrue: [ lnum := lineNum. self nextLex.
			^ (LReturnNode at: lnum)
				expression: self readExpression ].
	^ self readExpression
]

{ #category : #'as yet unclassified' }
LParser >> readStatementList [   | list |
	list := LList new.
	[ list add: self readStatement.
	  tokenType notNil and: [ tokenType = $. ] ]
		whileTrue: [ self nextLex.
			(token isNil or: [ tokenType = $] ] )
				ifTrue: [ ^ list ] ].
	^ list
]

{ #category : #'write and read' }
LParser >> readString [  | first last cc |
	first := index.
	[ cc := self currentChar.
	  cc isNil ifTrue: [ self error: 'unterminated string constant'].
	  cc ~= $' ] whileTrue: [ index := index + 1 ].
	last := index - 1.
	self nextChar = $'
		ifTrue: [ self nextChar.
			^ (text from: first to: index - 2) + self readString ].
	self nextLex.
	^ text from: first to: last
]

{ #category : #'write and read' }
LParser >> readSymbol [   | cc |
	cc := self currentChar.
	(cc isEOF or: [ cc isBlank])
		ifTrue: [ self error: 'invalid symbol'].
	cc = $( ifTrue: [ ^ self readArray ].
	(self charIsSyntax: cc)
		ifTrue: [ self error: 'invalid symbol'].
	self nextLex.
	cc := LSymbol new: token. self nextLex.
	^ cc
]

{ #category : #'as yet unclassified' }
LParser >> readTerm [   | node lnum |
	token isNil
		ifTrue: [ self error: 'unexpected end of input' ].
	tokenType = $(
		ifTrue: [ self nextLex. node := self readExpression.
			tokenType = $)
				ifFalse: [ self error: 'unbalanced parenthesis' ].
			self nextLex. ^ node ].
	tokenType = $[ ifTrue: [ ^ self readBlock ].
	tokenType = $< ifTrue: [ ^ self readPrimitive ].
	self tokenIsName
		ifTrue: [ node := self nameNode: token asSymbol.
			self nextLex. ^ node ].
	lnum := lineNum.
	^ (LLiteralNode at: lnum) value: self readLiteral
]

{ #category : #'as yet unclassified' }
LParser >> skipBlanks [  | cc |
	cc := self currentChar.
	[ cc isBlank ] whileTrue: [ cc := self nextChar ].
	( cc = $" ) ifTrue: [ self skipComment ]
]

{ #category : #'as yet unclassified' }
LParser >> skipComment [  | cc |
	[ cc := self nextChar.
	  cc isEOF ifTrue: [ ^ self error: 'unterminated comment'].
	  cc ~= $" ] whileTrue: [ nil ].
	self nextChar. self skipBlanks
]

{ #category : #'as yet unclassified' }
LParser >> text: aString instanceVars: anArray [
	text := aString.
	index := 1.
	lineNum := 1.
	argNames := LArray new: 1.
	argNames at: 1 put: #self.
	instNames := anArray.
	tempNames := LArray new: 0.
	maxTemps := 0
]

{ #category : #'as yet unclassified' }
LParser >> tokenIsArrow [
	(token isKindOf: LString) ifFalse: [ ^ false ].
	^ token = ':='
]

{ #category : #'as yet unclassified' }
LParser >> tokenIsBinary [
	(((token isNil
		or: [ self tokenIsName])
		or: [ self tokenIsKeyword])
		or: [ self charIsSyntax: tokenType ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : #'as yet unclassified' }
LParser >> tokenIsKeyword [
	tokenType isAlphabetic ifFalse: [ ^ false ].
	^ (token at: token size) = $:
]

{ #category : #'as yet unclassified' }
LParser >> tokenIsName [
	tokenType isAlphabetic ifFalse: [ ^ false ].
	^ (token at: token size) isAlphanumeric
]

{ #category : #'as yet unclassified' }
LParser >> unaryContinuation: base [ | receiver lnum |
	receiver := base.
	[ self tokenIsName ]
		whileTrue: [ lnum := lineNum.
			receiver := (LMessageNode at: lnum)
				receiver: receiver name: token asSymbol
					arguments: (LList new).
				self nextLex ].
	^ receiver
]
