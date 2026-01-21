Class {
	#name : 'CXString',
	#superclass : 'CXExternalObject',
	#category : 'CIG-LibClang',
	#package : 'CIG-LibClang'
}

{ #category : 'accessing' }
CXString >> cString [

	^ self clang_getCString utf8StringFromCString
]

{ #category : 'private' }
CXString >> clang_disposeString [

	self ffiCall: #(void clang_disposeString(self))
]

{ #category : 'private' }
CXString >> clang_getCString [

	^ self ffiCall: #(void *clang_getCString(self))
]

{ #category : 'accessing' }
CXString >> dispose [

	self getHandle isNull ifTrue: [ ^ self ].
	self clang_disposeString.
	self getHandle beNull
]
