Extension { #name : #CodeHolder }

{
	#category : #'*CtAppFramework-menus',
	#'squeak_changestamp' : 'ct 10/3/2025 02:24'
}
CodeHolder >> ctAppMenu: menu [
	<classListMenuShifted: false>
	<menuPriority: 100>

	(self selectedClass respondsTo: #appMenu:) ifTrue:
		[menu addItem: [:item |
			item contents: 'app'.
			item addSubMenu: [:subMenu |
				self selectedClass appMenu: subMenu]].
		menu addLine].
	^ menu
]
