Trait {
	#name : #TLProcessSize,
	#category : #'LSmalltalk-Core'
}

{ #category : #constants }
TLProcessSize >> argumentsInContext [
	^ 1
]

{ #category : #constants }
TLProcessSize >> bytePointerInContext [
	^ 4
]

{ #category : #constants }
TLProcessSize >> contextInProcess [
	^ 0
]

{ #category : #constants }
TLProcessSize >> contextSize [
	^ 7
]

{ #category : #constants }
TLProcessSize >> methodInContext [
	^ 0
]

{ #category : #constants }
TLProcessSize >> previousContextInContext [
	^ 6
]

{ #category : #constants }
TLProcessSize >> receiverInArguments [
	^ 0
]

{ #category : #constants }
TLProcessSize >> resultInProcess [
	^ 2
]

{ #category : #constants }
TLProcessSize >> stackInContext [
	^ 3
]

{ #category : #constants }
TLProcessSize >> stackTopInContext [
	^ 5
]

{ #category : #constants }
TLProcessSize >> statusInProcess [
	^ 1
]

{ #category : #constants }
TLProcessSize >> temporariesInContext [
	^ 2
]
