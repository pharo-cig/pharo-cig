Class {
	#name : 'CigPharoEnumGenerator',
	#superclass : 'CigPharoGenerator',
	#instVars : [
		'generatedClassName'
	],
	#category : 'CIG-Pharo-Generator',
	#package : 'CIG',
	#tag : 'Pharo-Generator'
}

{ #category : 'private' }
CigPharoEnumGenerator >> addEnum [
	| name generatedClass |
	
	name := self element phDeclaration.
	logger trace: name.
	generatedClass := (self baseEnumClass << name)
		tag: self namespaceName;
		package: self packageName;
		install.
		
	generatedClassName := generatedClass name
]

{ #category : 'private' }
CigPharoEnumGenerator >> addEnumDecl [

	self generatedClass class 
		compile: self element phTemplate generateEnumDecl
		classified: 'enum declaration'
]

{ #category : 'generating' }
CigPharoEnumGenerator >> doInitialize [

	self generatedClass
		initializeEnumeration;
		rebuildEnumAccessors
]

{ #category : 'generating' }
CigPharoEnumGenerator >> generate [
	
	self addEnum.
	self addEnumDecl
]

{ #category : 'generating' }
CigPharoEnumGenerator >> generateOn: aVisitor [
	
	super generateOn: aVisitor.
	aVisitor registerForInitialization: self
]

{ #category : 'private' }
CigPharoEnumGenerator >> generatedClass [

	^ self class environment classNamed: generatedClassName
]
