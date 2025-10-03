"
Tiny framework for Squeak apps that can be updated via Metacello and receive feedback on GitHub. To use this framework, add the trait TCtApp to the main class in your project.
"
Class {
	#name : #CtAppFramework,
	#superclass : #Object,
	#traits : 'TCtApp',
	#classTraits : 'TCtApp classTrait',
	#classVars : [
		'SelfUpdateBranches',
		'SelfUpdateMetacelloSpecs'
	],
	#category : #CtAppFramework,
	#'squeak_changestamp' : 'ct 10/3/2025 03:25'
}

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 01:09'
}
CtAppFramework class >> appName [

	^ 'CtAppFramework'
]

{
	#category : #private,
	#'squeak_changestamp' : 'ct 10/3/2025 02:05'
}
CtAppFramework class >> appNameFor: aClass [

	^ (aClass respondsTo: #appName)
		ifTrue: [aClass appName]
		ifFalse: [aClass name]
]

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 02:04'
}
CtAppFramework class >> apps [

	^ (self systemNavigation allBehaviors select: [:class |
		class isMeta not and: [class respondsTo: #selfUpdate]])
			contents
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 01:09'
}
CtAppFramework class >> baselineName [

	^ 'CtAppFramework'
]

{
	#category : #'self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:02'
}
CtAppFramework class >> confirmAndDoSystemUpdatesFor: appName or: cancelBlock [

	| squeakVersion |
	squeakVersion := SystemVersion current version.
	((Project uiManager
		confirm: ('It is recommended to install the latest updates for {1} first.' format: {squeakVersion})
		title: ('Updating {1}' format: {appName})
		trueChoice: ('Yes, install latest {1} updates now' format: {'Squeak'})
		falseChoice: ('Skip latest {1} updates (not recommended)' format: {'Squeak'}))
			ifNil: [^ cancelBlock value])
				ifTrue: [MCMcmUpdater default doUpdate: true]
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 01:09'
}
CtAppFramework class >> githubRepositoryParams [
	"{owner. name. directory}"

	^ {'LinqLover'. 'squeak-appframework'. 'packages'}
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'ct 10/3/2025 01:06'
}
CtAppFramework class >> initialize [

	SelfUpdateBranches := Dictionary new.
	SelfUpdateMetacelloSpecs := Dictionary new.
]

{
	#category : #private,
	#'squeak_changestamp' : 'ct 10/3/2025 03:08'
}
CtAppFramework class >> selfUpdateApp: app [

	^ (app respondsTo: #basicSelfUpdate)
		ifTrue: [app basicSelfUpdate]
		ifFalse: [app selfUpdate]
]

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 01:01'
}
CtAppFramework class >> selfUpdateBranchFor: appClass [

	^ SelfUpdateBranches at: appClass appName ifAbsent: [nil]
]

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 01:00'
}
CtAppFramework class >> selfUpdateBranchFor: appClass setTo: aString [

	SelfUpdateBranches at: appClass appName put: aString.
]

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 01:06'
}
CtAppFramework class >> selfUpdateMetacelloSpecFor: appClass [

	^ SelfUpdateMetacelloSpecs at: appClass appName ifAbsent: [nil]
]

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 01:06'
}
CtAppFramework class >> selfUpdateMetacelloSpecFor: appClass set: aString [

	SelfUpdateMetacelloSpecs at: appClass appName put: aString.
]

{
	#category : #'self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:09'
}
CtAppFramework class >> updateApps [

	| apps |
	apps := Project uiManager
		ctChooseMultipleFromLabeledValues: (self apps sortedSafely collect: [:ea | (self appNameFor: ea) -> ea])
		title: 'Update apps...'
		initialSelection: self apps.
	apps isEmptyOrNil ifTrue: [^ self].
	
	(apps select: [:app | app wantsSystemUpdates]) ifNotEmpty: [:someApps |
		self confirmAndDoSystemUpdatesFor: ('{1} {2}' format: {someApps size. 'app' asPluralBasedOn: someApps}) or: [^ false]].
	
	apps
		do: [:app | self selfUpdateApp: app]
		displayingProgress: [:app | 'Updating app: {1}' format: {self appNameFor: app}].
	
	self inform:
		('{1}:<br><br><blockquote>{2}</blockquote>' asTextFromHtml format:
			{apps size = 1
				ifTrue: ['1 app was updated successfully']
				ifFalse: ['{1} {2} were updated successfully' format: {apps size. 'app' asPluralBasedOn: apps}].
			(apps collect: [:app | self appNameFor: app]) joinSeparatedBy: String cr}).
	
	^ true
]
