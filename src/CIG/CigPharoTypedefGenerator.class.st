Class {
	#name : 'CigPharoTypedefGenerator',
	#superclass : 'CigPharoGenerator',
	#category : 'CIG-Pharo-Generator',
	#package : 'CIG',
	#tag : 'Pharo-Generator'
}

{ #category : 'generating' }
CigPharoTypedefGenerator >> generate [
	"in fact, typedef just has to register to be added after"
]

{ #category : 'generation' }
CigPharoTypedefGenerator >> generateOn: aVisitor [
	| declaration template |
	
	declaration := self element cDeclaration.
	template := self element phTemplate generate.

	self element definesFunctionPointer 
		ifTrue: [ aVisitor ensureBaseCallbackClass: self element root ].

	logger trace: declaration.
	logger trace: template.

	super generateOn: aVisitor.
	aVisitor registerDeclaration: declaration as: template
]
