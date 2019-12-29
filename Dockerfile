FROM python:3.7-buster

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN apt update && apt install -y zip && python3 -m pip install -U pip pipenv

WORKDIR /borg-windows-package

COPY Pipfile* ./
RUN pipenv sync --bare 

COPY requirements.txt get_cygwin_links.py package.sh ./

# mkdir -p dist/ && chcon -Rt fusefs_t dist/
CMD /borg-windows-package/package.sh