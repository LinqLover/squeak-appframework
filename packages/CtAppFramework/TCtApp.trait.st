"
Use this trait in the main class of your project and implement at least #appName and #packageNamePrefix.
"
Trait {
	#name : #TCtApp,
	#category : #CtAppFramework
}

{
	#category : #'app - menu',
	#'squeak_changestamp' : 'ct 10/3/2025 00:47'
}
TCtApp classSide >> appMenu: menu [

	menu
		add: 'send feedback...' target: self action: #sendFeedback;
		balloonTextForLastItem: 'make the author(s) happy by giving them some feedback'.
	menu
		add: 'self-update' target: self action: #doSelfUpdate;
		balloonTextForLastItem: ('download and install the latest updates for {1}' format: {self appName}).
	
	^ menu
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:45'
}
TCtApp classSide >> appName [

	^ self requirement

"Example:

	^ 'My App'
"
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
TCtApp classSide >> baselineName [

	^ self packageNamePrefix

"Example:

	^ 'MyApp'
"
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 02:59'
}
TCtApp classSide >> basicSelfUpdate [

	^ self selfUpdateFromMetacello
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:00'
}
TCtApp classSide >> basicSelfUpdateBranch: aString [

	CtAppFramework selfUpdateBranchFor: self setTo: aString.
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:02'
}
TCtApp classSide >> basicSelfUpdateMetacelloSpec [

	^ (CtAppFramework selfUpdateMetacelloSpecFor: self) ifNil: [#default]
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:03'
}
TCtApp classSide >> basicSelfUpdateMetacelloSpec: aString [

	CtAppFramework selfUpdateMetacelloSpecFor: self set: aString.
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 22:35'
}
TCtApp classSide >> defaultFeedbackText [

	^ '<br><br><i>Reported from {1} (VM: {2}), for version of {3} last updated at {4}.</i>' asTextFromHtml format:
		{SystemVersion current.
		([Smalltalk vm openSmalltalkVMBuildNumber] ifError: [nil]) ifNil: [Smalltalk platformSourceVersion].
		self appName.
		self latestTimeStamp}
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:17'
}
TCtApp classSide >> defaultSelfUpdateBranch [

	(self environment classNamed: #MCRepositoryGroup) ifNotNil: [:mcRepositoryGroupClass |
		| repoPrefix |
		repoPrefix := 'github://{1}/{2}' format: {self githubRepositoryParams first. self githubRepositoryParams second}.
		mcRepositoryGroupClass default repositories
			detect: [:repo | repo description beginsWith: repoPrefix]
			ifFound: [:repo | ^ repo projectVersion]].
	
	^ 'main'
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 23:11'
}
TCtApp classSide >> doSelfUpdate [

	(Project uiManager confirm: ('Are you sure you would like to install the latest updates for {1}?' withCRs format: {self appName})) ifFalse: [^ false].
	
	self selfUpdate.
	^ true
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:16'
}
TCtApp classSide >> githubNewIssueUrl [

	^ self githubNewIssueUrlWithBody: '<!-- Your feedback goes here -->\' withCRs, (String streamContents: [:stream |
		(HtmlReadWriter on: stream)
			breakLines: false;
			nextPutText: self defaultFeedbackText])
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:16'
}
TCtApp classSide >> githubNewIssueUrlWithBody: htmlString [

	^ 'https://github.com/{1}/{2}/issues/new?{3}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second.
		WebUtils encodeUrlEncodedForm: {
			'body' -> htmlString}}
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:52'
}
TCtApp classSide >> githubRepositoryParams [
	"{owner. name. directory}"

	^ self requirement

"Example:

	^ {'LinqLover'. 'squeak-myapp'. 'packages'}
"
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 12/19/2024 23:17'
}
TCtApp classSide >> githubUrl [

	^ 'https://github.com/{1}/{2}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second}
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
TCtApp classSide >> latestTimeStamp [

	| packages |
	packages := PackageInfo allPackages select: [:ea |
		(ea name beginsWith: self packageNamePrefix) or: [ea name = (#BaselineOf , self baselineName)]].
	^ CurrentReadOnlySourceFiles cacheDuring:
		[((packages gather: #methods) collect:
			[:method | [TimeStamp fromMethodTimeStamp: method timeStamp] ifError: [TimeStamp new]])
				max]
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
TCtApp classSide >> metacello [

	^ Metacello new
		baseline: self baselineName;
		repository: self selfUpdateGitHubPath;
		yourself
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 12/19/2024 23:37'
}
TCtApp classSide >> openUrl: urlString [

	self flag: #moveUpstream.
	"Something similar but less convenient is also in TextURL >> #actOnClickFor:."
	WebBrowser defaultOrNil ifNotNil: [:browser |
		(Project uiManager
			confirm: ('Do you want to open this URL in a web browser?\\{1}' withCRs format: {urlString})
			title: 'Open Web Page' translated) ifTrue: [browser openOnUrl: urlString].
		^ self].
	
	^ urlString asText
		addAttribute: (TextURL new url: urlString);
		editWithLabel: 'Requested URL'
]

{
	#category : #'app - accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:45'
}
TCtApp classSide >> packageNamePrefix [

	^ self requirement

"Example:

	^ 'MyApp'
"
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:02'
}
TCtApp classSide >> selfUpdate [
	"SwaLint selfUpdate"

	self wantsSystemUpdates ifTrue:
		[CtAppFramework confirmAndDoSystemUpdatesFor: self appName or: [^ self]].
	
	^ self basicSelfUpdate
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:00'
}
TCtApp classSide >> selfUpdateBranch [
	"<preference: '{appName} self-update branch'
		category: #{packageNamePrefix}
		description: 'The branch used for installing updates for {appName} from the GitHub repository.'
		type: #String>"
	self flag: #requirement. "Users should override this and add a suitable pragma"
	
	^ (CtAppFramework selfUpdateBranchFor: self) ifNil: [self defaultSelfUpdateBranch]
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:18'
}
TCtApp classSide >> selfUpdateBranch: aString [

	self basicSelfUpdateBranch: aString.
	
	(Project uiManager confirm: 'Would you like to install updates now?' title: ('{1} self-update' format: {self appName}))
		ifTrue: [self selfUpdate].
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:16'
}
TCtApp classSide >> selfUpdateFromMetacello [

	| metacello project configuration |
	metacello := self metacello.
	project := metacello get.
	
	configuration := project configuration.
	(configuration respondsTo: #installDependencies) ifTrue: [configuration installDependencies].
	
	(metacello respondsTo: #merge:) "ct: Spur64VMMaker.image"
		ifTrue: [metacello merge: self basicSelfUpdateMetacelloSpec]
		ifFalse: [metacello load: self basicSelfUpdateMetacelloSpec].
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:18'
}
TCtApp classSide >> selfUpdateGitHubPath [

	^ ('github://{1}/{2}:\{1\}/{3}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second.
		self githubRepositoryParams third}) format: {self selfUpdateBranch}
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:05'
}
TCtApp classSide >> selfUpdateMetacelloSpec [
	"<preference: '{appName} self-update Metacello spec'
		category: '{appName}'
		description: 'The Metacello used for installing updates for {appName} from the GitHub repository.'
		type: #String>"
	self flag: #optionalRequirement. "Users can override this and add a suitable pragma"

	^ self basicSelfUpdateMetacelloSpec storeString
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 21:37'
}
TCtApp classSide >> selfUpdateMetacelloSpec: aString [

	self basicSelfUpdateMetacelloSpec: aString.
	
	(Project uiManager confirm: 'Would you like to install updates now?' title: ('{1} self-update' format: {self appName}))
		ifTrue: [self selfUpdate]
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:17'
}
TCtApp classSide >> sendFeedback [

	^ self sendFeedbackGitHub
]

{
	#category : #'app - feedback',
	#'squeak_changestamp' : 'ct 11/12/2023 18:55'
}
TCtApp classSide >> sendFeedbackGitHub [

	self openUrl: self githubNewIssueUrl
]

{
	#category : #'app - self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:00'
}
TCtApp classSide >> wantsSystemUpdates [

	^ true
]
