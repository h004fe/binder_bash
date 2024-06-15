FROM python:3.9-slim
RUN pip install --no-cache notebook jupyterlab jupyterlab-git bash_kernel
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

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
RUN apt-get update && rm /etc/dpkg/dpkg.cfg.d/excludes
RUN apt-get update && apt-get install -y man-db manpages nano ed git && \
    rm -r /var/lib/apt/lists/*

USER ${NB_USER}
ENV PYTHONUNBUFFERED=1
#COPY /python3-login /usr/local/bin/python3-login
#COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint
#ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]
RUN chmod +x "${HOME}/start"
RUN ${HOME}/start
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
