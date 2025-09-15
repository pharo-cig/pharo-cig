Class {
	#name : 'CigFunctionTest',
	#superclass : 'CigBaseTest',
	#category : 'CIG-Tests-Base',
	#package : 'CIG-Tests',
	#tag : 'Base'
}

{ #category : 'tests' }
CigFunctionTest >> testFunctionWithDefineAtTheEndWillBeRead [
	| unit |
	
	unit := CigCLibraryGenerator new 
		packageName: 'Unit';
		prefix: 'Unit';
		importUnit: '
#define SOMEMACRO
#define EXPORT(x) x
EXPORT (void *)
aFunction (const char *anArgument) SOMEMACRO;';
		translateUnit.	

	self denyEmpty: unit elements.
	self assert: (unit findElementMatching: [ :each | each name = 'aFunction(const char *)' ]) isNotNil.
]
