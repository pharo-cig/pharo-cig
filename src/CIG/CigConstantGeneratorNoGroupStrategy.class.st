Class {
	#name : 'CigConstantGeneratorNoGroupStrategy',
	#superclass : 'CigConstantGeneratorGroupStrategy',
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'private' }
CigConstantGeneratorNoGroupStrategy >> addClassAccessors: aCollection to: generatedClass [

	aCollection do: [ :each | 
		generatedClass class 
			compileSilently: ('{1}

	^ {1}' format: { each name })
			classified: self methodProtocolName ]
]

{ #category : 'private' }
CigConstantGeneratorNoGroupStrategy >> addClassInitializationMethodConstants: aCollection to: generatedClass [

	generatedClass class 
		compile: (self classInitializationTemplate: aCollection)
		classified: 'class initialization'.
		
	generatedClass initialize
]

{ #category : 'generating' }
CigConstantGeneratorNoGroupStrategy >> addConstants: aCollection to: aConstantClass [
	| newClass constantsToAdd |

	aCollection ifEmpty: [ ^ self ].

	constantsToAdd := self filterCollectionToGenerate: aCollection.

	newClass := SharedPool << aConstantClass name asSymbol
		sharedVariables: (self collectSharedVariables: constantsToAdd); 
		tag: 'Library';
		package: aConstantClass packageName;
		install.

	self removeOldAccessorsIn: newClass.
	
	self 
		addClassInitializationMethodConstants: constantsToAdd
		to: newClass.
	self 
		addClassAccessors: constantsToAdd
		to: newClass.
		
	^ newClass
]

{ #category : 'private' }
CigConstantGeneratorNoGroupStrategy >> classInitializationTemplate: aCollection [

	^ String streamContents: [ :stream |
		stream << 'initialize'; cr; cr.
		aCollection
			do: [ :each | 
				stream tab.
				stream <<  each name << ' := ' << (self literalValueOf: each source).
				((each source ~= each originSource) and: [ each originSource isNotEmpty ]) 
					ifTrue: [ 
						stream tab. 
						stream << ' "' << each originSource << '"']  ]
			separatedBy: [ 
				stream << '.'; cr ] ]
]

{ #category : 'generating' }
CigConstantGeneratorNoGroupStrategy >> filterCollectionToGenerate: aCollection [

	self shouldIgnoreEmptyDefinitions ifFalse: [ ^ aCollection ].
	
	^ aCollection reject: [ :each | each isEmptyDefinition ]
]

{ #category : 'private' }
CigConstantGeneratorNoGroupStrategy >> methodProtocolName [

	^ 'accessing - constants'
]

{ #category : 'private' }
CigConstantGeneratorNoGroupStrategy >> removeOldAccessorsIn: aClass [

	aClass class methods 
		select: [ :each | each protocolName = self methodProtocolName ]
		thenDo: [ :each | each removeFromSystem ]
]
