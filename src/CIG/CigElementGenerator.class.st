"
An element generator offers some post-process control to elements read from libclang ast traversing (because some times is needed some extra changes) 
"
Class {
	#name : 'CigElementGenerator',
	#superclass : 'Object',
	#instVars : [
		'transforms',
		'globalTransforms'
	],
	#category : 'CIG-Base',
	#package : 'CIG',
	#tag : 'Base'
}

{ #category : 'initialization' }
CigElementGenerator >> initialize [

	super initialize.
	globalTransforms := OrderedCollection new.
	transforms := OrderedDictionary new
]

{ #category : 'accessing' }
CigElementGenerator >> makeAllFunctionsReturningStringReturnPointer [

	self withUnitDo: [ :aUnit | 
		aUnit elements 
			select: [ :each | each isFunction and: [ each isReturnTypeCharPointer ] ]
			thenDo: [ :each | each makeReturnVoidPointer ] ]
]

{ #category : 'accessing' }
CigElementGenerator >> makeFunctionReturnPointer: aName [
	"Forces a void* return on a function. 
	 This is useful because a function can answer a char* (a string) and expect 
	 that you free it, but uFFI will automatically convert that return into a 
	 internal `String`, making it impossible to free it after.
	 See also `CigElementGenerator>>#makeAllFunctionsReturningStringReturnPointer`"

	self withName: aName do: [ :anElement | anElement makeReturnVoidPointer ]
]

{ #category : 'accessing' }
CigElementGenerator >> makeFunctionReturnVoidPointer: aName [

	self withName: aName do: [ :anElement | anElement makeReturnVoidPointer ]
]

{ #category : 'accessing' }
CigElementGenerator >> makeStructureOpaque: aName [

	self withName: aName do: [ :anElement | anElement makeOpaque ]
]

{ #category : 'accessing' }
CigElementGenerator >> postProcess: aUnit [
 
 	globalTransforms 
 		do: [ :each | each value: aUnit ].
 
	transforms keysAndValuesDo: [ :aName :aBlock | 
		aUnit elements 
			detect: [ :each | each name = aName ] 
			ifFound: [ :anElement | aBlock value: anElement ] ]
]

{ #category : 'accessing' }
CigElementGenerator >> removeElement: aName [

	self withName: aName do: [ :anElement |anElement remove ]
]

{ #category : 'accessing' }
CigElementGenerator >> withName: aName do: aBlock [

	transforms at: aName put: aBlock
]

{ #category : 'accessing' }
CigElementGenerator >> withUnitDo: aBlock [ 

	globalTransforms add: aBlock
]
