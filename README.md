# Stress from Impact of an Elastic Sphere against a Solid Rod
Deformation kinematics during the impact of a ball on a bar. This application provides a solution for Hertzian contact theory for the impact of a solid sphere against a solid bar. The solution is provided following a nonlinear differential equation governs the stress pulse created in the bar. The code is written in MATLAB. The user interface was developed using MATLAB's App Designer interface.

### Voltage to Strain for the example data
**(Vo/Vi)=(e*Gain*BF*GF)/4

Vo = Output voltages from gauge/bridge (Variable term)
Vi = Input voltage to the bridge = 5V
Gain = set in the voltage amplifier, multiplication factor to the output voltage = 100
BF = Bridge factor; Longitudinal gauge=1; Lateral gauge=Poisson's ratio=0.3;
GF= Gauge factor; based on the gauges used and given by the manufacturer = 2;
e = Output stain

**e = (Vo*4)/(Vi*Gain*GF*BF)
**e = 1.53e-3*Vo


## Version: 1.0
Last Updated: **24/7/2020**

Total Versions: **1**
