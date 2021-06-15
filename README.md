## WHAT IS IT?
It is the application of a model for the dynamics of the COVID epidemic propagation, supported by agents and intuitive and simple heuristic rules.

## HOW IT WORKS

The basis of the proposed model is the possibility of representing a population of agents with the ability to move freely and interact, in a random way, resulting in the spread of an infectious disease.

During the execution of the model, healthy individuals are displayed in green, infected individuals in red, infected asymptomatic individuals in white, isolated individuals in cyan, immunized individuals in yellow and, finally, dead individuals in brown.

Individuals may be alive or die from the disease if they do not get through the critical phase of the disease. If an individual is alive, whether it is healthy or sick, and it does not have an encounter with someone else, it has the possibility of moving freely to seek personal encounters, as long as the individual is not isolated. When an individual moves freely, the following rules are followed:
I. The Individual moves randomly to find a partner to meet. As long as no partner is associated, the individual is free to meet. 
II. Once the Individual is near a potential partner, it checks that the potential partner is not isolated or dead. If the possible interlocutor is available, then contact is established with it and becomes the interlocutor in turn. 
III. Once a meeting has been established, in order to minimize the likelihood of infection, partners may or may not consider following the recommendation to maintain a minimum distance or to use face mask.
IV. Once a couple of individuals have made contact and interacted, they proceed to end the encounter and continue to seek new encounters by moving randomly.

Meanwhile, sick individuals can infect healthy ones according to the probability function that is found in terms of the inverse of 2 elevated to the distance between the partners.

The infected individuals have to submit to the various challenges involved in the evolution of the disease and its effects.  To begin with, once the incubation period is over, if the detection and isolation strategy is enabled, they are subjected to passing through a sanitary filter in which the symptoms of a sick individual can be detected and referred to isolation or confinement to prevent it from becoming a carrier of the infection. At this point, there is a possibility that a sick individual may evade the sanitary filter, either because detection fails, with a certain probability, or because the individual is asymptomatic.

Aditionally, on the most critical day of the disease, exactly at halfway through the infectious period, the infected individual is subjected to an endurance test where it can survive with a certain probability. 

Finally, if a sick individual manages to complete the infectious period, it is considered recovered and, for practical purposes, acquires the status of immunity to the disease.

## HOW TO USE IT

### Buttons

SETUP: Setup the world to initialice the multi-agent heuristic epidemic model. The number of individuals and other parameters are determined by the slider values.

GO: Start the individuals walk around the world and interact.

### Sliders

total-iterations-num: Maximum number of iterations (in ticks) for the simulation.
initial-positive-num: Number of infected individuals.
initial-negative-num: Number of healthy individuals.
minimum-separation: Minimum distance recommendation for avoid close contacts.
disobedience-probability: Probability of not complying with the minimum distance recommendation.
detection-fault-probability: Probability of failure in detection and timely isolation of infected and symptomatic individuals.

### Switches

to-wear-facemask: Enable/disable this strategie
detection-and-isolation: Enable/disable this strategie.
avoid-close-contact: Enable/disable this strategie.

### Strategies

Regarding the measures to contain the spread of the epidemic, this model allow us to evaluates the performance of three strategies:

A) Proper use of face masks. Individuals should wear face masks when wandering in the agent's world.

B) Timely identification of newly infected and immediate isolation. A sanitary filter is implemented to detect the first symptoms of the disease and refer the infected person to a containment or isolation area in a timely manner. In order to introduce voluntary avoidance or error into these diagnoses, the detection-fault-probability parameter is introduced.

C) Avoid close contacts. The minimum separation is recommended to be maintained in encounters between individuals in order to minimize the risk of possible contagion. In order to introduce the factor of free will in the adoption of this measure, the disobedience-probability parameter incorporated.


## THINGS TO NOTICE

Sick individuals can infect healthy ones according to the probability function that is found in terms of the inverse of 2 elevated to the distance between the partners. This heuristic rule has been adopted since it ensures that the probability of contagion is 1.0, when the distance between the partners is zero and decreases, in terms of the curve with a profile corresponding to the inverse of an exponential function, when the distance increases. Of course, this function for the probability of contagion in an encounter is completely subjective but a specialist epidemiologist could propose a more precise function of probability of contagion in terms of the distance between the partners and for each specific disease.

On the other hand, on the most critical day of the disease, the sick individual is subjected to a resistance test in which it can survive with a certain probability, which depends on the specific mortality rate of the disease in each country. This value can also be modified within the code without major problems.


## EXTENDING THE MODEL

Fork the code to make the model more complicated, detailed, or accurate.


## RELATED MODELS

- NetLogo PD N-Person Iterated model
- NetLogo heuristicEpiDem Iterated model

Specifically, to write this code, I took, as a starting point, my heuristicEpiDem Iterated model code, which was developed on the basis of the PD N-Person Iterated model code by U. Wilensky:

* Wilensky, U. (2002). NetLogo PD N-Person Iterated model. http://ccl.northwestern.edu/netlogo/models/PDN-PersonIterated. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## HOW TO CITE

If you mention this model in a publication, I ask that you include these citations for the model:

* Laguna-Sanchez, G.A. (2021).  NetLogo heuristicEpiDem COVID Iterated model.  https://github.com/galaguna/heuristicEpiDem-Iterated. 

## COPYRIGHT AND LICENSE

Copyright 2021 Gerardo Abel Laguna-Sanchez.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
