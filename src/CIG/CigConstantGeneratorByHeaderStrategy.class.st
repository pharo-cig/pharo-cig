Class {
	#name : 'CigConstantGeneratorByHeaderStrategy',
	#superclass : 'CigConstantGeneratorGroupStrategy',
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'generating' }
CigConstantGeneratorByHeaderStrategy >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass [
	
	self error: 'Should not arrive here'
]

{ #category : 'generating' }
CigConstantGeneratorByHeaderStrategy >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass in: aLibraryGenerator [
	| groups classes |

	groups := aCollectionOfMacroDefinitions 
		groupedBy: [ :each | 
			each location 
				ifNotEmpty: [ :location | location asFileReference base ]
				ifEmpty: [ 'unknown' ] ].
		
	classes := Set new.
	groups keysAndValuesDo: [ :aName :aCollection | 
		| groupClass className |
	
		className := aConstantClass name, 
			(aLibraryGenerator nameGenerator applyCamelCaseTo: aName) capitalized.
		groupClass := CigConstantGeneratorNoGroupStrategy new 
			configureWith: self;
			addConstants: aCollection 
			to: ((SharedPool << className asSymbol)
				tag: aConstantClass packageTagName;
				package: aConstantClass packageName;
				install)
			in: aLibraryGenerator.
	
		classes add: groupClass ].
		
	^ self 
		updateClass: aConstantClass 
		with: [ :aBuilder | 
			aBuilder sharedPools: (classes collect: #name as: Array) sorted ]
]
