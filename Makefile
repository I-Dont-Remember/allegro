test:
	ballerina test -a

docs:
	ballerina doc -a
	mv ./target/apidocs/ ./docs/
