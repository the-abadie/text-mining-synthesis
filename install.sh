#!/bin/bash

read -p "Installing Python Prerequisites. Are you in a virtual environment with Python 3.9? [Y/N]" pythonVer

case $pythonVer in
	[Yy] ) echo Proceeding with pip installs; break;;
	[Nn] ) echo Please use a venv with Python 3.9, exiting...; exit 1; break;;
	*    ) echo Please use a venv with Python 3.9, exiting...; exit 1; break;;
esac

echo Proceeding with pip installs.
pip install numpy tensorflow tensorflow-addons protobuf transformers regex pubchempy sympy spacy torch chemdataextractor psutil pymongo torch tqdm scipy gensim

cd MaterialParser
echo Attemping MaterialParser Install
pip install . && echo MaterialParser Installed Successfully

cd ../MatEntityRecognition
echo Attempting MaterialRecognizer Install
pip install . && echo MaterialRecognizer Installed Successfully

cd ../ParagraphClassification
echo Attempting ParagraphClassifier Install
pip install . && python -m synthesis_classifier.model download && echo ParagraphClassifier Installed Sucessfully

cd ../OperationsExtraction
echo Attemping OperationsExtraction Install
pip install . && echo OperationsExtraction Installed Sucessfully

cd ../ReactionCompleter
echo Attemping ReactionCompleter Install
pip install . && echo ReactionCompleter Installed Sucessfully

echo Installed.
