.PHONY: build up down

build:
\tdocker-compose build

up:
\tdocker-compose up -d

down:
\tdocker-compose down
