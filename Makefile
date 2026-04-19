SCHEME=chibi
DOCKER_IMG_TAG=latest
DOCKER_IMG=${SCHEME}:${DOCKER_IMG_TAG}

test:
	./coverage ${SCHEME}

test-docker:
	docker build --build-arg IMAGE=${DOCKER_IMG} --build-arg SCHEME=${SCHEME} --tag=r7rs-coverage-${SCHEME} -f Dockerfile.test .
	docker run \
		--memory=2G --cpus=2 \
		-v "${PWD}/results:/workdir/results" \
		-v "${PWD}/logs:/workdir/logs" \
		--workdir /workdir \
		-t r7rs-coverage-${SCHEME} \
		sh -c "make SCHEME=${SCHEME} test; chmod -R 775 logs/*.log; chmod -R 755 results"

report: index.html

results/results.csv:
	rm -rf results/results.csv
	cat results/*.csv > results/results.csv

index.html: results/results.csv stats.scm
	gosh -r7 stats.scm

clean:
	rm -rf *.log logs results
