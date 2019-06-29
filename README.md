This repo contains all backend systems that are part of project rewrite. Though
they are in one repo, every system is independently deployable.

For information about each service, view the corresponding `README` file under each
directory.

## Pre-requisites

- Git LFS
  - We uses git-lfs for versioning of large size files specified in
    [.gitattributes](https://github.com/Shuttl-Tech/monorepo/blob/master/.gitattributes)
file.
  - [Documentation Link](https://git-lfs.github.com/)
  - If you're install git-lfs **after** cloning the repository, make sure to
    run `git lfs fetch` to ensure all old files are pulled.
- Docker
  - Download Docker Desktop from [Docker Store](https://store.docker.com/editions/community/docker-ce-desktop-mac)

## Installation & Usage

- Clone this repository
- Run `docker-compose up [your-service-name]` in the project root. For e.g.,
  `docker-compose up user_profile_web`
- Your service should be up and running now (along with any dependencies).
  Check docker-compose.yml to know the system port mapping.
