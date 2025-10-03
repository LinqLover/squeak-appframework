"
Documentation only. DO NOT USE THIS TRAIT IN YOUR BASELINE, otherwise loading the baseline in a fresh image won't work!
"
Trait {
	#name : #TCtBaselineOf,
	#category : #CtAppFramework
}

{
	#category : #'self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:26'
}
TCtBaselineOf >> installDependencies [
	"Install most important dependencies. Metacello>>#get is not recursive."

	self requirement "optional but recommended - documentation only. DO NOT USE THIS TRAIT IN YOUR BASELINE, otherwise loading the baseline in a fresh image won't work!"

"Example:

	Metacello new
		baseline: 'CtAppFramework';
		repository: 'github://LinqLover/squeak-appframework';
		get;
		load.
"
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'ct 5/26/2021 15:29'
}
TCtBaselineOf >> projectClass [

	^ (self environment classNamed: #MetacelloCypressBaselineProject) ifNil: [super projectClass]
]
