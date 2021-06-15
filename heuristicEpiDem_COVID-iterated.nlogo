globals [  
  infected-num          ;Number of infected individuals
  new-infected-num      ;Number of new infected individuals (per tick)
  died-num              ;Number of dead individuals
  infectiopn2recovery-period      ;Period from contagion to recovery [in ticks]
  infective-period_ini  ;Time from infection to start of infectious period [in ticks]
  incubation-period     ;Incubation period [in ticks]
  survive-probability   ;Probability of surviving the critical phase of the disease
  asymptomatic-probability ;Probability that an individual is asymptomatic
]

turtles-own [
  alive?                ;Is the individual alive?
  infected?             ;Is the individual infected? 
  asymptomatic?         ;Is the individual asymptomatic?    
  masked?               ;Is the individual wearing a face mask?
  ticks-to-recovery     ;Ticks for full recovery
  isolated?             ;Is the individual isolated?
  immune?               ;Is the individual immunized?      
  partnered?            ;Does the individual have an interview?
  partner               ;WHO partner's identifier (nobody if there is no interlocutor)
]

to SetUp
  clear-all
  set infected-num initial-positive-num
  set asymptomatic-probability 0.04 ;4% probability that an individual is asymptomatic.
  set died-num 0
  set infectiopn2recovery-period 15      ;15 ticks (equals 15 days)
  set infective-period_ini 2             ;2 ticks (equals 2 days)
  set incubation-period 5      ;5 tiks (equals 5 days)
  set survive-probability 0.9075 ;90.75% chance of surviving the infection crisis (for Mexico)  

  setup-turtles
  
  file-open "myNetLogo_num_infected.txt"
  file-print 0
  file-open "myNetLogo_num_new_infected.txt"
  file-print 0
  file-close-all
  file-delete "myNetLogo_num_infected.txt"
  file-delete "myNetLogo_num_new_infected.txt"
 
  reset-ticks
end

to setup-turtles
  make-turtles
  setup-common-variables
end

to make-turtles
  crt initial-negative-num [ set infected? false set color lime ]
  crt initial-positive-num [ set infected? true set color red ]

end

to setup-common-variables
  ask turtles [
    set alive? true
    set partnered? false
    set partner nobody
    set immune? false
    set isolated? false
    set ticks-to-recovery infectiopn2recovery-period
    setxy random-xcor random-ycor
    ifelse ((random-float 1.0) > asymptomatic-probability ) [
     set asymptomatic? false
    ]  
    ;else:
    [   
     set asymptomatic? true
     if infected?
     [
       set color white 
     ]          
    ]
    
    ifelse (to-wear-facemask)[
      ifelse ((random-float 1.0) > disobedience-probability) [ ;Recommendation to use face masks with a certain probability of disobedience.
        set masked? true;
      ]
      ; else
      [
        set masked? false;
      ]
    ]
    ;else (No to-wear-facemask):
    [
      set masked? false;
    ]
  ]
end

to Go
  let infected-turtles turtles with [infected?]
  ask infected-turtles [pass-sanitary-filter]
  ask infected-turtles [try-recovery]

  let alive-turtles turtles with [alive?]
  let free-turtles alive-turtles with [not isolated?]
  ask free-turtles [partner-up]
  
  let partnered-turtles turtles with [partnered?]
  
  let last-infected  infected-num
  ask partnered-turtles [infect-randomly]
  set new-infected-num (infected-num - last-infected) 
  
  finish-meetings

  file-open "myNetLogo_num_infected.txt"
  file-print infected-num
  file-open "myNetLogo_num_new_infected.txt"
  file-print new-infected-num
  file-close-all
  
  tick
  
  if ticks = total-iterations-num [
    stop
  ]
end

to try-recovery
   ifelse (not asymptomatic?)
   [
    ifelse ((random-float 1.0) > tick-alive-probability (infectiopn2recovery-period - ticks-to-recovery) ) [
     set alive? false
     set infected? false
     set color brown
     set died-num died-num + 1
    ]
    ;else:
    [
     if (ticks-to-recovery > 0)[
      set ticks-to-recovery ticks-to-recovery - 1
      if (ticks-to-recovery = 0)[
        set infected? false
        set isolated? false
        set immune? true
        set color yellow
      ]
     ]
    ]
   ]
   ;else (asymptomatic individual)
   [
     if (ticks-to-recovery > 0)[
      set ticks-to-recovery ticks-to-recovery - 1
      if (ticks-to-recovery = 0)[
        set infected? false
        set isolated? false
        set immune? true
        set color yellow
      ]
     ]
   ]

end

to pass-sanitary-filter
 if (detection-and-isolation)[ 
   if (not asymptomatic?)
   [
    if ((random-float 1.0) > tick-escape-probability (infectiopn2recovery-period - ticks-to-recovery) ) [
     set isolated? true
     set color cyan
    ] 
   ] 
 ]
end

