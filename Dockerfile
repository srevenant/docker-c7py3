FROM centos:7

RUN yum -y install gpg
RUN yum -y install gcc gcc-c++ make
RUN yum -y install openssl-static

ENV PYTHON_VERSION="3.5.2"

WORKDIR /app/src

RUN curl -s --connect-timeout 5 -m 30 \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    -o python.tgz
RUN curl -s --connect-timeout 5 -m 30 \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz.asc \
	-o python.tgz.asc
RUN curl -s --connect-timeout 5 -m 30 -O \
	https://www.python.org/static/files/pubkeys.txt

RUN gpg --import pubkeys.txt
RUN gpg --verify python.tgz.asc python.tgz
RUN tar --owner=0 --strip-components=1 -xzf python.tgz
RUN ./configure --prefix=/app/python-${PYTHON_VERSION}-linux-x64
RUN make install
RUN rm -rf /app/src
RUN cd /app; ln -s python-${PYTHON_VERSION}-linux-x64 python-3
RUN cd /app/python-${PYTHON_VERSION}-linux-x64/bin; \
	 if [ ! -f pip ]; then ln -s pip3 pip; fi; \
     if [ ! -f virtualenv ]; then ln -s virtualenv3 virtualenv; fi

ENV PATH=$PATH:/app/python-${PYTHON_VERSION}-linux-x64/bin

RUN pip3 install --upgrade pip virtualenv

RUN rm -rf /app/src

RUN yum -y erase gcc gcc-c++ make
RUN yum clean all

WORKDIR /app
