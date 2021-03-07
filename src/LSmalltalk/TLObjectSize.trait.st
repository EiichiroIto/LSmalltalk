Trait {
	#name : #TLObjectSize,
	#category : #'LSmalltalk-Core'
}

{ #category : #constants }
TLObjectSize >> classSize [
	^ 5
]

{ #category : #constants }
TLObjectSize >> instanceSizeInClass [
	^ 3
]

{ #category : #constants }
TLObjectSize >> keysInDictionary [
	^ 0
]

{ #category : #constants }
TLObjectSize >> leftInNode [
	^ 1
]

{ #category : #constants }
TLObjectSize >> methodsInClass [
	^ 2
]

{ #category : #constants }
TLObjectSize >> nameInClass [
	^ 0
]

{ #category : #constants }
TLObjectSize >> objectSize [
	^ 12 "4 + 4 + 4"
]

{ #category : #constants }
TLObjectSize >> parentClassInClass [
	^ 1
]

{ #category : #constants }
TLObjectSize >> rightInNode [
	^ 2
]

{ #category : #constants }
TLObjectSize >> rootInTree [
	^ 0
]

{ #category : #constants }
TLObjectSize >> symbolsInSymbol [
	^ 5
]

{ #category : #constants }
TLObjectSize >> valueInNode [
	^ 0
]

{ #category : #constants }
TLObjectSize >> valuesInDictionary [
	^ 1
]

{ #category : #constants }
TLObjectSize >> variablesInClass [
	^ 4
]
