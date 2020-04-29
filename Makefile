.PHONY: test docs
test:
	ballerina test -a

push:
	# build it first
	ballerina build -c thyme
	ballerina push thyme

# would be cool if instead of phony we could force docs to compile if there are changes
docs:
	ballerina doc -a
	mkdir -p docs/
	cp -r ./target/apidocs/* ./docs/
	# make thyme module top level so github pages link isn't /thyme/thyme
	cp -r ./docs/thyme/* ./docs/
	# remove the original
	rm -rf ./docs/thyme/
	# update index to point to correct location of resources and nav
	sed -i -r 's:\.\.\/:\.\/:g' docs/index.html
	sed -i -r 's:\.\/thyme\/:\.\/:g' docs/index.html
	# update functions file
	sed -i -r 's:\.\.\/:\.\/:g' docs/functions.html
	sed -i -r 's:\.\/thyme\/:\.\/:g' docs/functions.html
	# lower directories we have to fix path different ../../ becomes ../ (specify multiple like {objects,types})
	find docs/objects/ -type f -name '*.html' -exec sed -i -r 's:\.\.\/\.\.\/:\.\.\/:g' {} \;
	# update ../thyme to ../
	find docs/objects/ -type f -name '*.html' -exec sed -i -r 's:\.\.\/thyme\/:\.\.\/:g' {} \;
