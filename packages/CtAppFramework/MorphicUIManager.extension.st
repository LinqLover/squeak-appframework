Extension { #name : #MorphicUIManager }

{
	#category : #'*CtAppFramework-ui requests',
	#'squeak_changestamp' : 'ct 10/3/2025 01:18'
}
MorphicUIManager >> ctChooseMultipleFrom: values title: aString initialSelection: selectedValues [
	
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ ListMultipleChooser
		ctChooseFrom: values
		title: aString
		initialSelection: selectedValues
]

{
	#category : #'*CtAppFramework-ui requests',
	#'squeak_changestamp' : 'ct 10/3/2025 01:55'
}
MorphicUIManager >> ctChooseMultipleFrom: labelList values: valueList title: aString initialSelection: selectedValues [
	
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ ListMultipleChooser
		ctChooseItemListFrom: labelList
		values: valueList
		title: aString
		initialSelection: selectedValues
]
