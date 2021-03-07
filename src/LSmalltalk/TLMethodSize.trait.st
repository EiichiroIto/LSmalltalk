Trait {
	#name : #TLMethodSize,
	#category : #'LSmalltalk-Core'
}

{ #category : #constants }
TLMethodSize >> byteCodesInMethod [
	^ 1
]

{ #category : #constants }
TLMethodSize >> classInMethod [
	^ 5
]

{ #category : #constants }
TLMethodSize >> literalsInMethod [
	^ 2
]

{ #category : #constants }
TLMethodSize >> methodSize [
	^ 7
]

{ #category : #constants }
TLMethodSize >> nameInMethod [
	^ 0
]

{ #category : #constants }
TLMethodSize >> stackSizeInMethod [
	^ 3
]

{ #category : #constants }
TLMethodSize >> temporarySizeInMethod [
	^ 4
]

{ #category : #constants }
TLMethodSize >> textInMethod [
	^ 6
]
