DOCKER_CMD = docker run \
	--rm -t -i \
	-e GIT_AUTHOR_NAME \
	-e GIT_AUTHOR_EMAIL \
	-e GIT_COMMITTER_NAME="$$GIT_AUTHOR_NAME" \
	-e GIT_COMMITTER_EMAIL="$$GIT_AUTHOR_EMAIL" \
	-v $$(pwd):/opt/build \
	dock0/pkgforge

.PHONY : default manual dircheck container

default: dircheck container auth
	$(DOCKER_CMD)

manual: dircheck container auth
	$(DOCKER_CMD) bash || true

ifdef GITHUB_CREDS
auth:
	git config 'url.https://github.com/.insteadOf' 'git@github.com:'
	git config credential.helper 'store --file=/opt/build/.github'
	@echo "https://$(GITHUB_CREDS)@github.com" > .github || true
	@echo "targit: $(GITHUB_CREDS)" > .targit || true
else
auth:
	@true
endif

ifneq ("$(wildcard .pkgforge)","")
dircheck:
	@true
else
dircheck:
	@echo ".pkgforge not found; run make from the repo root"
	@false
endif

ifneq ("$(wildcard Dockerfile)","")
CONTAINER_NAME = $$(pkgforge info | awk '/^name: / {print $$2}')
container:
	docker build -t $(CONTAINER_NAME)-pkg
else
container:
	@true
endif

