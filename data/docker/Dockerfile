FROM jupyter/minimal-notebook:python-3.10

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

# keep in sync with requirements.txt
# allow to update the image if the source repo is updated
ADD https://api.github.com/repos/brightway-lca/brightway2/git/refs/heads/master bw2.json
ADD https://api.github.com/repos/brightway-lca/brightway2-calc/git/refs/heads/bw2legacy bw2-calc.json
ADD https://api.github.com/repos/ccomb/brightway2-data/git/refs/heads/bw2legacy bw2-data.json
ADD https://api.github.com/repos/ccomb/brightway2-io/git/refs/heads/bw2legacy bw2-io.json
ADD https://api.github.com/repos/brightway-lca/brightway2-parameters/git/refs/heads/main bw2-parameters.json

COPY requirements.txt .
USER root
RUN apt update \
    && apt install -y gosu \
    && pip install -r /home/$NB_USER/requirements.txt \
    && rm /home/$NB_USER/requirements.txt \
    && if [ "$(dpkg --print-architecture)" = "amd64" ]; then pip install  pypardiso==0.4; ldconfig; fi;

COPY entrypoint.sh /

RUN jupyter nbextension enable --py widgetsnbextension


VOLUME /home/$NB_USER
WORKDIR /home/$NB_USER/notebooks
ENTRYPOINT ["/entrypoint.sh"]
