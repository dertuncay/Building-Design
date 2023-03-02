import numpy as np

# Vs30 to Turkish Soil Classification
def vs302TSC(vs30):
	if vs30 >= 1500:
		return 'ZA'
	elif 760 <= vs30 < 1500:
		return 'ZB'
	elif 360 <= vs30 < 760:
		return 'ZC'
	elif 180 <= vs30 < 360:
		return 'ZD'
	elif vs30 <= 180:
		return 'ZE'

def cms22g(val):
	# cm/s2 to g
	return val/980.665

def g2cms2(val):
	# g to cm/s2
	return val*980.665

# Horizontal Design Spectrum (g)
def horizontal_spectra(T, SDs, SD1, TA, TB , TL):  
	if T < TA :
		return((0.4 + 0.6*(T/TA))*SDs)
	elif T >= TA and T <= TB:
		return (SDs)
	elif T> TB and T <= TL:
		return (SD1/T)
	elif T> TL:
		return (SD1*TL/(T**2))

# Vertical Design Spectrum
def vertical_spectra(T, SDs, TA, TB):  
	if T < TA :
		return (0.32 + 0.48*(T/TA))*SDs
	elif T >= TA and T <= TB:
		return 0.8 * SDs
	elif T> TB :
		return  (0.8 * SDs * TB / T)

Ss_range = [0.25 , 0.50 , 0.75, 1.00 , 1.25 , 1.50 ]
FS_table = {"ZA": [0.8 , 0.8 , 0.8 , 0.8 , 0.8 , 0.8], 
			"ZB": [0.9 , 0.9 , 0.9 , 0.9 , 0.9 , 0.9], 
			"ZC": [1.3 , 1.3 , 1.2 , 1.2 , 1.2 , 1.2],
			"ZD": [1.6 , 1.4 , 1.2 , 1.1 , 1.0 , 1.0],
			"ZE": [2.4 , 1.7 , 1.3 , 1.1 , 0.9 , 0.8]}

S1_range = [0.10 , 0.20 , 0.30, 0.40 , 0.50 , 0.60 ]
F1_table = {"ZA": [0.8 , 0.8 , 0.8 , 0.8 , 0.8 , 0.8], 
			"ZB": [0.8 , 0.8 , 0.8 , 0.8 , 0.8 , 0.8], 
			"ZC": [1.5 , 1.5 , 1.5 , 1.5 , 1.5 , 1.4],
			"ZD": [2.4 , 2.2 , 2.0 , 1.9 , 1.8 , 1.7],
			"ZE": [4.2 , 3.3 , 2.8 , 2.4 , 2.2 , 2.0]}


def calc_tbdy(soil,Ss,S1,periods=None,soil_unit='vs30',period_unit='cms2',plot=False):
	'''
	This code is modified from here: https://github.com/gtuinsaat/TBDY2018_tepki_spektrumu 
	Turkish Building Earthquake Regulation (TBDY-2018)
	Inputs:
	soil - if soil unit is 'vs30', the input must be in cm/s2 Vs30 value.
	If soil unit is 'soiltype', the input must be one of the following: 'ZA','ZB','ZC','ZD','ZE'
	period unit - period unit must be in cms2 for spectral inputs for 0.2s and 1.0s for 'cms2' or in g for 'g'
	Ss - 0.2s spectral acceleration value for a given position determined by TBDY-2018
	S1 - 1.0s spectral acceleration value for a given position determined by TBDY-2018
	plot - If True, horizontal and vertical spectras will be shown
	Outputs:
	SA_H - Horizontal design spectra in unit of g
	SA_V - Vertical design spectra in unit of g
	'''
	if period_unit == 'cms2':
		Ss = cms22g(Ss)
		S1 = cms22g(S1)
	elif period_unit == 'g':
		Ss = Ss
		S1 = S1
	else:
		raise ('Period unit must be cms2 for cm/s^2 or g for the g-units')

	# Define Soil Class => "ZA", "ZB","ZC","ZD","ZE" 
	if soil_unit == 'vs30':
		soil = vs302TSC(soil)
	elif soil_unit == 'soiltype' and soil in ['ZA','ZB','ZC','ZD','ZE']:
		soil = soil
	else:
		raise ('Soil unit must be vs30 in cm/s2 or in local soil classes (ZA,ZB,ZC,ZD,ZE) check https://dergipark.org.tr/tr/download/article-file/1407009 Table 3')


	# Calculation of short periods
	FS_row = np.polyfit(Ss_range, FS_table[soil], 1)
	FS_constant = np.poly1d( FS_row )
	Fs = float( format(FS_constant(Ss) , '.2f') )
	SDs = Ss * Fs

	# Calculation of 1s period
	F1_row = np.polyfit(S1_range, F1_table[soil], 1)
	F1_constant = np.poly1d( F1_row )
	F1 = float( format(F1_constant(S1) , '.2f') )
	SD1 = S1 * F1

	# Example
	TA = 0.2 * SD1 / SDs
	TB = SD1 / SDs
	TL = 6

	# Create Horizontal Spectra 
	if periods is None:
		T_range = [0.01*item for item in range(1,1001)]
	else:
		T_range = periods
	SA_H = [(horizontal_spectra(period, SDs, SD1, TA, TB , TL)) for period in T_range]

	# Create Vertical Spectra 
	TAV , TBV , TLV = TA / 3 , TB/3 , TL/2
	SA_V = [vertical_spectra(period, SDs, TAV, TBV) for period in T_range]

	if plot == True:
		import matplotlib.pyplot as plt
		# Plot results
		fig, axs = plt.subplots(2,1,figsize=(10,5),sharex=True,sharey=True)
		axs = axs.flat

		# Horizontal
		axs[0].plot(T_range , SA_H,"r")
		axs[0].grid()
		# axs[0].set_xlabel("Period (s)")
		axs[0].set_ylabel("Sa (g)")
		axs[0].set_title('Horizontal Design Spectra')

		# Vertical
		axs[1].plot(T_range , SA_V,"r")
		axs[1].grid()
		axs[1].set_xlabel("Period (s)")
		axs[1].set_ylabel("Sa (g)")
		axs[1].set_title('Vertical Design Spectra')

		fig.suptitle('Ss: {} g | S1: {} g | Soil: {}'.format(round(Ss,2),round(S1,2),soil))
		plt.show()

	return SA_H, SA_V
