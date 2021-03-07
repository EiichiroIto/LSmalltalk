Trait {
	#name : #TLBlockSize,
	#category : #'LSmalltalk-Core'
}

{ #category : #constants }
TLBlockSize >> argumentLocationInBlock [
	^ 7
]

{ #category : #constants }
TLBlockSize >> argumentsInBlock [
	^ self argumentsInContext
]

{ #category : #constants }
TLBlockSize >> blockSize [
	^ 10
]

{ #category : #constants }
TLBlockSize >> bytePointerInBlock [
	^ 9
]

{ #category : #constants }
TLBlockSize >> creatingContextInBlock [
	^ 8
]

{ #category : #constants }
TLBlockSize >> methodInBlock [
	^ self methodInContext
]

{ #category : #constants }
TLBlockSize >> previousContextInBlock [
	^ self previousContextInContext
]

{ #category : #constants }
TLBlockSize >> stackInBlock [
	^ self stackInContext
]

{ #category : #constants }
TLBlockSize >> stackTopInBlock [
	^ self stackTopInContext
]

{ #category : #constants }
TLBlockSize >> temporariesInBlock [
	^ self temporariesInContext
]
