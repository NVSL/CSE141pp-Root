default:
install:
TESTS?=.*
test: clean zip
	bats -f "$(TESTS)" test.bats 

.PHONY:zip
zip:
	./build_zip.sh

clean:
	rm -rf *.zip
	rm -rf gradescope
	rm -rf test_autograder
	rm -rf gradescope-zipballs

.PHONY: test-gradescope.image
test-gradescope.image:
	docker build --progress plain --build-arg ZIP_BALL=$(ZIP_BALL) --file gradescope-test.docker --tag gradescope-test --no-cache .

.PHONY:test-gradescope
test-gradescope:
	rm -rf test_gradescope
	mkdir -p test_gradescope
	git clone $(TEST_LAB) test_gradescope/submission
	mkdir -p test_gradescope/results
	docker run -it  --volume $(WORK_OUTSIDE_OF_DOCKER)/gradescope/test_gradescope/submission:/autograder/submission --volume  $(WORK_OUTSIDE_OF_DOCKER)/gradescope/test_gradescope/results:/autograder/results gradescope-test
