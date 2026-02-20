SCHEME=chibi
DOCKER_IMG_TAG=latest
DOCKER_IMG=${SCHEME}:${DOCKER_IMG_TAG}

ifeq "${SCHEME}" "gambit"
DOCKER_IMG="gambit:head"
endif

test:
	rm -rf venv
	scheme-venv ${SCHEME} r7rs venv
	./coverage ${SCHEME} "$(shell ./venv/bin/scheme-version)"

test-docker:
	docker build --build-arg IMAGE=${DOCKER_IMG} --build-arg SCHEME=${SCHEME} --tag=r7rs-coverage-${SCHEME} -f Dockerfile.test .
	docker run -v "${PWD}/results:/workdir/results" -v "${PWD}/logs:/workdir/logs" --workdir /workdir -t r7rs-coverage-${SCHEME} sh -c "make SCHEME=${SCHEME} test; chmod 775 -R logs/*.log; chmod 755 -R results"

report: index.html

index.html: results/results.csv stats.scm
	gosh -r7 stats.scm

clean:
	rm -rf *.log logs results
