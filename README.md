# Bachelor Thesis
## Kinetosis optimization
This project is part of my bachelor thesis in “Automotive Engineering” at the Technical University of Berlin. It is about the optimization of existing simulation models for the calculation of kintosis. For this purpose, driving profiles are read in and corresponding vertical, longitudinal and lateral accelerations are considered.

## Abstract
The purpose of this bachelor thesis is to select an already existing numerical model for the simulation of kinetosis in motor vehicles, which has a good predictive accuracy, in order to subsequently analyze and optimize this model. 
Two factors are added to the model. Firstly, the frequency of the input signals is taken into account, since people react differently to different frequencies with kinetosis symptoms. Secondly, an individual factor is introduced, which is based on the test termination time of the subjects and thus reflects the personal kinetosis sensitivity. Thus, both a trial-dependent factor and an individual-dependent factor are introduced.
Finally, the extended model is compared with the original model using test data and evaluated.

## Data sources
There were two driving maneuvers: "lane change" and "stop and go".
The recorded data was divided into a control group and a test group.
The data from the control group was used to optimize the simulation models. The data from the test group was used to validate the optimized simulation models.

For data privacy reasons, the recorded data cannot be made available.
However, the results can be viewed in the Final_Paper.

## Required MATLAB/Simulink Version 
- MATLAB 2021a and later
- Simulink 2021a and later
