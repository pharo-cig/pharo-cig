Class {
	#name : 'CigPharoTypedefCallbackTemplate',
	#superclass : 'CigPharoTypedefTemplate',
	#category : 'CIG-Pharo-Template',
	#package : 'CIG',
	#tag : 'Pharo-Template'
}

{ #category : 'private' }
CigPharoTypedefCallbackTemplate class >> handlesElement: anElement [

	^ anElement definesFunctionPointer
]

{ #category : 'accessing' }
CigPharoTypedefCallbackTemplate >> generate [

	^ (self element root nameGenerator prefixToUse: self element root prefix) , 'Callback'
]
