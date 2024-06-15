FROM docker.io/library/buildpack-deps:jammy
#FROM debian
ENV DEBIAN_FRONTEND=noninteractive

ENV DEBCONF_NOWARNINGS yes
#RUN apt-get -qq update && apt-get -qq install --yes --no-install-recommends locales > /dev/null && apt-get -qq purge && apt-get -qq clean && rm -rf /var/lib/apt/lists/*
RUN apt-get -qq update && apt-get -qq install --yes  --no-install-recommends locales  > /dev/null
RUN apt-get -qq purge 
RUN apt-get -qq clean
RUN rm -rf /var/lib/apt/lists/*

#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen

ENV LC_ALL=en_US.UTF-8     LANG=en_US.UTF-8     LANGUAGE=en_US.UTF-8
ENV SHELL=/bin/bash
ARG NB_USER
ARG NB_UID
ENV USER=${NB_USER} HOME=/home/${NB_USER}

RUN which groupadd

#RUN groupadd --gid ${NB_UID} ${NB_USER} && useradd --comment "Default user" --create-home --gid ${NB_UID} --no-log-init --shell /bin/bash --uid ${NB_UID} ${NB_USER}
#RUN groupadd -gid ${NB_UID} ${NB_USER}
#RUN useradd --comment "Default user" --create-home --gid ${NB_UID} --no-log-init --shell /bin/bash --uid ${NB_UID} ${NB_USER}

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

#RUN apt-get -qq update && apt-get -qq install --yes --no-install-recommends gettext-base less unzip > /dev/null && apt-get -qq purge && apt-get -qq clean && rm -rf /var/lib/apt/lists/*
RUN apt-get -qq update && apt-get -qq install --yes  --no-install-recommends gettext-base
RUN apt-get -qq update && apt-get -qq install --yes  --no-install-recommends less
RUN apt-get -qq update && apt-get -qq install --yes  --no-install-recommends unzip
RUN apt-get -qq purge
RUN apt-get -qq clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 8888
ENV APP_BASE=/srv
ENV CONDA_DIR=${APP_BASE}/conda
ENV NB_PYTHON_PREFIX=${CONDA_DIR}/envs/notebook
ENV NPM_DIR=${APP_BASE}/npm
ENV NPM_CONFIG_GLOBALCONFIG=${NPM_DIR}/npmrc
ENV NB_ENVIRONMENT_FILE=/tmp/env/environment.lock
ENV MAMBA_ROOT_PREFIX=${CONDA_DIR}
ENV MAMBA_EXE=${CONDA_DIR}/bin/mamba
ENV CONDA_PLATFORM=linux-64
ENV KERNEL_PYTHON_PREFIX=${NB_PYTHON_PREFIX}
ENV PATH=${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${NPM_DIR}/bin:${PATH}
#COPY --chown=1000:1000 build_script_files/-2fopt-2fvenv-2flib-2fpython3-2e11-2fsite-2dpackages-2frepo2docker-2fbuildpacks-2fconda-2factivate-2dconda-2esh-e70a7b /etc/profile.d/activate-conda.sh
#COPY --chown=1000:1000 build_script_files/-2fopt-2fvenv-2flib-2fpython3-2e11-2fsite-2dpackages-2frepo2docker-2fbuildpacks-2fconda-2fenvironment-2epy-2d3-2e10-2dlinux-2d64-2elock-8fa955 /tmp/env/environment.lock
#COPY --chown=1000:1000 build_script_files/-2fopt-2fvenv-2flib-2fpython3-2e11-2fsite-2dpackages-2frepo2docker-2fbuildpacks-2fconda-2finstall-2dbase-2denv-2ebash-6a6072 /tmp/install-base-env.bash

#RUN TIMEFORMAT='time: %3R' bash -c 'time /tmp/install-base-env.bash' && rm -rf /tmp/install-base-env.bash /tmp/env
#RUN TIMEFORMAT='time: %3R' bash -c 'time /tmp/install-base-env.bash'
#RUN rm -rf /tmp/install-base-env.bash /tmp/env

#RUN mkdir -p ${NPM_DIR} && chown -R ${NB_USER}:${NB_USER} ${NPM_DIR}
RUN mkdir -p ${NPM_DIR}
RUN chown -R ${NB_USER}:${NB_USER} ${NPM_DIR}

USER root
ARG REPO_DIR=${HOME}
ENV REPO_DIR=${REPO_DIR}
#if [ $? -eq 0 ]; then echo TRUE; else echo FALSE; fi
RUN /usr/bin/install -o ${NB_USER} -g ${NB_USER} -d "${REPO_DIR}"
#RUN if [ ! -d "${REPO_DIR}" ]; then /usr/bin/install -o ${NB_USER} -g ${NB_USER} -d "${REPO_DIR}"; fi
WORKDIR ${REPO_DIR}
RUN chown ${NB_USER}:${NB_USER} ${REPO_DIR}
ENV PATH=${HOME}/.local/bin:${REPO_DIR}/.local/bin:${PATH}
ENV CONDA_DEFAULT_ENV=${KERNEL_PYTHON_PREFIX}
RUN ls
COPY --chown=1000:1000 src/environment.yml ${REPO_DIR}/environment.yml

#RUN apt-get -qq update && apt-get install --yes --no-install-recommends $(cat ${REPO_DIR}/apt.txt) && apt-get -qq purge && apt-get -qq clean && rm -rf /var/lib/apt/lists/*
RUN apt-get -qq update
RUN apt-get install --yes --no-install-recommends $(cat ${REPO_DIR}/apt.txt)
RUN apt-get -qq purge
RUN apt-get -qq clean
RUN rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

#RUN TIMEFORMAT='time: %3R' bash -c 'time ${MAMBA_EXE} env update -p ${NB_PYTHON_PREFIX} --file "environment.yml" && time ${MAMBA_EXE} clean --all -f -y && ${MAMBA_EXE} list -p ${NB_PYTHON_PREFIX} '
RUN TIMEFORMAT='time: %3R' bash -c 'time ${MAMBA_EXE} env update -p ${NB_PYTHON_PREFIX} --file "environment.yml" && time ${MAMBA_EXE} clean --all -f -y && ${MAMBA_EXE} list -p ${NB_PYTHON_PREFIX} '

USER root
COPY --chown=1000:1000 src/ ${REPO_DIR}/
LABEL repo2docker.ref="e7d9ce798fbc449b8e107528c9be0590de2c4acb"
LABEL repo2docker.repo="https://github.com/h004fe/binder_bash"
LABEL repo2docker.version="2024.03.0+21.g09f3d53"
USER ${NB_USER}
RUN chmod +x postBuild
RUN ./postBuild
RUN chmod +x "${REPO_DIR}/start"
ENV R2D_ENTRYPOINT="${REPO_DIR}/start"
ENV PYTHONUNBUFFERED=1
COPY /python3-login /usr/local/bin/python3-login
COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint
ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
