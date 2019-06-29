from node:11.13
run npm install -g redoc-cli json-refs
workdir /code
entrypoint ["/bin/bash", "make-docs.sh"]
