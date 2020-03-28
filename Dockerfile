ARG UBUNTU_VER=bionic
FROM ubuntu:$UBUNTU_VER
ARG UBUNTU_VER=bionic
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates gnupg build-essential git
RUN echo "deb http://build.openmodelica.org/apt/ ${UBUNTU_VER} stable" > /etc/apt/sources.list.d/openmodelica.list && echo "deb-src http://build.openmodelica.org/apt/ ${UBUNTU_VER} stable" >> /etc/apt/sources.list.d/openmodelica.list
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
RUN apt-key adv --fetch-keys http://build.openmodelica.org/apt/openmodelica.asc

# Update index (again)
RUN apt-get update

ARG OMLIB_MODELICA_VER=3.2.3
ARG PYTHON_VER=""
# Install minimal OpenModelica and  Python3 Components
RUN apt-get install -y omc omlib-modelica-$OMLIB_MODELICA_VER python${PYTHON_VER}-pip python${PYTHON_VER}-dev

# Install Jupyter notebook, always upgrade pip
RUN pip${PYTHON_VER} install --upgrade pip
RUN pip${PYTHON_VER} install jupyter

# Install OMPython and jupyter-openmodelica kernel
RUN pip${PYTHON_VER} install -U git+git://github.com/OpenModelica/OMPython.git
RUN pip${PYTHON_VER} install -U git+git://github.com/OpenModelica/jupyter-openmodelica.git

# Create a user profile "openmodelicausers" inside the docker container as we should run the docker container as non-root users
RUN useradd -m -s /bin/bash openmodelicausers

# Copy the kernel from root location to non root location so that jupyter notebook when started as non-root can find openmodelica kernel
RUN cp -R /root/.local/share/jupyter/kernels/OpenModelica /usr/local/share/jupyter/kernels/

# Change the container to non-root "openmodelicauser" and set the env 
USER openmodelicausers
ENV HOME /home/openmodelicausers
ENV USER openmodelicausers
WORKDIR $HOME

RUN mkdir $HOME/.jupyter

CMD ["jupyter", "notebook"]




