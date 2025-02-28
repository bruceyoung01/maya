PRO Chapter4_10Hw

x = FindGen(280)-30

avg = 80.0
stdev = 45.0
gamma = 0.57721

;Equation 4.60a
beta = (stdev*(6^(0.5)))/!pi
;Equation 4.60b
zeta = avg - gamma*beta

print, "Beta = ", beta
print, "Zeta = ", zeta

;Gumbel distribution
f = (1/beta)*2.71828^(-2.71828^(-(x-zeta)/beta)-(x-zeta)/beta)

;setting plot device to ps
SET_PLOT, 'PS'

;Here is the filename for the graph
DEVICE, Filename ="Gumbel.ps"

Plot, x, f, title = "Gumbel Distribution", $
	xtitle = "Snowfall (cm)", $
	ytitle = "Probability of Occurence"

;Closing device
DEVICE, /CLOSE

END
