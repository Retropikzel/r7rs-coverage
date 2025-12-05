.PHONY: all html clean
.SILENT: test test-docker html index.html

SCHEME=chibi
DOCKERIMG=${SCHEME}:head

test:
	./coverage ${SCHEME}

test-docker:
	echo "Building docker image..."
	docker build --build-arg IMAGE=${DOCKERIMG} --build-arg SCHEME=${SCHEME} --tag=r7rs-coverage-${SCHEME} --quiet .
	docker run -v "${PWD}:/workdir" --workdir /workdir -t r7rs-coverage-${SCHEME} sh -c "make SCHEME=${SCHEME} test && chmod 755 *.log && chmod 755 errors.csv"

html: index.html

#index.html: errors.csv stats.scm
	#mit-scheme --load stats.scm --eval '(begin (format-stats) (%exit 0))'

index.html: errors.csv stats.scm
	gosh -r7 stats.scm

clean:
	rm -f *.log errors.csv
