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

This technique employs a divide-and-conquer strategy by aggregating a number of binary SVM classifiers trained on selected features, which the selection process will be discussed in the next section.  Shown below is a diagram of a system for classifying cipher types:

