build:
	@docker-compose -p ha build
run:
	@docker-compose -p ha up -d
stop:
	@docker-compose -p ha stop
clean:	stop
	@docker-compose -p ha rm master nginx #registry
clean-images:
	@docker rmi 'docker images -q -f "dangling=true"'