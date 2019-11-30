# Ciphertext-Classification-Ensemble-SVM
This is a demonstration of performing ensemble learning with support vector machine (SVM) to classify type of cipher used to encrypt texts.

## Summary
My goal was to develop a machine learning based technique that enables to classify as accurately as possible the type of cipher that was used to generate ciphertext messages.  Accuracy is used as the measure of success—which is simply adding up the number of cases that were classified correctly and dividing by the total number of cases tested.  The accuracy results are given in terms of the amount of ciphertext used. 5-fold cross validation was used for all experiments, and a line graph showing accuracy as a function of the amount of ciphertext used in my experiments is shown below.

So, for this project I choose ensembling learning with SVM to solve the challenge—and this approach won as the best method across all Machine Learning courses in Spring 2019 semester, in term of getting best accuracy at lowest amount of ciphertext used.

## Data
1000 ciphertest messages, each of length 1000, were generated for each of the following classic ciphers:

* Simple substitution
* Vigenère
* Column transposition
* Playfair
* Hill cipher

Note that in each case, the plaintext consists only of alphabetic characters A through Z, and the same is true of the ciphertext.  For each ciphertext message which is generated, a plaintext is selected at some random initial point in the Brown Corupus and a random key is generated.  Those keys are saved so that the decryption are verified as needed.

## Technique: Ensemble learning with SVM

This technique employs a divide-and-conquer strategy by aggregating a number of binary SVM classifiers trained on selected features.  Shown below is a diagram of a system for classifying the ciphertexts:

![Ensemble SVM System Diagram](/images/ensembleSVM_system.png)

Here are the steps to employ the technique:
1. Extract features from the ciphertext, which are different types of characteristic values that describe each ciphertext.
2. For each cipher type, visually select a pair of feature variables to separate the cipher type from all other types as much as possible.
3. Train and test each of the binary SVM classifiers using 5-fold cross-validation. Each classifier model calculates a probability for the ciphertext to belong to that cipher type.  
4. Select the cipher type with the maximum probability to be the choosen cipher type for the ciphertext.

## Feature Extraction

There are different ways which a ciphertext can be measured.  For this project, eleven characteristic features were extracted from each ciphertext:

Feature | Abbreviation | Description
------- | ------------ | -----------
Number of unique characters | NUC | number of unique characters
Chi-squared statistic of English distribution | CSS | measure of how similar the frequency distrution of the characters in a ciphertext is to the frequency distribution of English
Index of coincidence | IC | measure of how similar a frequency distribution is to uniform distribution
Max IC for periods 1-15 | MIC | divide cipher by period P then average the IC values of divided ciphers
Max kappa for periods 1-15 | MKA | shift cipher P places to right then find percentage of characters that coincide with unshifted cipher
Digraphic index of coincidence | DIC | same formula as IC but add frequency of adjacent pairs of characters from ciphertext instead of single character
DIC for even-numbered pairs | EDI | calculate IC for pairs that start at even-numbered positions 0,2,4,etc
Long repeat | LR | square root of percentage of 3 character repeats
Percentage of odd-spaced repeats | ROD | percentage of odd-spaced repeats to all repeats
Log digraph score | LDI | for each character, get scores from pre-generated table of English log diagraph scores and average them
Single letter-digraph discrepancy score | SDD | for each character, get scores from pre-generated table of Single letter-Digraph Discrepancy scores and average them

Next thing was to create a special kind of plot called generalized pairs plot, as seen below, which allows us to see all possible combinations of 2 features in one place.

![Generalized Pairs Plot](/images/generalized_pairs_plot_1000.png)

With this plot five pairs of features were visually selected in which each pair isolates a cipher type from all other types.  It is ensured that a cluster of one cipher type is farthest from all other clusters without any overlaps if possible.  More importantly, the width of all hyperplanes must be maximized.
