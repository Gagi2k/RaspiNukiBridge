FROM python:3.9-slim-bullseye

RUN apt update && apt install -y python3-dev \
                          gcc \
                          libc-dev \
                          libffi-dev \
                          make \
			  bluez \
                          sudo

# ###############################################################################
# #### ----                    Create user environemt                    --- ####
# ###############################################################################

ENV USER=${USER:-nuki}
ENV USERNAME=${USER}
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV PASS=${PASS:-false}
ENV SSH_PASSWORD_AUTH=${SSH_PASSWORD_AUTH:-false}
ENV ACTIVATE_HOST_KEY=${ACTIVATE_HOST_KEY:-false}
ENV SUDO_PASS=${SUDO_PASS:-false}

ENV HOME=/home/${USERNAME}

RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
useradd ${USERNAME} -m -d ${HOME} -s /bin/bash -g ${USERNAME} && \
usermod -aG sudo ${USERNAME}

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME

# ###############################################################################
# #### ----                    Start application                         --- ####
# ###############################################################################

COPY --chown=$USERNAME:$USERNAME requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

COPY --chown=$USERNAME:$USERNAME __main__.py nuki.py entrypoint.sh /app/

WORKDIR /app
VOLUME /app/config

ENTRYPOINT ["/app/entrypoint.sh"]
ENV NUKI_MAC=
EXPOSE 8080/tcp
