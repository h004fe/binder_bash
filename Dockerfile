FROM python:3.9-slim
RUN pip install --no-cache notebook jupyterlab
ENV HOME=/tmp

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

USER ${NB_USER}
ENV PYTHONUNBUFFERED=1
#COPY /python3-login /usr/local/bin/python3-login
#COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint
#ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
