# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.6.0

# required
MAINTAINER Adam Sparks adamhsparks@gmail.com

COPY --chown=rstudio . /home/rstudio/rice_awd_pests

# install system-level libs
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*
RUN sudo add-apt-repository ppa:ubuntugis/ppa
RUN apt-get update && apt-get install -y libudunits2-dev libgdal-dev && \
    rm -r /var/lib/apt/lists/*

# go into the repo directory
RUN . /etc/environment \
  \
 # build this compendium package
  && R -e "devtools::install('home/rstudio/rice_awd_pests', dep=TRUE)" \
  \
 # render the data-raw file creating data that is used in analysis from raw data
  \
  && R -e "rmarkdown::render('/home/rstudio/rice_awd_pests/data-raw/README.Rmd')" \
  \
  && R -e "rmarkdown::render('/home/rstudio/rice_awd_pests/README.Rmd')" \
 # render the manuscript into a docx, you'll need to edit this if you've
 # customised the location and name of your main Rmd file
  && R -e "rmarkdown::render('/home/rstudio/rice_awd_pests/analysis/paper/paper.Rmd')" \
  \
 # build static documentation of pkgdown site
  \
  && R -e "pkgdown::build_site('/home/rstudio/rice_awd_pests')"
