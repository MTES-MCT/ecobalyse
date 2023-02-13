FROM jupyter/minimal-notebook:python-3.9

ENV BRIGHTWAY2_DIR /home/$NB_USER/data
ENV BRIGHTWAY2_DOCKER 1
ENV BRIGHTWAY2_OUTPUT_DIR /home/$NB_USER/output
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

USER $NB_USER

RUN mkdir -p /home/$NB_USER/data \
    && mkdir -p /home/$NB_USER/notebooks \
    && mkdir -p /home/$NB_USER/output \
    && fix-permissions "/home/${NB_USER}/data" \
    && fix-permissions "/home/${NB_USER}/notebooks" \
    && fix-permissions "/home/${NB_USER}/output" 

USER root

COPY requirements.txt .

RUN pip install -r /home/$NB_USER/requirements.txt \
    && if [ "$(dpkg --print-architecture)" = "amd64" ]; then pip install  pypardiso==0.4; ldconfig; fi;

VOLUME /home/$NB_USER
USER $NB_UID
WORKDIR /home/$NB_USER/notebooks
