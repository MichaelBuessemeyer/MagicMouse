accessing
parseImage: payload into: aMaybeUsedForm

	| format png form |
	format := payload unsignedCharAt: 2.
	format = $r
		ifTrue: [ | width height |
			width := payload unsignedLongAt: 3.
			height := payload unsignedLongAt: 7.
			png := payload copyFrom: 11 to: payload size.
			form := Form extent: width @ height depth: 32.
			1 to: width * height - 1 do: [:index |
				form bits
					at: index
					put: (png at: index * 4 + 3) asInteger << 0 + ((png at: index * 4 + 2) asInteger << 8) + ((png at: index * 4 + 1) asInteger << 16) + ((png at: index * 4 + 0) asInteger << 24)]]
		ifFalse: [ | reader |
			format caseOf: {
				[$p] -> [
					reader := PNGReadWriter on: (payload copyFrom: 3 to: payload size) readStream.
					form := reader nextImage].
				[$j] -> [
					reader := MMFastJPEGReader on: (payload readStream
						skip: 2;
						yourself).
					form := reader nextImage: aMaybeUsedForm]}].
	^ form