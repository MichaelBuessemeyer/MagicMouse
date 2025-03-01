starting
startCommand: command withArguments: arguments

	| stdout outPipe stderr errPipe stdin inPipe |
	outPipe := OSPipe nonBlockingPipe.
	stdout := outPipe writer.
	
	errPipe := OSPipe nonBlockingPipe.
	stderr := errPipe writer.
	
	inPipe := OSPipe blockingPipe.
	stdin := inPipe reader.
	stdinWriter := inPipe writer binary.
	
	process := UnixProcess
		forkJob: command
		arguments: (arguments collect: #asString)
		environment: nil
		descriptors: {stdin. stdout. stderr}.
	
	stdoutReader := outPipe reader asMMBufferedStream.
	stdoutReader
		setBlocking;
		throwTimeoutError: self throwsTimeoutError;
		binary.
	
	debug ifTrue: [ | stderrReader process |
		Transcript clear.
		stderrReader := errPipe reader.
		stderrReader ascii.
		process := [
			[stderrReader closed] whileFalse: [
				stderrReader next
					ifNil: [(Delay forSeconds: 1) wait]
					ifNotNil: [:next | Transcript show: next]]] fork.
		self debugLoggingProcess: process]