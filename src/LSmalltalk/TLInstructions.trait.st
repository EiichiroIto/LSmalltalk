Trait {
	#name : #TLInstructions,
	#category : #'LSmalltalk-Tools'
}

{ #category : #constants }
TLInstructions >> assignInstance [
	^ 6
]

{ #category : #constants }
TLInstructions >> assignTemporary [
	^ 7
]

{ #category : #constants }
TLInstructions >> blockReturn [
	^ 3
]

{ #category : #constants }
TLInstructions >> branch [
	^ 6
]

{ #category : #constants }
TLInstructions >> branchIfFalse [
	^ 8
]

{ #category : #constants }
TLInstructions >> branchIfTrue [
	^ 7
]

{ #category : #constants }
TLInstructions >> breakpoint [
	^ 12

]

{ #category : #constants }
TLInstructions >> doPrimitive [
	^ 13
]

{ #category : #constants }
TLInstructions >> doSpecial [
	^ 15
]

{ #category : #constants }
TLInstructions >> duplicate [
	^ 4
]

{ #category : #constants }
TLInstructions >> extended [
	^ 0
]

{ #category : #constants }
TLInstructions >> falseConst [
	^ 12
]

{ #category : #constants }
TLInstructions >> isNilConst [
	^ 0
]

{ #category : #constants }
TLInstructions >> lessEqualConst [
	^ 1
]

{ #category : #constants }
TLInstructions >> lessThanConst [
	^ 0
]

{ #category : #constants }
TLInstructions >> markArguments [
	^ 8
]

{ #category : #constants }
TLInstructions >> nilConst [
	^ 10
]

{ #category : #constants }
TLInstructions >> notNilConst [
	^ 1
]

{ #category : #constants }
TLInstructions >> plusConst [
	^ 2
]

{ #category : #constants }
TLInstructions >> popTop [
	^ 5
]

{ #category : #constants }
TLInstructions >> pushArgument [
	^ 2
]

{ #category : #constants }
TLInstructions >> pushBlock [
	^ 12
]

{ #category : #constants }
TLInstructions >> pushConstant [
	^ 5
]

{ #category : #constants }
TLInstructions >> pushInstance [
	^ 1
]

{ #category : #constants }
TLInstructions >> pushLiteral [
	^ 4
]

{ #category : #constants }
TLInstructions >> pushTemporary [
	^ 3
]

{ #category : #constants }
TLInstructions >> selfReturn [
	^ 1
]

{ #category : #constants }
TLInstructions >> sendBinary [
	^ 11
]

{ #category : #constants }
TLInstructions >> sendMessage [
	^ 9
]

{ #category : #constants }
TLInstructions >> sendToSuper [
	^ 11
]

{ #category : #constants }
TLInstructions >> sendUnary [
	^ 10
]

{ #category : #constants }
TLInstructions >> stackReturn [
	^ 2
]

{ #category : #constants }
TLInstructions >> trueConst [
	^ 11
]
