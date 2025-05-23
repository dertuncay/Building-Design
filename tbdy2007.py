import numpy as np

def dbybhy(pga, site_class, I):
    """
    Calculates design spectra according to Turkish Seismic Code 2007 (DBYBHY 2007).

    Parameters:
        pga (float): Peak ground acceleration (e.g., 0.4 for 1st-degree earthquake zone)
        site_class (str): Soil class ('A', 'B', 'C', 'D', or 'E')
        I (float): Importance factor (1.0 - 1.5)

    Returns:
        TT (ndarray): Period values
        Sa (ndarray): Spectral acceleration values
    """

    if I not in [1,1.2,1.4,1.5]:
        print('I should be one of the following valies:\n 1.0, 1.2, 1.4, 1.5')
        # break

    # Site coefficient S based on soil class and PGA
    if site_class == 'A':
        Ta = 0.10
        Tb = 0.30
    elif site_class == 'B':
        Ta = 0.15
        Tb = 0.40
    elif site_class == 'C':
        Ta = 0.15
        Tb = 0.60
    elif site_class == 'D':
        Ta = 0.20
        Tb = 0.90
    else:
        raise ValueError("Invalid site class.")
    # T 0 - T0
    Tst = np.arange(0,Ta,0.01)
    # T flat part
    Ti  = np.arange(Ta,Tb,0.01)
    # T Ts - 3 s
    Tl = np.arange(Tb,3,0.01)
    # Total T
    T = np.hstack(( Tst, Ti, Tl )).ravel()
    # T = np.array([Tst, Ti, Tl])

    # Sa 0 - T0
    Sas = 1 + 1.5*(Tst/Ta)
    # Sa flat part
    sai = np.ones(Ti.shape[0])*2.5
    # Sa Ts - 3 s
    Sal = 2.5*(Tb/Tl)**0.8
    # Total Sa
    Sa = pga*I*np.hstack(( Sas, sai, Sal )).ravel()
    # Sa = np.array([Sas, sai, Sal])

    return T, Sa