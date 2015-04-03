all: dev_image.compiled

dev_image.compiled: dev_image.Dockerfile
	docker build -t artpol/dev_image -f dev_image.Dockerfile .
	touch dev_image.compiled