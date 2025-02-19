# Bachelor Thesis
## Kinetosis optimization
This project is part of my bachelor thesis in “Automotive Engineering” at the Technical University of Berlin. It is about the optimization of existing simulation models for the calculation of kintosis. For this purpose, driving profiles are read in and corresponding vertical, longitudinal and lateral accelerations are considered.

## Abstract
The purpose of this bachelor thesis is to select an already existing numerical model for the simulation of kinetosis in motor vehicles, which has a good predictive accuracy, in order to subsequently analyze and optimize this model. 
Two factors are added to the model. Firstly, the frequency of the input signals is taken into account, since people react differently to different frequencies with kinetosis symptoms. Secondly, an individual factor is introduced, which is based on the test termination time of the subjects and thus reflects the personal kinetosis sensitivity. Thus, both a trial-dependent factor and an individual-dependent factor are introduced.
Finally, the extended model is compared with the original model using test data and evaluated.

## Step by Step
At the beginning I compared two models with each other to check which model is best suited for my task. I transferred the numerical model from Kamiji and Braccesi to Simulink.
Unfortunately, I had no data with which I could validate the model. Accordingly, I validated the model indirectly with the test data. I divided the test data into two groups. An experimental group and a control group.

<img src="https://github.com/user-attachments/assets/fb809db5-9d5b-48f0-aad0-9a94ee9d1f55" alt="kamiji_vs_braccesi" width="600" height="500"><br>

Here you can see that Kamiji's model has a smaller deviation from the value of the test subjects. The flow diagram of Kamiji's model is shown in the next graphic.

<img src="https://github.com/user-attachments/assets/1c9b08a3-ee34-4dc7-bc76-c60d2f21bac7" alt="Modell_kamiji" width="600" height="500"><br>

Since in all situations in which kinetosis can occur, it involves a state that is in contradiction to the subjective vertical (Kamiji). With this assumption, I introduced a frequency factor (k_Freq). This frequency factor is based on the rate of change of the subjective vertical. The subjects experienced a constant change in the subjective vertical of 0.2Hz. Therefore, I could only implement the k_Freq statically.

<img src="https://github.com/user-attachments/assets/cac4e73d-6862-42c0-9ac3-bc8bbc817dd3" alt="SVC_Modell_kamiji_erweitert_v2" width="800" height="500"><br>

With this optimization, an increase in accuracy of 70% was achieved.

<img src="https://github.com/user-attachments/assets/e2c379d0-65d1-41b4-a845-0778fd928dcd" alt="increase in accuracy of 70%" width="600" height="500"><br>



## Data sources
There were two driving maneuvers: "lane change" and "stop and go".
The recorded data was divided into a control group and a test group.
The data from the control group was used to optimize the simulation models. The data from the test group was used to validate the optimized simulation models.

For data privacy reasons, the recorded data cannot be made available.
However, the results can be viewed in the Final_Paper.

## Required MATLAB/Simulink Version 
- MATLAB 2021a and later
- Simulink 2021a and later
