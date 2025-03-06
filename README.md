# Text-mined Synthesis

This is a fork of the Ceder Group's wonderful Text-Mined Synthesis Project (https://github.com/CederGroupHub/text-mined-synthesis_public) to better suit the purposes of the Yu Group at the University of Central Florida. If you use this fork, please cite the Ceder Group's work:

Dataset:

 - Kononova, O., Huo, H., He, T., Rong Z., Botari, T., Sun, W., Tshitoyan, V. and Ceder, G., 2019. Text-mined dataset of inorganic materials synthesis recipes. Scientific Data  6: 203.

Paragraphs classification:

 - Huo, H., Rong, Z., Kononova, O., Sun, W., Botari, T., He, T., Tshitoyan, V. and Ceder, G., 2019. Semi-supervised machine-learning classification of materials synthesis procedures. npj Computational Materials, 5(1), p.62.

Materials Entity Recognition (MER):

 - He, T., Sun, W., Huo, H., Kononova, O., Rong, Z., Tshitoyan, V., Botari, T. and Ceder, G., 2020. Similarity of Precursors in Solid-State Synthesis as Text-Mined from Scientific Literature. Chemistry of Materials, 32(18), pp.7861-7873.
 
## 0. Setting Up

I highly recommend you first set up a virtual environment for this project specifically before proceeding, as we will use specific (outdated) versions of packages and Python itself. I believe this can be done with conda. Otherwise you can use `python(version) -m venv /path/to/venv/`.
<p style="text-align:center; color:red;">
<u>YOU MUST USE PYTHON 3.9</u>


Next, we will download everything we need to install the tools developed by the Ceder Group. 
1. Install Git Large File Storage (LFS). 
	- https://help.github.com/articles/installing-git-large-file-storage/
2. Download the text-mining repository from source. I have forked their original repository and modified it to be easier to install. Run the following command in the directory you want to work in for installation (you can delete everything here after completing installation):
	- `git clone --progress https://github.com/the-abadie/text-mining-synthesis`
	- Note: the step after `Resolving deltas...` is the longest and doesn't display any updates. Just be patient and it will finish. (It's about a ~1.5GB download)
3. Install the packages.
	- `cd text-mining-synthesis && sh setup.sh`

All done! This fork saves hours of effort, I promise.

## 1. Utilization
### 1. Paragraph Classifier

The paragraph classifier takes in a text input of a synthesis paragraph and returns what kind of reaction it thinks it is: `solid_state_ceramic_synthesis`, `sol_gel_ceramic_synthesis`, `hydrothermal_ceramic_synthesis`, `precipitation_ceramic_synthesis`, or `something_else`.

Here's a demo:
```python
from synthesis_classifier import get_model, get_tokenizer, run_batch

model = get_model()
tokenizer = get_tokenizer()

paragraphs = ["10.1063/1.3676216: The raw materials were BaCO3, ZnO, Nb2O5, and Ta2O5 powders with purity of more than 99.5%. Ba[Zn1/3 (Nb1−xTax)2/3]O3 (BZNT, x = 0.0, 0.2, 0.4, 0.6, 0.8, 1.0) solid solutions were synthesized by conventional solid-state sintering technique. Oxide compounds were mixed for 12 h in polyethylene jars with zirconia balls and then dried and calcined at 1100 °C for 2 h. After remilling, the powders were dried and pressed into discs of 15 mm × 1 mm and next sintered at 1500 °C for 3 h."]

result = run_batch(paragraphs, model, tokenizer)
print(result)
```
This returns a `list` of `dicts`, with each entry in the list corresponding to each text input we provided (here it was just one). We can get the scores for this example by adding:

```python
print(result[0]["scores"])
```
```python
>>> {'solid_state_ceramic_synthesis': 0.9992625117301941, 
>>> 'sol_gel_ceramic_synthesis': 0.0002470776962582022, 
>>> 'hydrothermal_ceramic_synthesis': 8.356478065252304e-05, 
>>> 'precipitation_ceramic_synthesis': 8.224115299526602e-05, 
>>> 'something_else': 0.00032462424132972956}
```
Which gives us high confidence that this reaction is a solid-state ceramic synthesis.

Side note: if you get a message similar to: 
`W tensorflow/stream_executor/platform/default/dso_loader.cc:64] Could not load dynamic library 'libcudart.so.11.0'; dlerror: libcudart.so.11.0: cannot open shared object file: No such file or directory`
`I tensorflow/stream_executor/cuda/cudart_stub.cc:29] Ignore above cudart dlerror if you do not have a GPU set up on your machine.`
This is not an issue (as far as I can tell). Whether this message appears is somehow related to the installation but I have not yet figured out what makes it show up.


