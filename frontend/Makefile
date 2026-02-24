IMAGE_NAME = frontend-app
CONTAINER_NAME = frontend-container
PORT = 5173

.PHONY: build run

build:
	docker build -t $(IMAGE_NAME) .

run: build
	docker run -it --rm \
		-p $(PORT):$(PORT) \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)