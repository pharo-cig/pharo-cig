Class {
	#name : 'CigConstantGeneratorGroupStrategy',
	#superclass : 'Object',
	#instVars : [
		'constantGenerator'
	],
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'generating' }
CigConstantGeneratorGroupStrategy >> addConstants: aCollection to: aConstantClass [

	self subclassResponsibility
]

{ #category : 'generating' }
CigConstantGeneratorGroupStrategy >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass in: aLibraryGenerator [

	^ self 
		addConstants: aCollectionOfMacroDefinitions 
		to: aConstantClass
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> collectConstantValues: aCollection [
	"
	1. generate temporal file and compile it, get results.
	2. parse and collect results into a dictionary.
	"
	| macros fileReference binaryReference result |

	logger trace: aCollection.

	macros := OrderedDictionary new.
	aCollection do: [ :each | 
		macros
			at: each name 
			put: (self literalValueOf: each source) ].
	
	^ macros
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> collectSharedVariables: aCollection [
		
	^ (aCollection sorted: #name ascending)
		collect: [ :each | each name asSymbol ] 
		as: Array
]

{ #category : 'configuring' }
CigConstantGeneratorGroupStrategy >> configureWith: aConstantGenerator [

	constantGenerator := aConstantGenerator
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> literalStringToInternal: aString [

	"remove quotes"
	^ (aString copyFrom: 2 to: aString size - 1) 
		"escape single quotes"
		copyReplaceAll: '''' with: ''''''
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> literalValueOf: aString [
	| literal |

	literal := String streamContents: [ :out | | in next |
		in := aString readStream.
		[ in atEnd  ] whileFalse: [ 
			next := in next.
			(next = $\ and: [ (in peek = Character cr) or: (in peek = Character lf) ]) ifTrue: [ next := in next ].
		out nextPut: next ]].

	literal := literal trimBoth.
	
	
	[ #($L $U) includes: literal last asUppercase ]
	whileTrue: [ literal := literal allButLast ].

	(literal = '0') 			ifTrue: [ ^ literal ].
	(literal beginsWith: '0x') 	ifTrue: [ ^ '16r', (literal allButFirst: 2) ].
	(literal beginsWith: '0X') 	ifTrue: [ ^ '16r', (literal allButFirst: 2) ].
	(literal beginsWith: '0b') 	ifTrue: [ ^ '2r', (literal allButFirst: 2) ].
	(literal beginsWith: '0B') 	ifTrue: [ ^ '2r', (literal allButFirst: 2) ].
	((literal beginsWith: '0') and: [ (literal beginsWith: '0.') not ]) ifTrue: [ ^ '8r', (literal allButFirst) ].
	(literal first isDigit) 		ifTrue: [ ^ self toNumberLiteral: literal ].
	(literal first = $-) 		ifTrue: [ ^ self toNumberLiteral: literal ].
	(literal first = $") 		ifTrue: [ ^ '''', (self literalStringToInternal: literal), '''' ].
	(literal first = $') 		ifTrue: [ ^ '$', literal second asString ].
	(literal = 'inf') 			ifTrue: [ ^ 'Float infinity' ].
	(literal = 'nan') 			ifTrue: [ ^ 'nil' ].

	self error: 'Invalid macro literal: ', aString
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> shouldIgnoreEmptyDefinitions [

	^ constantGenerator shouldIgnoreEmptyDefinitions
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> shouldPreferHexadecimal [

	^ constantGenerator shouldPreferHexadecimal
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> toNumberLiteral: aString [
	| number |

	number := NumberParser parse: aString.

	number isFloat ifTrue: [ 
		^ (aString last asUppercase = $F)
			ifTrue: [ aString allButLast ]
			ifFalse: [ aString ] ].
	(self shouldPreferHexadecimal not 
		or: [ number abs < 16 ]) 
		ifTrue: [ ^ aString ]. 
	
	^ number hex
]

{ #category : 'private' }
CigConstantGeneratorGroupStrategy >> updateClass: aClass with: aBlock [

	^ ShiftClassBuilder new 
		fillFor: aClass;
		in: [ :this | aBlock value: this ];
		install
]
