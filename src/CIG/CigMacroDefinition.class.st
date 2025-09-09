Class {
	#name : 'CigMacroDefinition',
	#superclass : 'CigElement',
	#instVars : [
		'isBuiltin',
		'isFunctionLike',
		'source',
		'isPrintable',
		'isLiteral',
		'originSource'
	],
	#category : 'CIG-Node',
	#package : 'CIG',
	#tag : 'Node'
}

{ #category : 'accessing' }
CigMacroDefinition class >> kind [
	
	^ CXCursor_MacroDefinition
]

{ #category : 'visiting' }
CigMacroDefinition >> accept: aVisitor [
	aVisitor visitMacroDefinition: self
]

{ #category : 'visiting' }
CigMacroDefinition >> acceptNameGenerator: aVisitor [
	self halt. "This is not implemented yet. It should be something like: 
	self source 
		ifNotNil: [ :aString | self cToPharo: aString substrings allButFirst ]"
	^ aVisitor visitMacroDefinition: self
]

{ #category : 'initialization' }
CigMacroDefinition >> fromCursor: aCursor [

	super fromCursor: aCursor.
	
	name ifNil: [ name := aCursor displayName ].
		
	isBuiltin := aCursor isMacroBuiltin.
	isFunctionLike := aCursor isMacroFunctionLike.
	isLiteral := false.
	isPrintable := false.

	"fast exit to not calculate the tokens of everything"
	isFunctionLike ifTrue: [ ^ self ].

	"I am going to try as printable anything that is not a function like. 
	 This is questionable, but I the generator will try to get the real printable 
	 value after"
	isPrintable := true.

	"get source"
	originSource := aCursor source ifNotNil: [ :aString | (aString allButFirst: name size) trimmed ]. 
	
	"get tokens to see if this is a literal"
	aCursor withSourceTokensDo: [ :tokens :numTokens :unit |
		tokens size = 2 ifTrue: [
			isLiteral := tokens second isLiteral ] ].
]

{ #category : 'testing' }
CigMacroDefinition >> isEmptyDefinition [

	^ self originSource isEmptyOrNil
]

{ #category : 'testing' }
CigMacroDefinition >> isFunctionLike [

	^ isFunctionLike
]

{ #category : 'testing' }
CigMacroDefinition >> isLiteral [

	^ isLiteral
]

{ #category : 'testing' }
CigMacroDefinition >> isMacroDefinition [

	^ true
]

{ #category : 'testing' }
CigMacroDefinition >> isPrintable [

	^ isPrintable
]

{ #category : 'accessing' }
CigMacroDefinition >> makeNotPrintable [

	isPrintable := false
]

{ #category : 'accessing' }
CigMacroDefinition >> originSource [

	^ originSource
]

{ #category : 'accessing' }
CigMacroDefinition >> source [

	^ source ifNil: [ originSource ]
]

{ #category : 'initialization' }
CigMacroDefinition >> updateSourceWith: aString [
	"in generation step, we can update the source of a macro with a calculated value. 
	 this will set the source but keep originSource intact (so we can use it later)"

	source := aString
]
