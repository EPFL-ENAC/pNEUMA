build:
	docker build -t pneuma-database .
run:
	docker run -e POSTGRES_PASSWORD=password -p 5432:5432 -v pneuma-db-data:/var/lib/postgresql/data pneuma-database
