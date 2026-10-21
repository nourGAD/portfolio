IMAGE ?= portfolio:local

.PHONY: build run test k8s-render tf-validate clean

build:
	docker build -t $(IMAGE) .

run: build
	docker run --rm -p 8080:8080 $(IMAGE)

test: build
	docker run -d --name portfolio-test -p 8080:8080 $(IMAGE)
	sleep 2
	curl -fs localhost:8080/healthz
	curl -fs localhost:8080/ | grep -q "Nour Gad" && echo "page OK"
	docker rm -f portfolio-test

k8s-render:
	kubectl kustomize deploy/k8s

tf-validate:
	cd deploy/terraform && terraform fmt -check && terraform init -backend=false && terraform validate

clean:
	-docker rm -f portfolio-test
	-docker rmi $(IMAGE)
