FROM python:3.7.1

RUN /usr/local/bin/pip install pipenv

WORKDIR /app

ADD Pipfile /app
ADD Pipfile.lock /app


RUN /usr/local/bin/pipenv install --dev --system

# Add these files AFTER pipenv install so that rebuilds are quick if Pipfile
# hasn't changed
ADD . /app


EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
