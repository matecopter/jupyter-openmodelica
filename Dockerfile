FROM ubuntu:latest
RUN apt-get update

RUN apt-get install -y --no-install-recommends ca-certificates gnupg build-essential git
RUN echo "deb http://build.openmodelica.org/apt/ bionic stable" > /etc/apt/sources.list.d/openmodelica.list && echo "deb-src http://build.openmodelica.org/apt/ bionic stable" >> /etc/apt/sources.list.d/openmodelica.list
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
#RUN wget -q http://build.openmodelica.org/apt/openmodelica.asc -O- | apt-key add
RUN apt-key adv --fetch-keys http://build.openmodelica.org/apt/openmodelica.asc

# Update index (again)
RUN apt-get update

# Install minimal OpenModelica Components
RUN apt-get install -y omc omlib-modelica-3.2.3 python3-pip python3-dev

# Install Python components
#RUN apt-get install -y python3-pip python3-dev

# Install Jupyter notebook, always upgrade pip
RUN pip3 install --upgrade pip
RUN pip3 install jupyter

# Install OMPython and jupyter-openmodelica kernel
RUN pip3 install -U git+git://github.com/OpenModelica/OMPython.git
RUN pip3 install -U git+git://github.com/OpenModelica/jupyter-openmodelica.git

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

#EXPOSE 8888

CMD ["jupyter", "notebook"]




