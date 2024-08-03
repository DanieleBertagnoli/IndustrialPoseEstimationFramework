#!/bin/bash

sudo echo

# Installing blenderproc using a venv
cd CustomBlenderproc
python3 -m venv venv
source venv/bin/activate
pip install -e .

# Downloading background textures for dataset generation
wget https://bertagnoli.ddns.net/static/PublicDrive/BackgroundTextures.zip
unzip BackgroundTextures.zip
rm BackgroundTextures.zip

# Downloading original BOP datasets for dataset generation
wget https://bertagnoli.ddns.net/static/PublicDrive/datasets.zip
unzip datasets.zip
rm datasets.zip
deactivate
cd ..

# Pull docker image
docker pull aaucns/poet:latest

sudo chmod -R +x Scripts