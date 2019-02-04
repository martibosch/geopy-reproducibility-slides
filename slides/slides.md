---
author: Martí Bosch
title: Reproducibility in Geospatial Data Science
date: February 4, 2019
---

# Reproducibility

## Idea

:man: publishes a paper with the results _**Y**_ of a applying the model _**f**_ to the datasets _**X**_

## What will be in the paper?

* *Most likely*: results _**Y**_ (tables, figures)
* *Maybe*: model _**f**_ (code)
* *Unlikely*: access to the datasets _**X**_

## Reproducibility quest

Imagine a paper with results _**Y**_ and sharing the model's code _**f**_

. . .

:raising_hand: has access to the dataset _**X**_. Will :raising_hand: be able to reproduce the results _**Y**_?

# Two main reproducibility issues

## Computational environments

* :man: has a :computer: with e.g. Ubuntu 18.04, GDAL 2.2.2, Python 2.7 and NumPy 1.15.1
* :raising_hand: has a :computer: with e.g. Windows 10, GDAL 2.2.4, Python 3.6 and NumPy 1.13.0

## Computational environments

The results _**Y**_ of running code _**f**_ on dataset _**X**_ might depend on the OS, system libraries, Python version and libraries...

. . .

These change really fast, so chances that :man: and :raising_hand: obtain the same results _**Y**_ can be quite low

## Yet there is a trickier issue

## Mutated data

Say :raising_hand: has access to the same *environment* as :man:

. . .

Furthermore, say :raising_hand: has access to the dataset _**X**_, that is a file named `g100_clc12_V18_5.tif`

. . .

Yet the code shared by :man: might look like

```python
with rasterio.open(
    "~/my-data/clc_2012_cropped_reclassified.tif") as src:
    clc_arr = src.read(1)
```

## 

Then :raising_hand: contacts :man: by email:

. . .

* :raising_hand: How did you obtain `clc_2012_cropped_reclassified.tif`?

. . .

* :man: Oh, I manually cropped and reclassified the `tif` with QGIS some months ago, I don't remember exactly how

## And so on

. . .

## Reality

Chances that :man: and :raising_hand: obtain the same results _**Y**_ are very low


# Reproducibility within the PyData stack

## Two kinds of code repositories

## Libraries

* **For**: general purpose tasks
* **Consist of**: Python modules 
* Packaged (instable by pip, conda...)
* Examples: NumPy, pandas, matplotlib...

## Analysis cases

* **For**: specific case studies
* **Consist of**: scripts and notebooks to preprocess and explore the data
* Make extensive use of libraries
* Example: rainfall-runoff simulation of the Broye watershed

## 

The focus of this workshop is on creating reproducible **analysis case repositories**


# Reproducibility of analysis case repositories

## 

Say that :man: includes a git repository for his analysis case, with all the scripts needed to preprocess the raw data 

. . .

How do we ensure that :raising_hand: can reproduce the results in her :computer: ?

## Virtual environments in Python

Consist of:

* Python interpreter, e.g., Python 2.7 or Python 3.6 ...
* Set of Python packages with *pinned* versions e.g.

```
numpy==1.13.3
pandas==0.23.4
matplotlib==3.0.2
...
```

. . . 

They are *virtual* because they are isolated from the OS libraries$\dagger$


## Managing Python virtual environments

Two main approaches

## pip + virtualenv

* virtualenv allows creating virtual Python environments that work with pip
* pip is the package manager supported by the Python foundation
* Environments can be shared with a `requirements.txt` file

## However

* pip only supports managing Python packages

$\dagger$ Python packages can often depend on non-Python libraries

. . .

:raising_hand: might still not be able to reproduce the results since she has GDAL 2.2.4 and :man: has GDAL 2.2.2

## Enter the second approach

## conda

* Packaged with the Anaconda Python distribution
* Compatible with pip and virtualenv[$\ddagger$](http://jakevdp.github.io/blog/2016/08/25/conda-myths-and-misconceptions/#Myth-#5:-conda-doesn't-work-with-virtualenv,-so-it's-useless-for-my-workflow)
* Handles library dependencies even outside Python, e.g., GDAL
* Environments can be shared with an `environment.yml` file

. . .

If :man: shares his `environment.yml`, :raising_hand: should be able to fully reproduce the results

## Yet, we still have the trickier issue of mutated data

There is no magic solution for it... Just organization

## Example repository structure {.large-code-block}

[Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/#cookiecutter-data-science)

    ├── notebooks          <- Jupyter notebooks
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── data
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   ├── models         <- Scripts to train models and then use them to make predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment
    ├── setup.py           <- makes project pip installable (pip install -e .) so src can be imported
    └── tox.ini            <- tox file with settings for running tox; see tox.testrun.org

(I have ommited some details so the tree can fit)

## Key principles

Although most templates are designed for Machine Learning analysis cases, the key principles are also relevant for Geospatial data science

## Provide a reproducible computational environment

* Many geo-Python packages depend on GDAL, so it is strongly recommended to use conda

* Tools like [Binder](https://mybinder.org/) can automatically build an executable environments (Docker images) for a repository with an `environment.yml`, so anybody can execute the repository's notebooks

## Raw data is immutable

* Do not overwrite raw data - especially not manually

* Any processed data should be stored in separate files (preferably separate folders too)

## Analysis as a DAG

An analysis case can be modeled as a directed-acyclic graph (DAG), with two kinds of nodes:

* Dataset states

* Data processing steps 

and edges link dataset states as inputs/outputs of data processing steps

## Example for Machine Learning

![Machine Learning DAG](images/machine-learning-dag.png)


## Automate your computational workflow

In order to avoid the `clc_2012_cropped_reclassified.tif` issue above, you might use make (or more advanced tools like snakemake, airflow...)

## Example for Machine Learning {.large-code-block}

```
RAW_DATASET_FP = data/raw/immutable_dataset.csv
FEATURE_DATASET_FP = data/processed/feature_dataset.csv
TRAIN_DATASET_FP = data/processed/train_dataset.csv
TEST_DATASET_FP = data/processed/test_dataset.csv
TRAINED_MODEL_FP = models/trained_model.csv

extract_features:
    python src/features/extract_features.py -i $(RAW_DATASET_FP) -o $(FEATURE_DATASET_FP)
    
split_dataset: extract_features
    python src/data/split_dataset.py -input $(FEATURE_DATASET_FP) -o $(TRAIN_DATASET_FP) \
        -o $(TEST_DATASET_FP)

train_model: split_dataset
    python src/models/train_model.py -i $(TRAIN_DATASET_FP) -o $(TRAINED_MODEL_FP)

validate_model: train_model
    python src/models/validate_model.py -i $(TEST_DATASET_FP) -o $(VALIDATED_MODEL_FP)

```

## Now let's apply this to Geospatial Data Science

# Example for Geospatial Data Science: Rainfall-runoff simulation

## Analysis DAG

![Rainfall-runoff DAG](images/rainfall-runoff-dag.png)

## Let's get to it!
