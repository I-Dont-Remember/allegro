.PHONY: test docs
test:
	ballerina test -a

# would be cool if instead of phony we could force docs to compile if there are changes
docs:
	ballerina doc -a
	mkdir -p docs/
	cp -r ./target/apidocs/* ./docs/
	# make thyme module top level so github pages link isn't /thyme/thyme
	cp -r ./docs/thyme/* ./docs/
	# update index to point to correct location of resources
	sed -i.bak -r 's:\.\.\/:\.\/:g' docs/index.htmlm

