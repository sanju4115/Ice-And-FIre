# Ice And Fire

## Overview
1. GET http://localhost:8080/api/external-books?name=:nameOfABook
2. POST http://localhost:8080/api/v1/books
3. GET http://localhost:8080/api/v1/books
4. PATCH http://localhost:8080/api/v1/books/:id
5. DELETE http://localhost:8080/api/v1/books/:id
6. GET http://localhost:8080/api/v1/books/:id


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them

1. **Docker**: [Install](https://docs.docker.com/) this is the container required to run an instance and its dependencies.
2. **Docker Compose**: [Install](https://docs.docker.com/compose/install/) Compose is a tool for defining and running multi-container Docker applications.
   With Compose, you use a YAML file to configure your application’s services  

### Installing

#### Local Installation

1. Clone the repository via ssh/http.
2. From the Root folder run below commands in order
  - ```docker-compose build book_web``` (To Build the docker images)
  - ```docker-compose up book_web``` (To start the application with all its dependencies and Meta data created)
  - ```docker-compose down --remove-orphans``` (To Stop the application and remove all the containers)

Hit `http:localhost:9134/` with all the API routes.

You can now proceed to test the APIs using Postman or implement new features.

## Running the tests

### Automated test cases
To run the automated tests for this system, follow the instructions below:
  - ```docker exec -it monorepo_supply_web_1 bash ```(to enter into the shell of the supply backend container started above)
  - ```pytest``` (From the command line run the pytests)

### Test coverage
To check test coverage report, follow the instructions below:

  - ```pytest --cov=supply_web```