to partner-up 
  if (not partnered?) [                                          ;If the individual does not have an interview
    rt (random-float 90 - random-float 90) fd 1                  ;The individual moves randomly
    set partner one-of (turtles-at -1 0) with [ not partnered? ] ;The individual seeks a nearby interlocutor
    if (partner != nobody) [              ;Si hay alguien cerca:
      let partner-alive? [alive?] of partner 
      let partner-isolated? [isolated?] of partner
      if (partner-alive? and not partner-isolated?) [
        set partnered? true                                      ;The individual initiates contact
        set heading 270                                          ;The individual faces the interlocutor
        ask partner [                                            
          set partnered? true                                    ;The interlocutor accepts the interview
          set partner myself                                     ;The individual is also an interlocutor
          set heading 90                                         ;The interlocutor faces the individual 
        ]
      ]
      if ((random-float 1.0) > disobedience-probability) [       ;Recommendation for distancing with a probability of disobedience
        separate
      ]
    ]
  ]
end


to infect-randomly
  let partner-infected? [infected?] of partner 
  let partner-ticks-to-recovery [ticks-to-recovery] of partner 
  let partner-masked? [masked?] of partner 
  if (partner-infected? and not infected? and not immune? and ((partner-ticks-to-recovery)<(infectiopn2recovery-period - infective-period_ini))) [ 
  ;If the partner is infected and the individual is not infected and is not immune,
    ;then a possible contagion:
    if ((random-float 1.0) < ((mask-efect-weight (partner-masked?) (masked?))*(infection-probability (distance partner)))) [  
     set infected? true
     ifelse asymptomatic?
     [
       set color white 
     ]     
     ;else:     
     [
       set color red
     ]
     set infected-num infected-num + 1
   ]
  ] 
end

to-report infection-probability [dist]
  report(1 / (2 ^ dist)) 
end

to-report tick-alive-probability [infection-ticks]
  let crisis-tick round(infectiopn2recovery-period / 2)
  ;If it is the day of the crisis, the infected individual survives with some probability:
  ifelse (infection-ticks = crisis-tick)[
    report(survive-probability)
  ]
  ;else: (does survive)
  [   
    report 1.0
  ]    
end

to-report tick-escape-probability [infection-ticks]
  ;If it is the first day with symptoms, the infected individual can be detected with some probability for isolation:
  ifelse (infection-ticks = incubation-period)[
    report(detection-fault-probability)
  ]
  ;else (escapes from being isolated):
  [   
    report 1.0
  ]    
end

to separate 
  if (avoid-close-contact)[
      if (distance partner < minimum-separation) [
        ifelse ( heading = 270) [
           setxy (xcor + (minimum-separation / 2)) ycor 
        ]
        ;else:
        [
           setxy (xcor - (minimum-separation / 2)) ycor           
        ]
      ]      
  ]
end


to finish-meetings
  let partnered-turtles turtles with [ partnered? ]
  ask partnered-turtles [ release-partners ]
end

to release-partners
  set partnered? false
  set partner nobody
  rt 180
end

to-report mask-efect-weight [infected-masked? healthy-masked?]
  ifelse (not infected-masked?  and not healthy-masked?)[
     report(0.9) ;90% weighting
  ]
  ;else:
  [   
   ifelse (not infected-masked?  and healthy-masked?)[
     report(0.7) ;70% weighting
   ]
   ;else:
   [
    ifelse (infected-masked?  and not healthy-masked?)[
     report(0.05) ;5% weighting
    ]
    ;else (both individuals masked):
    [
     report(0.015) ;1.5% weighting      
    ]
   ]
  ]    
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
685
506
15
15
15.0
1
10
1
1
1
0
1
1
1
-15
15
-15
15
0
0
1
ticks
30.0

BUTTON
29
55
94
88
SetUP
SetUp
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
110
55
173
88
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
16
98
188
131
initial-positive-num
initial-positive-num
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
16
138
188
171
initial-negative-num
initial-negative-num
1
100
100
1
1
NIL
HORIZONTAL

MONITOR
18
466
89
511
NIL
infected-num
17
1
11

SLIDER
16
178
188
211
minimum-separation
minimum-separation
0
10
1.5
0.5
1
NIL
HORIZONTAL

SLIDER
15
219
189
252
disobedience-probability
disobedience-probability
0
1
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
110
466
182
511
died-num
died-num
17
1
11

PLOT
704
16
1284
497
Epidemy evolution
Time [ticks]
Total positive cases
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"new-infected-num" 1.0 0 -2674135 true "" "plot new-infected-num"
"infected-num" 1.0 0 -13791810 true "" "plot infected-num"

SLIDER
14
259
190
292
detection-fault-probability
detection-fault-probability
0
1
0.5
0.1
1
NIL
HORIZONTAL

SWITCH
20
408
181
441
avoid-close-contact
avoid-close-contact
1
1
-1000

SWITCH
20
367
182
400
detection-and-isolation
detection-and-isolation
1
1
-1000

TEXTBOX
15
302
165
330
Strategies:
16
0.0
1

TEXTBOX
18
445
168
463
Accumulated totals:
14
0.0
1

SLIDER
19
11
188
44
total-iterations-num
total-iterations-num
1
1000
250
1
1
NIL
HORIZONTAL

SWITCH
20
327
178
360
to-wear-facemask
to-wear-facemask
1
1
-1000

@#$#@#$#@
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
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
