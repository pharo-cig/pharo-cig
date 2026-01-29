Class {
	#name : 'CigFunctionTest',
	#superclass : 'CigBaseTest',
	#category : 'CIG-Tests-Base',
	#package : 'CIG-Tests',
	#tag : 'Base'
}

{ #category : 'tests' }
CigFunctionTest >> testFunctionWitCommentWilllGenerateComment [
	| unit element |
	
	unit := CigCLibraryGenerator new 
		packageName: 'Unit';
		prefix: 'Unit';
		importUnit: '
/**
 * This is a comment
 */
void someFunction();
';
		translateUnit.	

	self denyEmpty: unit elements.
	
	element := unit findElementMatching: [ :each | each name = 'someFunction()' ].
	
	self deny: element isNil.
	self assert: element phTemplate generate equals: 'someFunction
	"/**
	 * This is a comment
	 */"

	self ffiCall: #(void someFunction())'
]

{ #category : 'tests' }
CigFunctionTest >> testFunctionWithBooleanAsReturnWillBeParsedAsBooleanAndNotInt [
	"this error emerged while parsing mongoc"
	| unit element |
	
	unit := CigCLibraryGenerator new 
		packageName: 'Unit';
		prefix: 'Unit';
		importUnit: '
typedef Boolean bool;
bool mongoc_function_definition ();';
		translateUnit.	

	self denyEmpty: unit elements.
	
	element := unit findElementMatching: [ :each | each name = 'mongoc_function_definition()' ].
	
	self deny: element isNil.
	self assert: element returnTypeName equals: 'bool'
]

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
