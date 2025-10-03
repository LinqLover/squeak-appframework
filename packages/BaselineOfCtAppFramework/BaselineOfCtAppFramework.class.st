Class {
	#name : #BaselineOfCtAppFramework,
	#superclass : #BaselineOf,
	#category : #BaselineOfCtAppFramework
}

{
	#category : #baseline,
	#'squeak_changestamp' : 'ct 10/3/2025 03:16'
}
BaselineOfCtAppFramework >> baseline: spec [
	<baseline>

	spec for: #common do: [
		"packages"
		spec package: 'CtAppFramework'.
		
		"groups"
		spec group: #default with: #('SnapshotReminder')]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 5/26/2021 15:29'
}
BaselineOfCtAppFramework >> projectClass [

	^ (self environment classNamed: #MetacelloCypressBaselineProject) ifNil: [super projectClass]
]
