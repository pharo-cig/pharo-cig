"
This template handles arrays of structure parameters (e.g. struct mystruct arg[42]).
"
Class {
	#name : 'CigCParameterArrayOfStructTypeTemplate',
	#superclass : 'CigCParameterStructTypeTemplate',
	#category : 'CIG-C-Template',
	#package : 'CIG',
	#tag : 'C-Template'
}

{ #category : 'private' }
CigCParameterArrayOfStructTypeTemplate class >> handlesType: type [

	^ type isStructure 
		and: [ type isClass not
		and: [ type isPointer not
		and: [ type isArray ] ] ]
]

{ #category : 'generating' }
CigCParameterArrayOfStructTypeTemplate >> castReturn: aString [ 
	
	^ String streamContents: [ :stream | 
		stream << 'return (' << self generateCType << ')(' << aString << ')' ]
]

{ #category : 'generating' }
CigCParameterArrayOfStructTypeTemplate >> generateFFIType [
	| startArity parsed |

	startArity := 0.
	parsed := self type parseTypeTolerant.
	^ String streamContents: [ :stream |
		stream << super generateFFIType.
		(1 + startArity) to: parsed arity do: [ :each |
			stream << '_pointer' ].
		parsed arraySizes ifNotEmpty: [
			(parsed arraySizes size = 1 and: [ parsed arraySizes first = 0 ])
				ifTrue: [
					stream << '*' ]
				ifFalse: [
					stream << '_'.
					parsed arraySizes 
						do: [ :each | stream print: each ]
						separatedBy: [ stream << '_'] ] ] ]
]

{ #category : 'private' }
CigCParameterArrayOfStructTypeTemplate >> nameForArrayType: aType [

	^ CigPharoStructureGenerator new nameForArrayType: type
	"^ String streamContents: [ :stream | 
		stream << aType name. 
		aType parseType arraySizes do: [ :each | 
			stream << '[' << each asString << ']' ] ]"
]

{ #category : 'generating' }
CigCParameterArrayOfStructTypeTemplate >> registerRequiredTypeOn: aVisitor [
	
 	"do not register if it is an empty array (it will be a pointer)"
 	(type parseType arraySizes isEmpty 
 		or: [ type parseType arraySizes first = 0 ])
 		ifTrue: [ ^ self ].
 
	aVisitor 
		registerDeclaration: self element cTemplate generateFFITypeForField
		as: (self nameForArrayType: type)
]
