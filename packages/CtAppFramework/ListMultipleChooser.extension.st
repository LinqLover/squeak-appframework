Extension { #name : #ListMultipleChooser }

{
	#category : #'*CtAppFramework-instance creation',
	#'squeak_changestamp' : 'ct 10/3/2025 01:19'
}
ListMultipleChooser class >> ctChooseFrom: someLabels title: aString initialSelection: selectedLabels [

	^ self
		ctChooseItemListFrom: someLabels
		title: aString
		initialSelection: selectedLabels
]

{
	#category : #'*CtAppFramework-instance creation',
	#'squeak_changestamp' : 'ct 10/3/2025 01:47'
}
ListMultipleChooser class >> ctChooseItemListFrom: someObjects title: aString initialSelection: selectedObjects [

	self flag: #bug. "just pressing enter does not accept but cancel"
	^ self new
		title: aString;
		labels: (someObjects collect: [:ea | ea asString]);
		values: someObjects;
		ctSelectedValues: selectedObjects;
		choose
]

{
	#category : #'*CtAppFramework-instance creation',
	#'squeak_changestamp' : 'ct 10/3/2025 03:11'
}
ListMultipleChooser class >> ctChooseItemListFrom: labels values: values title: aString initialSelection: selectedValues [

	self flag: #bug. "just pressing enter does not accept but cancel"
	^ self new
		title: aString;
		labels: labels;
		values: values;
		ctSelectedValues: selectedValues;
		"ctSelectedLabels: selectedLabels;"
		choose
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 01:57'
}
ListMultipleChooser >> ctSelectedLabels: someLabels [

	self labels withIndexDo: [:label :index |
		self selectionAt: index put: (someLabels includes: label)].
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 01:20'
}
ListMultipleChooser >> ctSelectedValues: objects [

	self values withIndexDo: [:object :index |
		self selectionAt: index put: (objects includes: object)].
]
