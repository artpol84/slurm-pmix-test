all: compiler_image.compiled

compiler_image.compiled: compiler_image.Dockerfile
	docker build -t artpol/compiler_image -f compiler_image.Dockerfile .
	touch compiler_image.compiled