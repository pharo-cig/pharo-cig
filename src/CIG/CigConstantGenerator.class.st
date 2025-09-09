"
Define which headers to include to generate macros and rules to match them.
Users can implement their own.
"
Class {
	#name : 'CigConstantGenerator',
	#superclass : 'Object',
	#instVars : [
		'headers',
		'excludeMacros',
		'excludeMatches',
		'preferHexadecimal',
		'ignoreEmptyDefinitions',
		'groupStrategy'
	],
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'accessing' }
CigConstantGenerator >> addHeader: aString [ 
	"Just include constants on specified headers."

	headers ifNil: [ headers := #() ].
	headers := headers copyWith: aString
]

{ #category : 'accessing' }
CigConstantGenerator >> doNotGroup [

	groupStrategy := CigConstantGeneratorNoGroupStrategy new
]

{ #category : 'accessing - scripting' }
CigConstantGenerator >> exclude: aString [

	excludeMacros := excludeMacros copyWith: aString
]

{ #category : 'accessing - scripting' }
CigConstantGenerator >> excludeAll: aCollection [

	aCollection do: [ :each | self exclude: each ]
]

{ #category : 'accessing - scripting' }
CigConstantGenerator >> excludeAllMatching: aString [
	"receives a regex expression to match with the macro name"

	excludeMatches := excludeMatches copyWith: aString asRegex
]

{ #category : 'accessing - scripting' }
CigConstantGenerator >> excludeAllMatchingAnyOf: aCollection [
	aCollection do: [ :each | self excludeAllMatching: each ]
]

{ #category : 'accessing' }
CigConstantGenerator >> excludeMacros: aCollection [

	excludeMacros := aCollection
]

{ #category : 'accessing' }
CigConstantGenerator >> groupByHeader [

	groupStrategy := CigConstantGeneratorByHeaderStrategy new
]

{ #category : 'accessing' }
CigConstantGenerator >> groupByPrefix: aNumber [

	groupStrategy := CigConstantGeneratorByPrefixStrategy newPrefixLetters: aNumber
]

{ #category : 'accessing' }
CigConstantGenerator >> groupStrategy [

	^ groupStrategy
]

{ #category : 'accessing' }
CigConstantGenerator >> headers [

	^ headers
]

{ #category : 'accessing' }
CigConstantGenerator >> headers: aCollection [

	headers := aCollection
]

{ #category : 'accessing' }
CigConstantGenerator >> ignoreEmptyDefinitions [

	ignoreEmptyDefinitions := true
]

{ #category : 'accessing - scripting' }
CigConstantGenerator >> include: aString [ 

	self addHeader: aString
]

{ #category : 'accessing' }
CigConstantGenerator >> includeEmptyDefinitions [

	ignoreEmptyDefinitions := false
]

{ #category : 'initialization' }
CigConstantGenerator >> initialize [

	super initialize.
	excludeMacros := #().
	excludeMatches := #().
	self doNotGroup.
	self preferHexadecimal.
	self ignoreEmptyDefinitions
]

{ #category : 'private' }
CigConstantGenerator >> isInIncludedHeaders: aStringOrFileReference [
	| basename |

	headers isEmptyOrNil ifTrue: [ ^ true ].
	
	basename := aStringOrFileReference asFileReference basename.
	^ headers anySatisfy: [ :each | basename = each ]
]

{ #category : 'testing' }
CigConstantGenerator >> isPreferHexadecimal [

	^ preferHexadecimal
]

{ #category : 'testing' }
CigConstantGenerator >> isPrintable: aMacroDefinition [

	^ (excludeMacros includes: aMacroDefinition name) not
		and: [ (excludeMatches noneSatisfy: [ :eachRegex | eachRegex matches: aMacroDefinition name ])
		and: [ self isInIncludedHeaders: aMacroDefinition location  ] ] 
]

{ #category : 'accessing' }
CigConstantGenerator >> preferDecimal [
	"When we do not get literal constants, we need to calculate and print the result. 
	 We can tell the generator to prefer decimal notation to print the numbers."

	preferHexadecimal := false
]

{ #category : 'accessing' }
CigConstantGenerator >> preferHexadecimal [
	"When we do not get literal constants, we need to calculate and print the result. 
	 We can tell the generator to prefer hexadecimal notation to print the numbers.
	 This is the DEFAULT"

	preferHexadecimal := true
]

{ #category : 'testing' }
CigConstantGenerator >> shouldIgnoreEmptyDefinitions [

	^ ignoreEmptyDefinitions
]

{ #category : 'testing' }
CigConstantGenerator >> shouldPreferHexadecimal [

	^ preferHexadecimal
]
