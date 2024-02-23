run-martin: 
				docker run --net=host -e DATABASE_URL=postgresql://postgres:password@localhost/pneuma ghcr.io/maplibre/martin
# replace password postgres & host with your own
