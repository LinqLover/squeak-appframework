Extension { #name : #Class }

{
	#category : #'*CtAppFramework-menu',
	#'squeak_changestamp' : 'ct 10/3/2025 00:47'
}
Class >> appMenu: menu [

	menu
		add: 'send feedback...' target: self action: #sendFeedback;
		balloonTextForLastItem: 'make the author(s) happy by giving them some feedback'.
	menu
		add: 'self-update' target: self action: #doSelfUpdate;
		balloonTextForLastItem: ('download and install the latest updates for {1}' format: {self appName}).
	
	^ menu
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 18:25'
}
Class >> appName [

	^ self packageInfo name

"Example:

	^ 'My App'
"
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
Class >> baselineName [

	^ self packageNamePrefix

"Example:

	^ 'MyApp'
"
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 02:59'
}
Class >> basicSelfUpdate [

	^ self selfUpdateFromMetacello
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:00'
}
Class >> basicSelfUpdateBranch: aString [

	CtAppFramework selfUpdateBranchFor: self setTo: aString.
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:02'
}
Class >> basicSelfUpdateMetacelloSpec [

	^ (CtAppFramework selfUpdateMetacelloSpecFor: self) ifNil: [#default]
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 01:03'
}
Class >> basicSelfUpdateMetacelloSpec: aString [

	CtAppFramework selfUpdateMetacelloSpecFor: self set: aString.
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 22:35'
}
Class >> defaultFeedbackText [

	^ '<br><br><i>Reported from {1} (VM: {2}), for version of {3} last updated at {4}.</i>' asTextFromHtml format:
		{SystemVersion current.
		([Smalltalk vm openSmalltalkVMBuildNumber] ifError: [nil]) ifNil: [Smalltalk platformSourceVersion].
		self appName.
		self latestTimeStamp}
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:17'
}
Class >> defaultSelfUpdateBranch [

	(self environment classNamed: #MCRepositoryGroup) ifNotNil: [:mcRepositoryGroupClass |
		| repoPrefix |
		repoPrefix := 'github://{1}/{2}' format: {self githubRepositoryParams first. self githubRepositoryParams second}.
		mcRepositoryGroupClass default repositories
			detect: [:repo | repo description beginsWith: repoPrefix]
			ifFound: [:repo | ^ repo projectVersion]].
	
	^ 'main'
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 23:11'
}
Class >> doSelfUpdate [

	(Project uiManager confirm: ('Are you sure you would like to install the latest updates for {1}?' withCRs format: {self appName})) ifFalse: [^ false].
	
	self selfUpdate.
	^ true
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:16'
}
Class >> githubNewIssueUrl [

	^ self githubNewIssueUrlWithBody: '<!-- Your feedback goes here -->\' withCRs, (String streamContents: [:stream |
		(HtmlReadWriter on: stream)
			breakLines: false;
			nextPutText: self defaultFeedbackText])
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:16'
}
Class >> githubNewIssueUrlWithBody: htmlString [

	^ 'https://github.com/{1}/{2}/issues/new?{3}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second.
		WebUtils encodeUrlEncodedForm: {
			'body' -> htmlString}}
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 18:27'
}
Class >> githubRepositoryParams [
	"{owner. name. directory}"

	^ self subclassResponsibility

"Example:

	^ {'LinqLover'. 'squeak-myapp'. 'packages'}
"
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 12/19/2024 23:17'
}
Class >> githubUrl [

	^ 'https://github.com/{1}/{2}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second}
]

{
	#category : #'*CtAppFramework-testing',
	#'squeak_changestamp' : 'ct 10/3/2025 18:27'
}
Class >> isCtApp [

	^ (self class includesSelector: #selfUpdate)
		or: [(self class whichClassIncludesSelector: #githubRepositoryParams) ~= thisContext methodClass]
]

{
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
Class >> latestTimeStamp [

	| packages |
	packages := PackageInfo allPackages select: [:ea |
		(ea name beginsWith: self packageNamePrefix) or: [ea name = (#BaselineOf , self baselineName)]].
	^ CurrentReadOnlySourceFiles cacheDuring:
		[((packages gather: #methods) collect:
			[:method | [TimeStamp fromMethodTimeStamp: method timeStamp] ifError: [TimeStamp new]])
				max]
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 00:56'
}
Class >> metacello [

	^ Metacello new
		baseline: self baselineName;
		repository: self selfUpdateGitHubPath;
		yourself
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 12/19/2024 23:37'
}
Class >> openUrl: urlString [

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
	#category : #'*CtAppFramework-accessing',
	#'squeak_changestamp' : 'ct 10/3/2025 18:26'
}
Class >> packageNamePrefix [

	^ self packageInfo name

"Example:

	^ 'MyApp'
"
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 18:30'
}
Class >> selfUpdate [
	"SwaLint selfUpdate"

	self wantsSystemUpdatesBeforeSelfUpdate ifTrue:
		[CtAppFramework confirmAndDoSystemUpdatesFor: self appName or: [^ self]].
	
	^ self basicSelfUpdate
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 18:40'
}
Class >> selfUpdateBranch [
	"<preference: '{appName} self-update branch'
		category: #{packageNamePrefix}
		description: 'The branch used for installing updates for {appName} from the GitHub repository.'
		type: #String>"
	self flag: #subclassResponsibility. "Users should override this and add a suitable pragma"
	
	^ (CtAppFramework selfUpdateBranchFor: self) ifNil: [self defaultSelfUpdateBranch]
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:18'
}
Class >> selfUpdateBranch: aString [

	self basicSelfUpdateBranch: aString.
	
	(Project uiManager confirm: 'Would you like to install updates now?' title: ('{1} self-update' format: {self appName}))
		ifTrue: [self selfUpdate].
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 03:16'
}
Class >> selfUpdateFromMetacello [

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
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 20:18'
}
Class >> selfUpdateGitHubPath [

	^ ('github://{1}/{2}:\{1\}/{3}' format: {
		self githubRepositoryParams first.
		self githubRepositoryParams second.
		self githubRepositoryParams third}) format: {self selfUpdateBranch}
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 18:40'
}
Class >> selfUpdateMetacelloSpec [
	"<preference: '{appName} self-update Metacello spec'
		category: '{appName}'
		description: 'The Metacello used for installing updates for {appName} from the GitHub repository.'
		type: #String>"
	self flag: #optionalSubclassResponsibility. "Users can override this and add a suitable pragma"

	^ self basicSelfUpdateMetacelloSpec storeString
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 8/27/2023 21:37'
}
Class >> selfUpdateMetacelloSpec: aString [

	self basicSelfUpdateMetacelloSpec: aString.
	
	(Project uiManager confirm: 'Would you like to install updates now?' title: ('{1} self-update' format: {self appName}))
		ifTrue: [self selfUpdate]
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 8/27/2023 20:17'
}
Class >> sendFeedback [

	^ self sendFeedbackGitHub
]

{
	#category : #'*CtAppFramework-feedback',
	#'squeak_changestamp' : 'ct 11/12/2023 18:55'
}
Class >> sendFeedbackGitHub [

	self openUrl: self githubNewIssueUrl
]

{
	#category : #'*CtAppFramework-self-updating',
	#'squeak_changestamp' : 'ct 10/3/2025 18:30'
}
Class >> wantsSystemUpdatesBeforeSelfUpdate [

	^ true
]
