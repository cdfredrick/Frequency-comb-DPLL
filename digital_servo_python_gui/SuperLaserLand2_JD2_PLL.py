"""
XEM6010 Phase-lock box communication interface, PLL sub-module
by JD Deschenes, October 2013

"""
from __future__ import print_function

import numpy as np
import RP_PLL

class Loop_filters_module(object):
    def __init__(self, device, channel):
        assert isinstance(device, RP_PLL.RP_PLL_device)
        assert isinstance(channel, int)
        self.dev = device # instance of RP_PLL for device communications
        self.chan = channel

        self.bus_base_addr = self.dev.BUS_ADDR_PLL_BASE[self.chan]
        # Lock Enable Register Register Address
        self.lock_en_addr = self.bus_base_addr + self.dev.BUS_OFFSET_LOCK
        # Proportional Gain Register Address
        self.gain_p_addr = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_P
        # Integral Gain Register Address
        self.gain_i_addr_lsbs = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_I_LSBs
        self.gain_i_addr_msbs = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_I_MSBs
        # Double Integral Gain Register Address
        self.gain_ii_addr_lsbs = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_II_LSBs
        self.gain_ii_addr_msbs = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_II_MSBs
        # Derivative Gain Register Address
        self.gain_d_addr = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_D
        # Derivative Filter Gain Register Address
        self.coef_df_addr = self.bus_base_addr + self.dev.BUS_OFFSET_COEF_DF
        # Open Loop Gain Register Address
        self.gain_ol_addr = self.bus_base_addr + self.dev.BUS_OFFSET_GAIN_OL

        self.N_DIVIDE_P = self.dev.N_BITS_DIVIDE_P[self.chan]
        self.N_DIVIDE_I = self.dev.N_BITS_DIVIDE_I[self.chan]
        self.N_DIVIDE_II = self.dev.N_BITS_DIVIDE_II[self.chan]
        self.N_DIVIDE_D = self.dev.N_BITS_DIVIDE_D[self.chan]
        self.N_DIVIDE_DF = self.dev.N_BITS_DIVIDE_DF[self.chan]

        self.gain_p = 0.
        self.gain_i = 0.
        self.gain_ii = 0.
        self.gain_d = 0.
        self.coef_df = 0.
        self.gain_ol = 0.

        self.N_delay_p = self.dev.N_CYCLS_DELAY_P[self.chan]
        self.N_delay_i = self.dev.N_CYCLES_DELAY_I[self.chan]
        self.N_delay_ii = self.dev.N_CYCLES_DELAY_II[self.chan]
        self.N_delay_d = self.dev.N_CYCLES_DELAY_D[self.chan]

    ###########################################################################
    #--- Parameter Limits:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Integer Parameter Limits:
    #

    @property
    def int_p_limits(self):
        '''Gain P is signed 32 bit integer on the FPGA'''
        return (1,
                2**(self.dev.N_BITS_GAIN_P[self.chan] - 1) -1)

    @property
    def int_i_limits(self):
        '''Gain I is signed 32 bit integer on the FPGA'''
        return (1,
                2**(self.dev.N_BITS_GAIN_I[self.chan] - 1) - 1)

    @property
    def int_ii_limits(self):
        '''Gain II is signed 32 bit integer on the FPGA'''
        return (1,
                2**(self.dev.N_BITS_GAIN_II[self.chan] - 1) - 1)

    @property
    def int_d_limits(self):
        '''Gain D is signed 32 bit integer on the FPGA'''
        return (1,
                2**(self.dev.N_BITS_GAIN_D[self.chan] - 1) - 1)

    @property
    def int_df_limits(self):
        '''Filter Coefficient DF is signed 18 bit integer on the FPGA'''
        return (1,
                2**(self.dev.N_BITS_COEF_DF[self.chan] - 1) - 1)

    #--------------------------------------------------------------------------
    # Scaled Parameter Limits:
    #

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

    ###########################################################################
    #--- Read/Write Loop Filter Settings:
    ###########################################################################
    #

    def set_pll_settings(self, gain_p, gain_i, gain_ii, gain_d, coef_df, bLock, gain_ol):
        # Register format is:
        # gain_p  (32 bits signed, actual gain is gain_p/ 2**N_DIVIDE_P)
        # gain_i  (32 bits signed, actual gain is gain_i/ 2**N_DIVIDE_I)
        # gain_ii (32 bits signed, actual gain is gain_ii/2**N_DIVIDE_II)
        # settings register: 1 bit: bLock
        bDebugOutput = True

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

        # Send lock/unlock setting
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.lock_en_addr),
                bLock)
        # Send P gain
        self.dev.write_Zynq_register_int32(
                self.dev.dpll_write_address(self.gain_p_addr),
                gain_p_int)
        # Send I gain
        self.dev.write_Zynq_register_int64(
                self.dev.dpll_write_address(self.gain_i_addr_lsbs),
                self.dev.dpll_write_address(self.gain_i_addr_msbs),
                gain_i_int)
        # Send II gain
        self.dev.write_Zynq_register_int64(
                self.dev.dpll_write_address(self.gain_ii_addr_lsbs),
                self.dev.dpll_write_address(self.gain_ii_addr_msbs),
                gain_ii_int)
        # Send D gain
        self.dev.write_Zynq_register_int32(
                self.dev.dpll_write_address(self.gain_d_addr),
                gain_d_int)
        # Send DF coef
        self.dev.write_Zynq_register_int32(
                self.dev.dpll_write_address(self.coef_df_addr),
                coef_df_int)
        # Send OL gain
        self.dev.write_Zynq_register_float32(
                self.dev.dpll_write_address(self.gain_ol_addr),
                gain_ol)

    def get_pll_settings(self):
        # Get Lock/Unlock setting
        bLock = self.dev.read_Zynq_register_uint16(
                self.dev.dpll_read_address(self.lock_en_addr))
        # Get P Gain
        gain_p_int = self.dev.read_Zynq_register_int32(
                self.dev.dpll_read_address(self.gain_p_addr))
        # Get I Gain
        gain_i_int = self.dev.read_Zynq_register_int64(
                self.dev.dpll_read_address(self.gain_i_addr_lsbs),
                self.dev.dpll_read_address(self.gain_i_addr_msbs))
        # Get II Gain
        gain_ii_int = self.dev.read_Zynq_register_int64(
                self.dev.dpll_read_address(self.gain_ii_addr_lsbs),
                self.dev.dpll_read_address(self.gain_ii_addr_msbs))
        # Get D Gain
        gain_d_int = self.dev.read_Zynq_register_int32(
                self.dev.dpll_read_address(self.gain_d_addr))
        # Get DF Coef
        coef_df_int = self.dev.read_Zynq_register_int32(
                self.dev.dpll_read_address(self.coef_df_addr))
        # Get Open Loop Gain
        gain_ol = self.dev.read_Zynq_register_float32(
                self.dev.dpll_read_address(self.gain_ol_addr))

        self.bLock   = bLock
        self.gain_p  = gain_p_int/2.**self.N_DIVIDE_P
        self.gain_i  = gain_i_int/2.**self.N_DIVIDE_I
        self.gain_ii = gain_ii_int/2.**self.N_DIVIDE_II
        self.gain_d  = gain_d_int/2.**self.N_DIVIDE_D
        self.coef_df = coef_df_int/2.**self.N_DIVIDE_DF
        self.gain_ol = gain_ol # float to float, no conversion
        return (self.gain_p,  self.gain_i, self.gain_ii, self.gain_d, self.coef_df, self.bLock, self.gain_ol)

    ###########################################################################
    #--- Loop Filter Helper Functions:
    ###########################################################################
    #

    def get_current_transfer_function(self, freq_axis, fs):

        unit_delay_phase_ramp = 2*np.pi * freq_axis/fs
        H_cumsum = 1/(1-np.exp(1j*unit_delay_phase_ramp))
        #H_cumsum = 1/(1j*unit_delay_phase_ramp)

        afilt = self.coef_df
        H_filt = afilt/(1-(1-afilt)*np.exp(1j*unit_delay_phase_ramp))
        #H_filt = afilt/(afilt+(1-np.exp(1j*unit_delay_phase_ramp)))
        #H_filt = afilt/(afilt+1j*unit_delay_phase_ramp)
        H_diff = (1-np.exp(1j*unit_delay_phase_ramp))
        #H_diff = 1j*unit_delay_phase_ramp

        # The transfer function is the sum of the four terms (P, I, II, D)
        H_loop_filters_P = self.gain_p * np.exp(-1j*self.N_delay_p * unit_delay_phase_ramp)
        H_loop_filters_I = self.gain_i * H_cumsum * np.exp(-1j*self.N_delay_i * unit_delay_phase_ramp)
        H_loop_filters_II = self.gain_ii * H_cumsum**2 * np.exp(-1j*self.N_delay_ii * unit_delay_phase_ramp)
        H_loop_filters_D = self.gain_d * H_diff * H_filt * np.exp(-1j*self.N_delay_d * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters_P + H_loop_filters_II + H_loop_filters_I + H_loop_filters_D
        #print(H_loop_filters)

        return H_loop_filters

    def getFreqDiscriminatorGain(self):
        return 2**self.dev.DDC_FREQ_N_BITS/self.dev.ADC_CLK_Hz # number of fractional bits (CORDIC output)/sample rate

    ###########################################################################
    #--- PLL 1 Only Methods:
    ###########################################################################
    #

    def set_mux_pll1(self, register_value):
        ''' This mux selects the source of the error signal to the loop filter
        of channel 1.

        This makes it possible to select:
            - register_value = 0:
                the output of DDC2 (the normal, 2 independent
                channels operation)
            - register_value = 1:
                the output of DDC1 (allows two different loop filter settings
                being applied to the same error signal)
            - register_value = 2:
                the output of the channel 1's loop filter, to allow locking
                the same beat note with two actuators

        '''
        if self.chan != 1:
            raise AttributeError('Channel {:} does not have access to set_mux_pll1'.format(self.chan))
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_MUX_PLL1),
                register_value)

    def read_pll1_mux(self):
        if self.chan != 1:
            raise AttributeError('Channel {:} does not have access to read_pll1_mux'.format(self.chan))
        mux_value = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_MUX_PLL1))
        return mux_value
