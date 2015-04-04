# Image that represents developer machine
# We will have all nessesary packages installed here
# Compute nodes won't have such reach set o packages

FROM debian
MAINTAINER Artem Polyakov <artemp@mellanox.com>

# Install some ps and Midnight Commander
RUN apt-get update && \
    apt-get install -y procps mc && \
    apt-get install -y gcc make && \
    apt-get install -y wget bzip2 && \
    apt-get install -y git && \
    apt-get install -y python && \
    apt-get install -y libssl-dev && \
    apt-get install -y libglib2.0-dev libgtk2.0-dev

# Prepare tools for compilation
COPY ./compilation /root/
RUN cd /root/compile/scripts/ && ./download_tools.sh
RUN cd /root/compile/scripts/ && ./prepare.sh
RUN echo "BASE=/opt/compile_tools/" >> /root/.bashrc
RUN echo "PATH=\$BASE/bin:\$PATH" >> /root/.bashrc
RUN echo "LD_LIBRARY_PATH=\$BASE/lib:\$LD_LIBRARY_PATH" >> /root/.bashrc
RUN rm -Rf /root/compile

