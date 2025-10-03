"
Tiny framework for Squeak apps that can be updated via Metacello and receive feedback on GitHub. To participate in this framework, override at least #selfUpdate or #githubRepositoryParams in the main class in your project, plus optionally #appName, #baselineName, and #packageNamePrefix.
"
Class {
	#name : #CtAppFramework,
	#superclass : #Object,
	#classVars : [
		'SelfUpdateBranches',
		'SelfUpdateMetacelloSpecs'
	],
	#category : #CtAppFramework,
	#'squeak_changestamp' : 'ct 10/3/2025 18:37'
}

{
	#category : #'accessing - apps',
	#'squeak_changestamp' : 'ct 10/3/2025 18:33'
}
CtAppFramework class >> apps [

	^ self systemNavigation allClasses
		select: [:class | class isCtApp]
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
	#'squeak_changestamp' : 'ct 10/3/2025 20:02'
}
CtAppFramework class >> selfUpdateApp: app [

	^ ((app class whichClassIncludesSelector: #basicSelfUpdate) ~= Class)
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
	#'squeak_changestamp' : 'ct 10/3/2025 18:32'
}
CtAppFramework class >> updateApps [

	| apps |
	apps := Project uiManager
		ctChooseMultipleFromLabeledValues: (self apps sortedSafely collect: [:ea | ea appName -> ea])
		title: 'Update apps...'
		initialSelection: self apps.
	apps isEmptyOrNil ifTrue: [^ self].
	
	(apps select: [:app | app wantsSystemUpdatesBeforeSelfUpdate]) ifNotEmpty: [:someApps |
		self confirmAndDoSystemUpdatesFor: ('{1} {2}' format: {someApps size. 'app' asPluralBasedOn: someApps}) or: [^ false]].
	
	apps
		do: [:app | self selfUpdateApp: app]
		displayingProgress: [:app | 'Updating app: {1}' format: {app appName}].
	
	self inform:
		('{1}:<br><br><blockquote>{2}</blockquote>' asTextFromHtml format:
			{apps size = 1
				ifTrue: ['1 app was updated successfully']
				ifFalse: ['{1} {2} were updated successfully' format: {apps size. 'app' asPluralBasedOn: apps}].
			(apps collect: [:app | app appName]) joinSeparatedBy: String cr}).
	
	^ true
]
