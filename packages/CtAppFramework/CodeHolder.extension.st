Extension { #name : #CodeHolder }

{
	#category : #'*CtAppFramework-menus',
	#'squeak_changestamp' : 'ct 12/29/2025 04:45'
}
CodeHolder >> ctAppMenu: menu [
	<classListMenuShifted: false>
	<menuPriority: 100>

	self selectedClass ifNil: [^ menu].
	(self selectedClass isTrait not and: [self selectedClass isMeta not] and: [self selectedClass isCtApp]) ifFalse: [^ menu].
	
	menu addItem: [:item |
		item contents: 'app'.
		item addSubMenu: [:subMenu |
			self selectedClass appMenu: subMenu]].
	menu addLine.
	^ menu
]