### 2. Material Parser

Material Parser is required for the Synthesis Materials Recognizer. The main method is `parse_material`, which has the following internal documentation:
```
main method to parse material string into chemical structure and
convert chemical name into chemical formula
:param material_string: <str> material name/formula
:return: 
dict(material_string: <str> initial material string,
	material_name: <str> chemical name of material found in the string
	material_formula: <str> chemical formula of material
	dopants: <list> list of dopped materials/elements appeared in material string
	phase: <str> material phase appeared in material string
	hydrate: <float> if material is hydrate fraction of H2O
	is_mixture: <bool> material is mixture/composite/alloy/solid solution
	is_abbreviation: <bool> material is similar to abbreviation
	fraction_vars: <dict> elements fraction variables and their values
	elements_vars: <dict> elements variables and their values
	composition: <dict> compound constitute of the material: composition (element: fraction) and fraction of compound)
```

You can verify if it is working correctly by running the following script:

```python
import material_parser.material_parser as matpar

mp = matpar.MaterialParser(pubchem_lookup=False, verbose=False)
output = mp.parse_material("Li5+xLa3Ta2-xGexO12")

print(output)
```
You should get the following output:
```python
>>> MaterialParser version 5.6.1
>>> {'material_string': 'Li5+xLa3Ta2-xGexO12', 'material_name': 'Li5+xLa3Ta2-xGexO12', 'material_formula': 'Li5+xLa3Ta2-xGexO12', 'phase': '', 'additives': [], 'is_abbreviation_like': False, 'oxygen_deficiency': '', 'amounts_vars': {'x': {}}, 'elements_vars': {}, 'composition': [{'formula': 'Li5+xLa3Ta2-xGexO12', 'amount': '1.0', 'elements': OrderedDict([('Li', 'x+5'), ('La', '3.0'), ('Ta', '2-x'), ('Ge', 'x'), ('O', '12.0')])}]}
```
Of particular relevance is the chemical composition and stoichiometry, provided by the last element in the output in a `dict`. https://github.com/CederGroupHub/text-mined-synthesis_public/tree/master/MaterialParser is a good resource for relevant functions of this package.

### 3.  Synthesis Materials Recognizer
The synthesis materials recognizer extracts materials, precursors, targets, and other materials for each sentence in the input paragraphs.

```python
from materials_entity_recognition import MatRecognition   

model = MatRecognition()  

paragraph = ["Transparent bulk silicate undoped and (1%) Eu3+ xerogels were prepared by using the sol\u2013gel method (Aldrich reagents) according to the method described in [20]\u00a0and\u00a0[21]. In the first step tetraethoxysilane (TEOS) was hydrolyzed under constant stirring with a mixed solution of ethanol and water and using glacial acetic acid as catalyst; molar ratio was 1:4:10:0.5. Then another solution of Eu(CH3COO)3, Y(CH3COO)3, Li(CH3COO) and CF3COOH with the molar ratio for Eu:Y:Li:F of 1:5:20:255 was prepared by and added to the first solution. For other molar ratio of Y to Li (i.e. smaller than four) we have obtained glass\u2013ceramic containing only YF3 phase (i.e. for 1 to 1 molar ratio) or a mixture of YF3 and LiYF4 as was reported in Ref. [17]. After an additional vigorous stirring for 1\u00a0h at room temperature, the mixed solution was aged at room temperature for several days in a sealed container. Then the wet-gel obtained was dried up to 120\u00a0\u00b0C during 1 week to form the xerogel. Glass ceramization was obtained after subsequently thermal treatments in air at 530\u00a0\u00b0C for 30\u00a0min. in air. Using the same procedure we have prepared an Eu-doped xerogel and a silica glass."]

result = model.mat_recognize(paragraph)  
print(result)
```
The output is a very long `list`  of `dicts` which goes through each sentence in the paragraph and pulls out the precursors, targets or other materials. We can extract, for example, all of the materials in the paragraph with the following loop:

```python
for sentence in result:
    if sentence["all_materials"] != []:
        for mat in sentence["all_materials"]:
            print(mat["text"])
```
```python
>>> tetraethoxysilane
>>> TEOS
>>> ethanol
>>> water
>>> glacial acetic acid
>>> Eu(CH3COO)3
>>> Y(CH3COO)3
>>> Li(CH3COO)
>>> CF3COOH
>>> YF3
>>> YF3
>>> LiYF4
>>> air
>>> air
```

### 4. Others
Currently, Operations Extraction and Reaction Completer are unfunctional and not included in this fork. They will be added if their functionality is particularly needed.
