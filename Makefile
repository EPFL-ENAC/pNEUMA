dev-martin: 
				docker run --net=host -e DATABASE_URL=postgresql://postgres:password@localhost/pneuma ghcr.io/maplibre/martin
# replace password postgres & host with your own

dev-front:
	$(MAKE) -C webmap dev


dev-all:
	gnome-terminal --tab -- bash -c '$(MAKE) dev-front'
	$(MAKE) dev-martin
