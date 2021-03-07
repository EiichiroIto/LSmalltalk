Class {
	#name : #BaselineOfLSmalltalk,
	#superclass : #BaselineOf,
	#category : #BaselineOfLSmalltalk
}

{ #category : #baselines }
BaselineOfLSmalltalk >> baseline: spec [
	spec
		for: #common
		do: [ spec
				package: 'LSmalltalk';
				package: 'LSmalltalk-Kernel'
					with: [ spec requires: #('LSmalltalk') ];
				package: 'LSmalltalk-Tests'
					with: [ spec requires: #('LSmalltalk' 'LSmalltalk-Kernel') ] ]
]

{ #category : #accessing }
BaselineOfLSmalltalk >> projectClass [
    ^ MetacelloCypressBaselineProject
]
