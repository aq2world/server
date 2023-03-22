FROM ubuntu:22.04 AS buildstage

# Cache hax, so we get a fresh build every time
##ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano unzip

# Copy stuff
RUN mkdir /aq2server
COPY aq2-tng /aq2-tng
COPY q2admin.lua q2a_cw.lua q2a_cw_docker.lua /aq2server/

# Copy configs to aq2server
RUN cp -r /aq2-tng/action /aq2server/
COPY config/* /aq2server/action/
COPY tng /aq2server/action/tng

# Download and extract latest Q2Pro build
RUN wget -qnv https://github.com/actionquake/q2pro/releases/latest/download/q2pro-lin-gcc.zip
RUN unzip q2pro-lin-gcc.zip
RUN mv q2proded /aq2server/q2proded
RUN chmod +x /aq2server/q2proded

# Download and extract latest TNG build
RUN wget -qnv https://github.com/actionquake/aq2-tng/releases/latest/download/tng-lin-x86_64.zip
RUN unzip -o tng-lin-x86_64.zip
RUN mv gamex86_64.so /aq2server/action/gamex86_64.real.so

# Download and extract latest Q2Admin build
RUN wget -qnv https://github.com/actionquake/q2admin/releases/latest/download/q2admin-lin-x86_64.zip
RUN unzip q2admin-lin-x86_64.zip
RUN mv plugins /aq2server
RUN mv gamex86_64.so /aq2server/action/gamex86_64.so

# Make libraries and scripts executable
RUN chmod +x /aq2server/action/gamex* /aq2server/plugins/mvd_transfer.sh

# Cache hax
##ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends nano wget curl lua5.1 liblua5.1-0-dev libcurl3-gnutls s3cmd ca-certificates -y && update-ca-certificates

COPY --from=buildstage /aq2server /aq2server
# Copy and set entrypoint
COPY entrypoint.sh /aq2server
ENTRYPOINT /aq2server/entrypoint.sh

# Maps and skins
COPY fullmaplist.ini /aq2server/action/
COPY skinlist.ini /aq2server/action/
RUN mkdir /aq2server/action/maps

# Logs and Demos
RUN mkdir /aq2server/action/logs
RUN mkdir /aq2server/action/demos

# Sounds
COPY sndlist.ini tourney.ini /aq2server/action/

# Create user and add rights to aq2server
RUN useradd -rm -d /home/admin -s /bin/bash -g root -G sudo -u 1001 admin
RUN chown -R admin /aq2server
USER admin
WORKDIR /aq2server

# S3CFG for S3 demo uploads
COPY s3cfg /home/admin/.s3cfg

COPY all_env_vars.env /aq2server/