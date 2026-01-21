Class {
	#name : 'CigConstantGeneratorByPrefixStrategy',
	#superclass : 'CigConstantGeneratorGroupStrategy',
	#instVars : [
		'prefixLetters'
	],
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'instance creation' }
CigConstantGeneratorByPrefixStrategy class >> newPrefixLetters: aString [

	^ self new 
		prefixLetters: aString;
		yourself
]

{ #category : 'generating' }
CigConstantGeneratorByPrefixStrategy >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass [
	
	self error: 'Should not arrive here'
]

{ #category : 'generating' }
CigConstantGeneratorByPrefixStrategy >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass in: aLibraryGenerator [
	| groups classes |

	groups := aCollectionOfMacroDefinitions 
		groupedBy: [ :each | 
			each name size >= prefixLetters 
				ifTrue: [ (each name first: prefixLetters) asUppercase ]
				ifFalse: [ each name asUppercase ] ].
		
	classes := Set new.
	groups keysAndValuesDo: [ :aName :aCollection | 
		| groupClass className |
	
		className := aConstantClass name, aName.
		groupClass := CigConstantGeneratorNoGroupStrategy new 
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

{ #category : 'accessing' }
CigConstantGeneratorByPrefixStrategy >> prefixLetters [

	^ prefixLetters
]

{ #category : 'accessing' }
CigConstantGeneratorByPrefixStrategy >> prefixLetters: aString [

	prefixLetters := aString
]
