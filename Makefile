SCHEME=chibi
DOCKERIMG=${SCHEME}:latest

test:
	rm -rf venv
	scheme-venv ${SCHEME} r7rs venv
	./coverage ${SCHEME} "$(shell ./venv/bin/scheme-version)"

test-docker:
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=r7rs-coverage-${SCHEME} -f Dockerfile.test .
	docker run --memory=2G --cpus=2 -v "${PWD}:/workdir" --workdir /workdir -t r7rs-coverage-${SCHEME} sh -c "make SCHEME=${SCHEME} test"

report: index.html

index.html: results.csv stats.scm
	gosh -r7 stats.scm

clean:
	rm -f *.log results.csv
