Trait {
	#name : #TLReturnCode,
	#category : #'LSmalltalk-Core'
}

{ #category : #constants }
TLReturnCode >> returnBadMethod [
	^ 3
]

{ #category : #constants }
TLReturnCode >> returnBreak [
	^ 6
]

{ #category : #constants }
TLReturnCode >> returnContinue [
	^ 0
]

{ #category : #constants }
TLReturnCode >> returnError [
	^ 2
]

{ #category : #constants }
TLReturnCode >> returnReturned [
	^ 4
]

{ #category : #constants }
TLReturnCode >> returnTimeExpired [
	^ 5
]
