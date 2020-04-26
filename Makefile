.PHONY: test docs
test:
	ballerina test -a

# would be cool if instead of phony we could force docs to compile if there are changes
docs:
	ballerina doc -a
	mkdir -p docs/
	cp -r ./target/apidocs/* ./docs/
