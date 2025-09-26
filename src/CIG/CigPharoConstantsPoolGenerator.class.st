Class {
	#name : 'CigPharoConstantsPoolGenerator',
	#superclass : 'CigPharoGenerator',
	#instVars : [
		'generatedClassName'
	],
	#category : 'CIG-Pharo-Generator',
	#package : 'CIG',
	#tag : 'Pharo-Generator'
}

{ #category : 'private' }
CigPharoConstantsPoolGenerator class >> constantsTemplate [

	^ '
#if defined(__clang__)
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Weverything"
#endif
#define REQUIRE_EXPR(x) ((void)sizeof((void)(x)))
#define AFTER_EXPR(x, expr) (REQUIRE_EXPR(x), (expr))
#define print_macro(x) \
    AFTER_EXPR(x, _Generic((x), \
        char:               printf(#x "=%d\n",  (int)(x)), \
        signed char:        printf(#x "=%d\n",  (int)(x)), \
        unsigned char:      printf(#x "=%u\n",  (unsigned)(x)), \
        short:              printf(#x "=%d\n",  (int)(x)), \
        unsigned short:     printf(#x "=%u\n",  (unsigned)(x)), \
        int:                printf(#x "=%d\n",  (x)), \
        unsigned:           printf(#x "=%u\n",  (x)), \
        long:               printf(#x "=%ld\n", (x)), \
        unsigned long:      printf(#x "=%lu\n", (x)), \
        long long:          printf(#x "=%lld\n",(x)), \
        unsigned long long: printf(#x "=%llu\n",(x)), \
        float:              printf(#x "=%f\n",  (double)(x)), \
        double:             printf(#x "=%f\n",  (x)), \
        long double:        printf(#x "=%Lf\n", (x)), \
        char *:             printf(#x "=\"%s\"\n",  (x)), \
        const char *:       printf(#x "=\"%s\"\n",  (x)), \
        default:            printf(#x "=[CIGUNSUPORTED]\n") \
    ))
'
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> addClass [
	| constantsName generatedClass |

	constantsName := self libraryConstantsName.
	generatedClass := SharedPool << constantsName asSymbol
		sharedVariables: #(); 
		tag: 'Library';
		package: self packageName;
		install.
		
	generatedClassName := generatedClass name
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> collectConstantsToGenerate: aCollection [ 

	"they are printable but not literals, I try to retrieve its value and 
	 then reset source/printable status"
	aCollection 
		reject: [ :each | each isLiteral ] 
		thenDo: [ :each | self retrieveLiteralConstantIn: each ].
	
	"now I will have all macro printables with values solved (that I can use)"
	^ aCollection select: [ :each | each isPrintable ]
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> compileCFileFrom: sourceReference [
	| result binaryReference command |

	logger trace: sourceReference.

	binaryReference := sourceReference withoutExtension ensureDelete.
	command := 'clang {3} {1} -o {2}' format: { 
		sourceReference basename. 
		binaryReference basename.
		String streamContents: [ :stream |
			self file cIncludePathsAsArguments
				do: [ :each | stream << each ] 
				separatedBy: [ stream space ] ] }.
	
	CigCommandExecutor execute: command. 

	^ binaryReference
	
]

{ #category : 'generating' }
CigPharoConstantsPoolGenerator >> generate [

	^ self addClass
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> generateCFileFor: aMacroName [
	| fileReference |

	fileReference := (FileLocator temp 
		/ 'CIG' 
		/ 'macro_to_constant') 
		withExtension: 'c'.
	fileReference parent ensureCreateDirectory.
	
	fileReference 
		ensureDelete;
		writeStreamDo: [ :stream | 
		
			stream << '#import <stdio.h>'; lf.
			
			self file constantGenerator headers
				ifNotNil: [ :aCollection | 
					aCollection 
						do: [ :each | stream << '#import <' << each << '>' ]
						separatedBy: [ stream lf ] ]
				ifNil: [
					self file imports 
						do: [ :eachTarget | 
							eachTarget isUnit 
								ifTrue: [ stream << eachTarget unit ]
								ifFalse: [ stream << '#import <' << eachTarget name << '>' ] ]
						separatedBy: [ stream lf ] ].

			stream << self class constantsTemplate; lf.
			
			stream << 'int main() {'; lf; tab. 
			stream << 'print_macro(' << aMacroName << ');'; lf; tab.
			stream << 'return 0;'; lf.
			stream << '}' ].

	^ fileReference
]

{ #category : 'generating' }
CigPharoConstantsPoolGenerator >> generateConstants: aCollection [
	| constantsToGenerate |

	constantsToGenerate := self collectConstantsToGenerate: aCollection.

	self groupStrategy 
		addConstants: constantsToGenerate 
		to: self libraryConstantsClass
		in: self file
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> generatedClass [

	^ self class environment classNamed: generatedClassName
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> groupStrategy [

	^ self file constantGenerator groupStrategy
]

{ #category : 'private' }
CigPharoConstantsPoolGenerator >> retrieveLiteralConstantIn: aMacroDefinition [

	| sourceReference binaryReference result source |
	logger trace: aMacroDefinition. "if this is just a definition, it means 1, because 
		#define SOMEMACRO 
		is equivalent to 
		#define SOMEMACRO 1"
	aMacroDefinition source isEmptyOrNil ifTrue: [
			aMacroDefinition updateSourceWith: '1'.
			^ self ].

	sourceReference := self generateCFileFor: aMacroDefinition name.
	[ binaryReference := self compileCFileFrom: sourceReference ]
		on: CigCommandExecutionError
		do: [ :e |
				logger info: 'Skipping ' , aMacroDefinition name , ': TYPE NOT SUPPORTED'.
				logger error: e.
				aMacroDefinition makeNotPrintable.
				^ self ].

	result := (CigCommandExecutor execute: binaryReference fullName) trimBoth.
	result
		ifNotEmpty: [
				| newSource |
				newSource := (result trimBoth substrings: '=') second.
				(newSource isNotEmpty and: [ newSource ~= '[CIGUNSUPORTED]' ])
					ifTrue: [ "ok, we have a real value" aMacroDefinition updateSourceWith: newSource ]
					ifFalse: [ "program worked, but I do not have a result"
							logger info: 'Skipping ' , aMacroDefinition name , ': TYPE NOT SUPPORTED'.
							aMacroDefinition makeNotPrintable ] ]
		ifEmpty: [ "for some reason program didn't answer anything (this should not happen)"
				logger info: 'Skipping ' , aMacroDefinition name , ': NOT PRINTABLE (UNKNOWN REASONS)'.
				aMacroDefinition makeNotPrintable ]
]
