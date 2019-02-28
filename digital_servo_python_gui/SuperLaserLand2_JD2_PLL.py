"""
XEM6010 Phase-lock box communication interface, PLL sub-module
by JD Deschenes, October 2013

"""
from __future__ import print_function

import numpy as np
    
class Loop_filters_module(object):
    # Values that are fixed in the firmware (VHDL/Verilog code)
    BUS_OFFSET_settings      = 0x0
    BUS_OFFSET_gain_p        = 0x1
    BUS_OFFSET_gain_i        = 0x2
    BUS_OFFSET_gain_ii       = 0x3
    BUS_OFFSET_gain_d        = 0x4
    BUS_OFFSET_coef_df   = 0x5
    
    def __init__(self, bus_base_address, N_DIVIDE_P, N_DIVIDE_I, N_DIVIDE_II, N_DIVIDE_D, N_DIVIDE_DF):
        self.bus_base_address = bus_base_address
        self.N_DIVIDE_P = N_DIVIDE_P
        self.N_DIVIDE_I = N_DIVIDE_I
        self.N_DIVIDE_II = N_DIVIDE_II
        self.N_DIVIDE_D = N_DIVIDE_D
        self.N_DIVIDE_DF = N_DIVIDE_DF
        self.gain_p = 0.
        self.gain_i = 0.
        self.gain_ii = 0.
        self.gain_d = 0.
        self.coef_df = 0.
        
        self.N_delay_p = 5 # TODO: put the correct values here
        self.N_delay_i = 6 # TODO: put the correct values here
        self.N_delay_ii = 7 # TODO: put the correct values here
        self.N_delay_d = 7 # TODO: put the correct values here
    
    @property
    def int_p_limits(self):
        '''Gain P is signed 32 bit integer on the FPGA'''
        return (1,
                2**(32-1)-1)
    
    @property
    def int_i_limits(self):
        '''Gain I is signed 32 bit integer on the FPGA'''
        return (1,
                2**(32-1)-1)
    
    @property
    def int_ii_limits(self):
        '''Gain II is signed 32 bit integer on the FPGA'''
        return (1,
                2**(32-1)-1)
    
    @property
    def int_d_limits(self):
        '''Gain D is signed 32 bit integer on the FPGA'''
        return (1,
                2**(32-1)-1)
    
    @property
    def int_df_limits(self):
        '''Filter Coefficient DF is signed 18 bit integer on the FPGA'''
        return (1,
                2**(18-1)-1)
    
    @property
    def p_limits(self):
        (min_int_p, max_int_p) = self.int_p_limits
        return (min_int_p/2.**self.N_DIVIDE_P,
                max_int_p/2.**self.N_DIVIDE_P)
    
    @property
    def i_limits(self):
        (min_int_i, max_int_i) = self.int_i_limits
        return (min_int_i/2.**self.N_DIVIDE_I,
                max_int_i/2.**self.N_DIVIDE_I)
    
    @property
    def ii_limits(self):
        (min_int_ii, max_int_ii) = self.int_ii_limits
        return (min_int_ii/2.**self.N_DIVIDE_II,
                max_int_ii/2**self.N_DIVIDE_II)
    
    @property
    def d_limits(self):
        (min_int_d, max_int_d) = self.int_d_limits
        return (min_int_d/2.**self.N_DIVIDE_D,
                max_int_d/2.**self.N_DIVIDE_D)        
    
    @property
    def df_limits(self):
        (min_int_df, max_int_df) = self.int_df_limits
        return (min_int_df/2.**self.N_DIVIDE_DF,
                max_int_df/2.**self.N_DIVIDE_DF)
        
    def get_current_transfer_function(self, freq_axis, fs):
        
        unit_delay_phase_ramp = 2*np.pi * freq_axis/fs
        H_cumsum = 1/(1-np.exp(1j*unit_delay_phase_ramp))
        
        afilt = self.coef_df
        H_filt = afilt/(1-(1-afilt)*np.exp(1j*unit_delay_phase_ramp))
        H_diff = (1-np.exp(1j*unit_delay_phase_ramp))
        
        # The transfer function is the sum of the four terms (P, I, II, D)
        H_loop_filters = self.gain_i * H_cumsum * np.exp(-1j*self.N_delay_i * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_ii * H_cumsum**2 * np.exp(-1j*self.N_delay_ii * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_p * np.exp(-1j*self.N_delay_p * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters + self.gain_d * H_diff * H_filt * np.exp(-1j*self.N_delay_d * unit_delay_phase_ramp)
        #H_loop_filters = self.gain_d * (0.5) * H_diff * np.exp(-1j*self.N_delay_d * unit_delay_phase_ramp)
        #print(H_loop_filters)

        return H_loop_filters

        
    def set_pll_settings(self, sl, gain_p, gain_i, gain_ii, gain_d, coef_df, bLock):
        # Register format is:
        # gain_p  (32 bits signed, actual gain is gain_p/ 2**N_DIVIDE_P)
        # gain_i  (32 bits signed, actual gain is gain_i/ 2**N_DIVIDE_I)
        # gain_ii (32 bits signed, actual gain is gain_ii/2**N_DIVIDE_II)
        # settings register: 1 bit: bLock
        bDebugOutput = False
        
        gain_p_int = int(round(gain_p*2.**self.N_DIVIDE_P))
        gain_i_int = int(round(gain_i*2.**self.N_DIVIDE_I))
        gain_ii_int = int(round(gain_ii*2.**self.N_DIVIDE_II))
        gain_d_int = int(round(gain_d*2.**self.N_DIVIDE_D))
        coef_df_int = int(round(coef_df*2.**self.N_DIVIDE_DF))
        
        if gain_p_int > max(self.int_p_limits):
            if bDebugOutput:
                print('P Gain maximized.')
            gain_p_int = max(self.int_p_limits)
        elif gain_p_int < min(self.int_p_limits):
            if bDebugOutput:
                print('P Gain off.')
            gain_p_int = 0
        
        if gain_i_int > max(self.int_i_limits):
            if bDebugOutput:
                print('I Gain maximized.')
            gain_i_int = max(self.int_i_limits)
        elif gain_i_int < min(self.int_i_limits):
            if bDebugOutput:
                print('I Gain off.')
            gain_i_int = 0
        
        if gain_ii_int > max(self.int_ii_limits):
            if bDebugOutput:
                print('II Gain maximized.')
            gain_ii_int = max(self.int_ii_limits)
        elif gain_ii_int < min(self.int_ii_limits):
            if bDebugOutput:
                print('II Gain off.')
            gain_ii_int = 0
        
        if gain_d_int > max(self.int_d_limits):
            if bDebugOutput:
                print('D Gain maximized.')
            gain_d_int = max(self.int_d_limits)
        elif gain_d_int < min(self.int_d_limits):
            if bDebugOutput:
                print('D Gain off.')
            gain_d_int = 0
        
        if coef_df_int > max(self.int_df_limits):
            if bDebugOutput:
                print('DF Coef maximized.')
            coef_df_int = max(self.int_df_limits)
        elif coef_df_int < min(self.int_df_limits):
            if bDebugOutput:
                print('DF Coef off.')
            coef_df_int = 0
        
        self.gain_p = gain_p_int/2.**self.N_DIVIDE_P
        self.gain_i = gain_i_int/2.**self.N_DIVIDE_I
        self.gain_ii = gain_ii_int/2.**self.N_DIVIDE_II
        self.gain_d = gain_d_int/2.**self.N_DIVIDE_D
        self.coef_df = coef_df_int/2.**self.N_DIVIDE_DF
        
        if bDebugOutput:
            print('P_gain = {:.4g}, in integer: P_gain = {:d} = 2^{:.3f}'.format(self.gain_p, gain_p_int, 1+np.log2(gain_p_int)))
            print('I_gain = {:.4g}, in integer: I_gain = {:d} = 2^{:.3f}'.format(self.gain_i, gain_i_int, 1+np.log2(gain_i_int)))
            print('II_gain = {:.4g}, in integer: II_gain = {:d} = 2^{:.3f}'.format(self.gain_ii, gain_ii_int, 1+np.log2(gain_ii_int)))
            print('D_gain = {:.4g}, in integer: D_gain = {:d} = 2^{:.3f}'.format(self.gain_d, gain_d_int, 1+np.log2(gain_d_int)))
            print('DF_gain = {:.4g}, in integer: DF_gain = {:d} = 2^{:.3f}'.format(self.coef_df, coef_df_int, 1+np.log2(coef_df_int)))
            print('')
        
        # Send P gain
        int_bits15_to_0 = gain_p_int & 0xFFFF
        int_bits31_to_16 = (gain_p_int & 0xFFFF0000) >> 16
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_p, int_bits15_to_0, int_bits31_to_16)
#        print('int_bits15_to_0 = %d, int_bits31_to_16 = %d' % (int_bits15_to_0, int_bits31_to_16))
        
        # Send I gain
        int_bits15_to_0 = gain_i_int & 0xFFFF
        int_bits31_to_16 = (gain_i_int & 0xFFFF0000) >> 16
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_i, int_bits15_to_0, int_bits31_to_16)
        #print('address = %x' % (self.bus_base_address + self.BUS_OFFSET_gain_i))
        
        # Send II gain
        int_bits15_to_0 = gain_ii_int & 0xFFFF
        int_bits31_to_16 = (gain_ii_int & 0xFFFF0000) >> 16
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_ii, int_bits15_to_0, int_bits31_to_16)
            
        # Send D gain
        int_bits15_to_0 = gain_d_int & 0xFFFF
        int_bits31_to_16 = (gain_d_int & 0xFFFF0000) >> 16
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_gain_d, int_bits15_to_0, int_bits31_to_16)
            
        # Send DF gain
        int_bits15_to_0 = coef_df_int & 0xFFFF
        int_bits31_to_16 = (coef_df_int & 0xFFFF0000) >> 16
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_coef_df, int_bits15_to_0, int_bits31_to_16)
        
        # Send lock/unlock setting
        sl.send_bus_cmd(self.bus_base_address + self.BUS_OFFSET_settings, bLock, 0)

    def get_pll_settings(self, sl):
        gain_p_int  = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_gain_p)
        gain_i_int  = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_gain_i)
        gain_ii_int = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_gain_ii)
        gain_d_int  = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_gain_d)
        coef_df_int = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_coef_df)
        bLock       = sl.read_RAM_dpll_wrapper(self.bus_base_address + self.BUS_OFFSET_settings)

        self.gain_p  = gain_p_int/2.**self.N_DIVIDE_P
        self.gain_i  = gain_i_int/2.**self.N_DIVIDE_I
        self.gain_ii = gain_ii_int/2.**self.N_DIVIDE_II
        self.gain_d  = gain_d_int/2.**self.N_DIVIDE_D
        self.coef_df = coef_df_int/2.**self.N_DIVIDE_DF
        self.bLock   = bLock
        return (self.gain_p,  self.gain_i, self.gain_ii, self.gain_d, self.coef_df, self.bLock)


class PLL0_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code)
    bus_base_address = 0x7000
    N_DIVIDE_P = 10
    N_DIVIDE_I = 27
    N_DIVIDE_II = 36
    N_DIVIDE_D = 11
    N_DIVIDE_DF = 18
    
    def __init__(self, sl):
        super(PLL0_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
class PLL1_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code)
    bus_base_address = 0x7010
    N_DIVIDE_P = 10
    N_DIVIDE_I = 27
    N_DIVIDE_II = 36
    N_DIVIDE_D = 11
    N_DIVIDE_DF = 18

    
    def __init__(self, sl):
        super(PLL1_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
        
class PLL2_module(Loop_filters_module):
    
    # Values that are fixed in the firmware (VHDL/Verilog code)
    bus_base_address = 0x7020
    N_DIVIDE_P = 11
    N_DIVIDE_I = 40
    N_DIVIDE_II = 29
    N_DIVIDE_D = 0
    N_DIVIDE_DF = 18

    
    def __init__(self, sl):
        super(PLL2_module, self).__init__(self.bus_base_address, self.N_DIVIDE_P, self.N_DIVIDE_I, self.N_DIVIDE_II, self.N_DIVIDE_D, self.N_DIVIDE_DF)
        
