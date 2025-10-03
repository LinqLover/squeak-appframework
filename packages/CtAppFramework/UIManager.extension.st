Extension { #name : #UIManager }

{
	#category : #'*CtAppFramework-ui requests',
	#'squeak_changestamp' : 'ct 10/3/2025 01:18'
}
UIManager >> ctChooseMultipleFrom: values title: aString initialSelection: selectedValues [

	self flag: #moveUpstream.
	
	^ self chooseMultipleFrom: values title: aString
]

{
	#category : #'*CtAppFramework-ui requests',
	#'squeak_changestamp' : 'ct 10/3/2025 01:50'
}
UIManager >> ctChooseMultipleFrom: labels values: values title: aString initialSelection: selectedValues [

	self flag: #moveUpstream.
	
	^ self chooseMultipleFrom: labels values: values title: aString
]

{
	#category : #'*CtAppFramework-ui requests',
	#'squeak_changestamp' : 'ct 10/3/2025 03:11'
}
UIManager >> ctChooseMultipleFromLabeledValues: associationsOrDictionary title: aString initialSelection: selectedValues [

	^ associationsOrDictionary isArray
		ifTrue: [self ctChooseMultipleFrom: (associationsOrDictionary collect: [:assoc | assoc key]) values: (associationsOrDictionary collect: [:assoc | assoc value]) title: aString initialSelection: selectedValues]
		ifFalse: [self ctChooseMultipleFrom: associationsOrDictionary keys values: associationsOrDictionary values title: aString initialSelection: selectedValues]
]
