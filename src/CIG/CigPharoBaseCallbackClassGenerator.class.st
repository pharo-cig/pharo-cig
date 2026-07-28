"
Generates the base callback class for a library. The generated class extends FFICallback and serves as the superclass for all callback types in the library, allowing per-library customization (e.g., thread runner for worker-thread-safe callbacks).
"
Class {
	#name : 'CigPharoBaseCallbackClassGenerator',
	#superclass : 'CigPharoBaseClassGenerator',
	#instVars : [
		'generatedClass'
	],
	#category : 'CIG-Pharo-Generator',
	#package : 'CIG',
	#tag : 'Pharo-Generator'
}

{ #category : 'generation' }
CigPharoBaseCallbackClassGenerator >> addCallback [

	generatedClass := (FFICallback << self baseCallbackClassName asSymbol)
		traits: self libraryTrait;
		sharedPools: self sharedPoolNames;
		tag: self namespaceName;
		package: self packageName;
		install
]

{ #category : 'generation' }
CigPharoBaseCallbackClassGenerator >> generate [

	self addCallback
]
