dev-martin: 
				docker run --rm --net=host -e DATABASE_URL=postgresql://postgres:password@localhost/postgres ghcr.io/maplibre/martin
# replace password postgres & host with your own

dev-front:
	$(MAKE) -C webmap dev


dev-all:
	gnome-terminal --tab -- bash -c '$(MAKE) dev-front'
	$(MAKE) dev-martin
