"
An element generator offers some post-process control to elements read from libclang ast traversing (because some times is needed some extra changes) 
"
Class {
	#name : 'CigElementGenerator',
	#superclass : 'Object',
	#instVars : [
		'transforms'
	],
	#category : 'CIG-Base',
	#package : 'CIG',
	#tag : 'Base'
}

{ #category : 'initialization' }
CigElementGenerator >> initialize [

	super initialize.
	transforms := Dictionary new
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
