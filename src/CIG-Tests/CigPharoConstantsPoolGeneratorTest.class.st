Class {
	#name : 'CigPharoConstantsPoolGeneratorTest',
	#superclass : 'TestCase',
	#category : 'CIG-Tests-Pharo',
	#package : 'CIG-Tests',
	#tag : 'Pharo'
}

{ #category : 'running' }
CigPharoConstantsPoolGeneratorTest >> tearDown [

	PackageOrganizer default 
		packageNamed: #UnitToTest
		ifPresent: [ :aPackage | aPackage removeFromSystem ].
		
	super tearDown
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testAddConstantsTo [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		withConstantGenerator: [ :gen | gen doNotGroup ];
		importUnit: '
#define MACRO_DEC 			42
#define MACRO_HEX 			0x2A
#define MACRO_OCT 			052
#define MACRO_BIN 			0b101010
#define MACRO_STRING 		"Hello, World"
#define MACRO_CHAR 			''A''';
		yourself.
		
	unit := file translateUnit.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen groupStrategy
		addConstants: (unit elements select: [ :each | each isMacroDefinition ])
		to: gen generatedClass.
	result := gen generatedClass.

	self assert: result name equals: 'UnittotestConstants'.
	self assert: result classPool size equals: 6
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testCollectConstantValues [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		withConstantGenerator: [ :gen | gen doNotGroup ];
		importUnit: '
#define MACRO_DEC 42
#define MACRO_HEX 0x2A
#define MACRO_OCT 052
#define MACRO_BIN 0b101010
#define MACRO_STRING "Hello, World"
#define MACRO_CHAR ''A''';
		yourself.
		
	unit := file translateUnit.
	file constantGenerator preferDecimal.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 

	result := gen groupStrategy 
		collectConstantValues: (unit elements select: [ :each | each isMacroDefinition ]).

	self assert: (result at: 'MACRO_DEC') equals: '42'.
	self assert: (result at: 'MACRO_HEX') equals: '16r2A'.
	self assert: (result at: 'MACRO_OCT') equals: '8r52'.
	self assert: (result at: 'MACRO_BIN') equals: '2r101010'.
	self assert: (result at: 'MACRO_STRING') equals: '''Hello, World'''.	
	self assert: (result at: 'MACRO_CHAR') equals: '$A'
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testEmptyDefineWillGenerateTrue [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		withConstantGenerator: [ :gen | 
			gen includeEmptyDefinitions; doNotGroup ];
		importUnit: '
#define MACRO
';
		yourself.
		
	unit := file translateUnit.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen generateConstants: unit elements copy.
	result := gen generatedClass.

	self assert: result name equals: 'UnittotestConstants'.
	self assert: result classPool size equals: 1.
	self assert: result MACRO equals: 1
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testGenerateConstants [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		importUnit: '
#define MACRO_DEC 42
#define MACRO_HEX 0x2A
#define MACRO_OCT 052
#define MACRO_BIN 0b101010
#define MACRO_STRING "Hello, World"
#define MACRO_CHAR ''*''';
		yourself.
		
	unit := file translateUnit.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen generateConstants: (unit elements select: [ :each | each isMacroDefinition ]).
	result := gen generatedClass.

	self assert: result name equals: 'UnittotestConstants'.
	self assert: result classPool size equals: 6.
	
	self assert: result MACRO_DEC equals: 42.
	self assert: result MACRO_HEX equals: 42.
	self assert: result MACRO_OCT equals: 42.
	self assert: result MACRO_BIN equals: 42.
	self assert: result MACRO_STRING equals: 'Hello, World'.
	self assert: result MACRO_CHAR equals: $*
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testIgnoreConstantThatExpandsToAFunction [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		importUnit: '
#define MACRO_NUMBER 42
#define MACRO_FUNCTION(x) printf(x)
#define MACRO_STRING "A STRING"';
		yourself.

	unit := file translateUnit.
	
	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen generateConstants: (unit elements select: [ :each | each isMacroDefinition ]).
	result := gen generatedClass.
	
	self assert: result classPool size equals: 2
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testLiteralValueOf [
	| gen |

	gen := CigConstantGeneratorGroupStrategy new
		configureWith: CigConstantGenerator new;
		yourself.
	
	self assert: (gen literalValueOf: '0x2A') equals: '16r2A'.
	self assert: (gen literalValueOf: '0b101010') equals: '2r101010'.
	self assert: (gen literalValueOf: '052') equals: '8r52'.
	self assert: (gen literalValueOf: '0') equals: '0'.
	self assert: (gen literalValueOf: '"Hello, World"') equals: '''Hello, World'''.
	self assert: (gen literalValueOf: '"Hello, ''World''"') equals: '''Hello, ''''World'''''''.
	self assert: (gen literalValueOf: '''A''') equals: '$A'.	
	self assert: (gen literalValueOf: '0.01') equals: '0.01'.
	self assert: (gen literalValueOf: '0.01F') equals: '0.01'.
	
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testMacroWithMacroCombinationWillGenerateAValue [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		withConstantGenerator: [ :gen | gen doNotGroup ];
		importUnit: '
#define MACRO_START 0x0F 
#define MACRO_END 	0xF0
#define MACRO MACRO_START | MACRO_END
';
		yourself.
		
	unit := file translateUnit.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen generateConstants: (unit elements select: [ :each | each isMacroDefinition ]).
	result := gen generatedClass.

	self assert: result name equals: 'UnittotestConstants'.
	self assert: result classPool size equals: 3.
	self assert: result MACRO equals: 16rFF
]

{ #category : 'tests' }
CigPharoConstantsPoolGeneratorTest >> testMacroWithMathOperationWillGenerateANumber [
	| gen file unit result |

	file := CigCLibraryGenerator new 
		packageName: 'UnitToTest';
		libraryName: 'unittotest';
		withConstantGenerator: [ :gen | gen doNotGroup ];
		importUnit: '
#define MACRO 1 << 2
';
		yourself.
		
	unit := file translateUnit.

	gen := CigPharoConstantsPoolGenerator newFile: file unit: unit. 
	gen addClass.
	gen generateConstants: (unit elements select: [ :each | each isMacroDefinition ]).
	result := gen generatedClass.

	self assert: result name equals: 'UnittotestConstants'.
	self assert: result classPool size equals: 1.
	self assert: result MACRO equals: 4
]
