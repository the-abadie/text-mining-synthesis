#!/bin/bash

echo Are you in a virtual environment with Python 3.9? [Y/N]?
read pythonVer

case $pythonVer in
	[Yy] ) echo Proceeding with pip installs...;;
	[Nn] ) echo Please use a venv with Python 3.9, exiting...; exit 1;;
	*    ) echo Please use a venv with Python 3.9, exiting...; exit 1;;
esac

#pip install -v numpy "tensorflow-addons==0.17.1" tensorflow "protobuf==3.19.6" "transformers==4.11.3" regex pubchempy sympy spacy torch chemdataextractor psutil pymongo torch tqdm scipy gensim

cd MaterialParser
echo Attemping MaterialParser install
pip install -e . && echo MaterialParser Installed Successfully

cd ../MatEntityRecognition
echo Attempting MaterialRecognizer install
pip install -e . && echo MaterialRecognizer Installed Successfully

cd ../ParagraphClassification
echo Attempting ParagraphClassifier install
pip install -e .
python -m synthesis_classifier.model download 
echo ParagraphClassifier Installed Sucessfully

cde data download

