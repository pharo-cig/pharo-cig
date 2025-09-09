Class {
	#name : 'CXString',
	#superclass : 'CXExternalObject',
	#category : 'CIG-LibClang',
	#package : 'CIG-LibClang'
}

{ #category : 'accessing' }
CXString >> cString [

	^ self clang_getCString copy
]

{ #category : 'private' }
CXString >> clang_disposeString [

	self ffiCall: #(void clang_disposeString(self))
]

{ #category : 'private' }
CXString >> clang_getCString [

	^ self ffiCall: #(char *clang_getCString(self))
]

{ #category : 'accessing' }
CXString >> dispose [

	self getHandle isNull ifTrue: [ ^ self ].
	self clang_disposeString.
	self getHandle beNull
]
