# -*- coding: utf-8 -*-
"""
XEM6010 Phase-lock box communication interface,
by JD Deschenes, October 2013
Modified January 2016 to interface with the Red Pitaya port of the phase-lock box

"""
from __future__ import print_function

# import ok       # used to talk to the FPGA board
import time     # used for time.sleep()
import numpy as np
from scipy.signal import lfilter

import os

from SuperLaserLand2_JD2_PLL import Loop_filters_module
import RP_PLL

class SuperLaserLand_JD_RP:
    ###########################################################################
    #--- Class Initialization
    ###########################################################################
    #

    def __init__(self, controller):
        #----------------------------------------------------------------------
        # Communications Logging
        #
        self.bCommunicationLogging = False   # Turn On/Off logging of the USB communication with the FPGA box
        self.bVerbose = False
        if self.bCommunicationLogging == True:
            os.makedirs('data_logging', exist_ok=True)
            strNameTemplate = time.strftime("data_logging\%m_%d_%Y_%H_%M_%S_")
            strCurrentName = strNameTemplate + 'SuperLaserLand_log.txt'
            self.log_file = open(strCurrentName, 'w')

        #----------------------------------------------------------------------
        # Device Communications:
        #

        self.controller = controller
        self.dev = RP_PLL.RP_PLL_device(self.controller)

        #----------------------------------------------------------------------
        # Sub-Module Initialization:
        #

        self.pll = [Loop_filters_module(self.dev, channel) for channel in range(3)]

        #----------------------------------------------------------------------
        # System Parameters:
        #

        self.bDDR2InUse = False  # Each function that uses the DDR2 logger module should make sure that this isn't set before changing any setting

        self.ddc0_filter_select = 0
        self.ddc1_filter_select = 0
        self.ddc0_angle_select = 0
        self.ddc1_angle_select = 0
        self.residuals0_phase_or_freq = 0
        self.residuals1_phase_or_freq = 0


        self.ddc0_frequency_in_hz = 125e6/4
        self.ddc1_frequency_in_hz = 125e6/4
        self.ddc0_int_phase_incr = self.DDS_phase_increment_parameter(self.ddc0_frequency_in_hz)
        self.ddc1_int_phase_incr = self.DDS_phase_increment_parameter(self.ddc0_frequency_in_hz)
        self.DACs_limit_low = self.dev.DAC_LIM_LOW_INT[:] # [:] returns copy
        self.DACs_limit_high = self.dev.DAC_LIM_HIGH_INT[:]
        self.DACs_offset = [0, 0, 0]

        self.output_vco = [0, 0, 0]

        # Triangular averaging is on by default:
        self.bTriangularAveraging = 1

        # variables for the dither lock-in:
        self.modulation_period_divided_by_4_minus_one = [0, 0, 0]
        self.N_periods_integration_minus_one = [0, 0, 0]
        self.dither_amplitude = [0, 0, 0]
        self.dither_enable = [0, 0, 0]
        self.dither_mode_auto = [1, 1, 1] # 1 means automatic (on when lock is off, off when lock is on), 0 means manual
        self.lock_read = [0, 0, 0]

        # this holds a sample number used to make sure that we don't grab the same counter samples twice
        self.last_zdtc_samples_number_counter = [0, 0]

        self.last_freq_update = 0
        self.new_freq_setting_number = 0

    ###########################################################################
    #--- Generic Helper Functions
    ###########################################################################
    #

    def set_bits(self, bit_values, N_bit_start_loc, bit_length=1):
        assert isinstance(bit_values, int)
        assert isinstance(N_bit_start_loc, int)
        assert isinstance(bit_length, int)
        if bit_values.bit_length() > bit_length:
            raise ValueError("{:} is greater than {:} bits".format(bit_values, bit_length))
        return bit_values << N_bit_start_loc

    def get_bits(self, bit_values,  N_bit_start_loc, bit_length=1):
        assert isinstance(N_bit_start_loc, int)
        assert isinstance(bit_length, int)
        return (bit_values >> N_bit_start_loc) % 2**bit_length

    ###########################################################################
    #--- Reset Signals:
    ###########################################################################
    #

    def reset_front_end(self):
        if self.bVerbose == True:
            print('reset_front_end')

        print('Resetting FPGA (reset_front_end)...')
        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_TRIG_RESET_FRONTEND*4, 0)

    ###########################################################################
    #--- Primary ADC Inputs:
    ###########################################################################
    # no functions...
    #

    ###########################################################################
    #--- Digital Down Converter (DDC):
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # DDS Helper Functions
    #

    def DDS_phase_increment_parameter(self, target_frequency_Hz):
        '''Calculate the DDS integer phase increment parameter that will
        produce an output frequency nearest to the target.

        See the theory of operation in standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        # Magnitude of the fractional phase increment
        target_fractional_phase_increment = abs(target_frequency_Hz)/self.dev.ADC_CLK_Hz
        # Magnitude of the target phase increment parameter
        target_phase_increment_parameter = target_fractional_phase_increment * 2**self.dev.DDC_DDS_PHASE_ACCUM_N_BITS
        # Wrapped integer magnitude of the phase increment parameter
        int_phase_increment_parameter = int(round(target_phase_increment_parameter)) % 2**self.dev.DDC_DDS_PHASE_ACCUM_N_BITS
        # Signed integer phase increment parameter
        int_phase_increment_parameter = int(int_phase_increment_parameter * np.sign(target_frequency_Hz))
        return int_phase_increment_parameter

    def DDS_frequency(self, int_phase_increment_parameter):
        '''Calculate the DDS output frequency in Hz given an integer phase
        increment parameter.

        See the theory of operation in standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        fractional_phase_increment = int_phase_increment_parameter / 2**self.dev.DDC_DDS_PHASE_ACCUM_N_BITS
        frequency_Hz = fractional_phase_increment * self.dev.ADC_CLK_Hz
        return frequency_Hz

    @property
    def DDS_frequency_resolution(self):
        '''Calculate the frequency resolution of the DDS.

        See the theory of operation in standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        frequency_resolution = self.dev.ADC_CLK_Hz / 2**self.dev.DDC_DDS_PHASE_ACCUM_N_BITS
        return frequency_resolution

    #--------------------------------------------------------------------------
    # DDC Helper Functions
    #

    def DDC_frequency(self, ddc_frequency_int):
        '''Convert the internal FPGA integer DDC output into frequency offset
        in Hz.
        '''
        if self.bVerbose == True:
            print('DDC_frequency')
        return ddc_frequency_int * self.dev.DDC_FREQ_INT

    def frontend_DDC_processing(self, samples, ref_exp0, input_number):
        if self.bVerbose == True:
            print('frontend_DDC_processing, len(samples) = %d, samples[0] = %d' % (len(samples), samples[0]))

        # Fractional Frequency Offset
        if input_number == 0:
            f_reference = self.DDS_frequency(self.ddc0_int_phase_incr) / self.dev.ADC_CLK_Hz
        elif input_number == 1:
            f_reference = self.DDS_frequency(self.ddc1_int_phase_incr) / self.dev.ADC_CLK_Hz

        ref_exp = (ref_exp0)/np.abs(ref_exp0) * np.exp(-1j*2*np.pi*f_reference*np.array(range(len(samples))))
        complex_baseband = (samples-np.mean(samples)) * ref_exp

        # There are two versions of the firmware in use: one uses a 20points boxcar filter,
        # the other one uses a wider bandwidth filter, consisting of a cascade of a 2-pts boxcar, another 2-pts boxcar, and finally a 4-points boxcar.
        if input_number == 0:
            filter_select = self.ddc0_filter_select
            angle_select  = self.ddc0_angle_select
        else:
            filter_select = self.ddc1_filter_select
            angle_select  = self.ddc1_angle_select

        if filter_select == 0:
            N_filter = 16
            lpf = np.convolve(np.ones(2, dtype=float)/2., np.ones(2, dtype=float)/2.)
            lpf = np.convolve(np.ones(4, dtype=float)/4., lpf)
        elif filter_select == 1:
            N_filter = 20
            lpf = np.convolve(np.ones(4, dtype=float)/4., np.ones(16, dtype=float)/16.)
        elif filter_select == 2:
            N_filter = 16+2
            lpf = np.array([4533, 11833, 14589, 7610, -2628, -5400, -350, 3293, 1086, -1867, -1080, 956, 800, -462, -650, 338])/(2.**15-1)
            lpf = np.convolve(np.ones(2, dtype=float)/2., lpf)
#            print(lpf)
        complex_baseband = lfilter(lpf, 1, complex_baseband)[N_filter:]
        return complex_baseband

    def get_frontend_filter_response(self, frequency_axis, input_number):
        if self.bVerbose == True:
            print('get_frontend_filter_response')

        if input_number == 0:
            f_reference = self.DDS_frequency(self.ddc0_int_phase_incr)
        elif input_number == 1:
            f_reference = self.DDS_frequency(self.ddc1_int_phase_incr)

        if input_number == 0:
            filter_select = self.ddc0_filter_select
            angle_select  = self.ddc0_angle_select
        else:
            filter_select = self.ddc1_filter_select
            angle_select  = self.ddc1_angle_select

        if filter_select == 0:
            # wideband filter
            spc_filter = np.ones(frequency_axis.shape, dtype=float)
            N_filter = 2
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)
            N_filter = 4
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)

            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
        elif filter_select == 1:
            # narrowband filter
            N_filter = 16
            spc_filter = np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)
            N_filter = 4
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/self.dev.ADC_CLK_Hz)

            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
        elif filter_select == 2:
            # minimum-phase fir filter:
            lpf = np.array([4533, 11833, 14589, 7610, -2628, -5400, -350, 3293, 1086, -1867, -1080, 956, 800, -462, -650, 338])/(2.**15-1)
            lpf = np.convolve(np.ones(2, dtype=float)/2., lpf)
            spc_ref = np.fft.fft(lpf, 2*len(frequency_axis))
            freq_axis_ref = np.linspace(0*self.dev.ADC_CLK_Hz, 1*self.dev.ADC_CLK_Hz, 2*len(frequency_axis))
            spc_filter = np.interp(abs(frequency_axis-abs(f_reference)), freq_axis_ref, np.abs(spc_ref))
            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)

        return spc_filter

    #--------------------------------------------------------------------------
    # Read/Write DDC Parameters
    #

    def get_ddc0_ref_freq_from_RAM(self):
        if self.bVerbose == True:
            print('get_ddc0_ref_freq')
        # Read FPGA to get the current value
        self.ddc0_int_phase_incr = self.dev.read_Zynq_register_int64(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_ref_freq0_lsbs),
                self.dev.dpll_read_address(self.dev.BUS_ADDR_ref_freq0_msbs))
        frequency_hz = self.DDS_frequency(self.ddc0_int_phase_incr)
        return frequency_hz

    def get_ddc0_ref_freq(self):
        if self.bVerbose == True:
            print('get_ddc0_ref_freq')

        # This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
        # or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
        frequency_in_hz = self.DDS_frequency(self.ddc0_int_phase_incr)
        return frequency_in_hz

    def set_ddc0_ref_freq(self, frequency_in_hz):
        if self.bVerbose == True:
            print('set_ddc0_ref_freq')
        if self.bCommunicationLogging == True:
            self.log_file.write('set_ddc0_ref_freq()\n')
        # Calculate nearest phase increment parameter
        self.ddc0_int_phase_incr = self.DDS_phase_increment_parameter(frequency_in_hz)
        # Wrap by the number of bits in the phase accumulator
        self.ddc0_int_phase_incr = self.ddc0_int_phase_incr
        # Calculate the actual frequency
        self.ddc0_frequency_in_hz = self.DDS_frequency(self.ddc0_int_phase_incr)
        # Write to FPGA
        self.dev.write_Zynq_register_int64(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_ref_freq0_lsbs),
                self.dev.dpll_write_address(self.dev.BUS_ADDR_ref_freq0_msbs),
                self.ddc0_int_phase_incr)

    def get_ddc1_ref_freq_from_RAM(self):
        if self.bVerbose == True:
            print('get_ddc1_ref_freq')
        # Read FPGA to get the current value
        self.ddc1_int_phase_incr = self.dev.read_Zynq_register_int64(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_REF_FREQ1_LSBs),
                self.dev.dpll_read_address(self.dev.BUS_ADDR_REF_FREQ1_MSBs))
        frequency_in_hz = self.DDS_frequency(self.ddc1_int_phase_incr)
        return frequency_in_hz

    def get_ddc1_ref_freq(self):
        if self.bVerbose == True:
            print('get_ddc1_ref_freq')

        # This only gives the correct answer if either: this object has explicitely ran its set_ddc0_ref_freq() function.
        # or: the default value in the FPGA firmware matches the one in self.frequency_in_int defined as a data member.
        frequency_in_hz = self.DDS_frequency(self.ddc1_int_phase_incr)
        return frequency_in_hz

    def set_ddc1_ref_freq(self, frequency_in_hz):
        if self.bVerbose == True:
            print('set_ddc1_ref_freq')

        if self.bCommunicationLogging == True:
            self.log_file.write('set_ddc1_ref_freq()\n')
        # Calculate nearest phase increment parameter
        self.ddc1_int_phase_incr = self.DDS_phase_increment_parameter(frequency_in_hz)
        # Wrap by the number of bits in the phase accumulator
        self.ddc1_int_phase_incr = self.ddc1_int_phase_incr
        # Calculate the actual frequency
        self.ddc1_frequency_in_hz = self.DDS_frequency(self.ddc1_int_phase_incr)
        # Write to FPGA
        self.dev.write_Zynq_register_int64(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_REF_FREQ1_LSBs),
                self.dev.dpll_write_address(self.dev.BUS_ADDR_REF_FREQ1_MSBs),
                self.ddc1_int_phase_incr)

    def set_ddc_filter(self, adc_number, filter_select, angle_select = 0):
        if self.bVerbose == True:
            print('set_ddc_filter')

        if adc_number == 0:
            self.ddc0_filter_select = filter_select
            self.ddc0_angle_select = angle_select
        elif adc_number == 1:
            self.ddc1_filter_select = filter_select
            self.ddc1_angle_select = angle_select

        self.set_ddc_filter_select_register()

    def set_ddc_filter_select_register(self): #TODO: Break apart setting into filter and angle selection
        if self.bVerbose == True:
            print('set_ddc_filter_select_register')

        # DDC Filter Selection:
        register_value = (
                self.set_bits(self.ddc0_filter_select, 0, bit_length=2)
                +self.set_bits(self.ddc1_filter_select, 2, bit_length=2)
                +self.set_bits(self.residuals0_phase_or_freq, 4)
                +self.set_bits(self.residuals1_phase_or_freq, 5))
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_ddc_filter_select),
                register_value)
        # "Angle" Selection:
        register_value = (self.set_bits(self.ddc0_angle_select, 0, bit_length=4)
                          +self.set_bits(self.ddc1_angle_select, 4, bit_length=4))
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_ddc_angle_select),
                register_value)

    def get_ddc_filter_select(self):
        if self.bVerbose == True:
            print('get_ddc_filter_select')

        data = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_ddc_filter_select))

        self.ddc0_filter_select = self.get_bits(data, 0, bit_length=2)
        self.ddc1_filter_select = self.get_bits(data, 2, bit_length=2)

        return (self.ddc1_filter_select, self.ddc0_filter_select)

    def get_ddc_angle_select(self):
        if self.bVerbose == True:
            print('get_ddc_angle_select')

        data = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_ddc_angle_select))
        self.ddc0_angle_select = self.get_bits(data, 0, bit_length=4)
        self.ddc1_angle_select = self.get_bits(data, 4, bit_length=4)

        return (self.ddc1_angle_select, self.ddc0_angle_select)

    ###########################################################################
    #--- Loop Filters:
    ###########################################################################
    # contained within self.pll[*]
    #

    ###########################################################################
    #--- Dither and Lock-In:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Dither and Lock-In Helper Functions:
    #

    def scaleDitherResultsToHz(self, results, dac_number):
        if self.bVerbose == True:
            print('scaleDitherResultsToHz')

        N_samples_integration = 4*(self.modulation_period_divided_by_4_minus_one[dac_number]+1) * (self.N_periods_integration_minus_one[dac_number]+1)

        # scaling of the Dither results are DDC counts, summed for N_samples_integration.
        results_in_Hz = self.DDC_frequency(results)/N_samples_integration
        return results_in_Hz

    def scaleDitherResultsToHzPerVolts(self, results, dac_number):
        if self.bVerbose == True:
            print('scaleDitherResultsToHzPerVolts')

#        print('type = %s' % type(results))
#        print('shape = %s' % str(results.shape))
        results_in_Hz = self.scaleDitherResultsToHz(results, dac_number)
        dither_amplitude_in_Volts = self.dither_amplitude[dac_number] * self.dev.DAC_V_INT
        if dither_amplitude_in_Volts == 0.:
            dither_amplitude_in_Volts = 1e-10

        results_in_Hz_per_Volts = results_in_Hz/dither_amplitude_in_Volts
        return results_in_Hz_per_Volts

    def setupDitherLockIn(self, dac_number, modulation_period, N_periods, amplitude, mode_auto):
        if self.bVerbose == True:
            print('setupDitherLockIn')

        self.modulation_period_divided_by_4_minus_one[dac_number] = int(round(modulation_period/4-1))
        self.N_periods_integration_minus_one[dac_number] = int(N_periods-1)
        self.dither_amplitude[dac_number] = int(round(amplitude))
        # self.dither_enable[dac_number] = int(bEnable)
        self.dither_mode_auto[dac_number] = int(mode_auto)

        self.setDitherLockInSettings(dac_number)

    #--------------------------------------------------------------------------
    # Read/Write Dither and Lock-In Parameters:
    #

    def setDitherLockInState(self, dac_number, bEnable):
        if self.bVerbose == True:
            print('setDitherLockInState')
        self.dither_enable[dac_number] = int(bEnable)
        self.setDitherLockInSettings(dac_number)

    def setDitherLockInSettings(self, dac_number):
        if self.bVerbose == True:
            print('setDitherLockInSettings')
        # Dither Modulation Period
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_dither_period_divided_by_4_minus_one[dac_number]),
                self.modulation_period_divided_by_4_minus_one[dac_number])
        # Dither Integration Time
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_dither_N_periods_minus_one[dac_number]),
                self.N_periods_integration_minus_one[dac_number])
        # Dither Amplitude
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_dither_amplitude[dac_number]),
                self.dither_amplitude[dac_number])
        # Dither Enabled
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_dither_enable[dac_number]),
                self.dither_enable[dac_number])
        # Auto Dither Enabled
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_dither_mode_auto[dac_number]),
                self.dither_mode_auto[dac_number])

    def get_Dither_Settings(self, dac_number):
        # Dither Modulation Period
        self.modulation_period_divided_by_4_minus_one[dac_number] = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_dither_period_divided_by_4_minus_one[dac_number]))
        # Dither Integration Time
        self.N_periods_integration_minus_one[dac_number] = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_dither_N_periods_minus_one[dac_number]))
        # Dither Amplitude
        self.dither_amplitude[dac_number] = self.dev.read_Zynq_register_uint16(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_dither_amplitude[dac_number]))
        # Dither Enabled
        self.dither_enable[dac_number] = self.dev.read_Zynq_register_uint16(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_dither_enable[dac_number]))
        # Auto Dither Enabled
        self.dither_mode_auto[dac_number] = self.dev.read_Zynq_register_uint16(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_dither_mode_auto[dac_number]))

        modulation_period = int((self.modulation_period_divided_by_4_minus_one[dac_number]+1)*4)
        N_periods = int(self.N_periods_integration_minus_one[dac_number]+1)
        amplitude = int(self.dither_amplitude[dac_number])


        return (modulation_period, N_periods, amplitude, self.dither_enable[dac_number], self.dither_mode_auto[dac_number])

    def ditherRead(self, N_samples, dac_number=0):
        if self.bVerbose == True:
            print('ditherRead')

        # Read N samples from the dither lock-in
        samples = np.zeros(N_samples, dtype=np.complexfloating)

        if dac_number == 0:
            BASE_ADDR_REAL_LSB = self.dev.BUS_ADDR_DITHER0_LOCKIN_REAL_LSB
            BASE_ADDR_REAL_MSB = self.dev.BUS_ADDR_DITHER0_LOCKIN_REAL_MSB
        elif dac_number == 1:
            BASE_ADDR_REAL_LSB = self.dev.BUS_ADDR_DITHER1_LOCKIN_REAL_LSB
            BASE_ADDR_REAL_MSB = self.dev.BUS_ADDR_DITHER1_LOCKIN_REAL_MSB
        elif dac_number == 2:
            # there is no DAC2 anymore
            return samples

        # print 'ditherRead------------'
        for k in range(N_samples):
            samples[k] = self.dev.read_Zynq_register_int64(
                    self.dev.dpll_write_address(BASE_ADDR_REAL_LSB), # use the write address for legacy "Opal Kelly" I/O
                    self.dev.dpll_write_address(BASE_ADDR_REAL_MSB))
        return samples

    ###########################################################################
    #--- Vector Network Analyzer (VNA):
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # VNA Helper Functions:
    #

    def compute_integration_time_for_syst_ident(self, System_settling_time, first_modulation_frequency_in_hz):
        ''' Compute the time needed to complete the requested vector network
        analysis (VNA)

        There are four constraints on this value:
            - First of all, the output rate of the block depends on this value
            so it has to be kept under some limit (one block of data every
            ~20 clock cycles)
            - The second is the settling time of the impulse response of the
            system to be identified
            - The third is that we need to integrate long enough to reject the
            tone at twice the modulation frequency (after the multiplier)
            - The fourth is the overall SNR, which depends on the modulation
            amplitude and how much noise there is already on the system output.
            This last one is easy to handle; the measured transfer function
            will be very noisy if we don't integrate long enough
        '''
        #
        return int(max((20,
                        System_settling_time*self.dev.ADC_CLK_Hz,
                        1/(first_modulation_frequency_in_hz)*self.dev.ADC_CLK_Hz)))

    def get_system_identification_wait_time(self):
        if self.bVerbose == True:
            print('get_system_identification_wait_time')
        return 1.1*2*self.number_of_cycles_integration*self.number_of_frequencies/self.dev.ADC_CLK_Hz

    def wait_for_system_identification(self):
        if self.bVerbose == True:
            print('wait_for_system_identification')
#        print(1.1*2*self.number_of_cycles_integration*self.number_of_frequencies/self.ADC_CLK_Hz)
        time.sleep(self.get_system_identification_wait_time())

    #--------------------------------------------------------------------------
    # Read/Write VNA Parameters
    #

    def setup_system_identification(self, input_select,
                                    output_select,
                                    first_modulation_frequency_in_hz,
                                    last_modulation_frequency_in_hz,
                                    number_of_frequencies,
                                    System_settling_time,
                                    output_amplitude,
                                    bDither=False):
        ''' Setup the requested vector network analysis (VNA).

        Input Select
        Bit 1 and 0 select between one of the four inputs, in that order:
        ADCraw0
        ADCraw1
        DDC_inst_freq0
        DDC_inst_freq1

        Output Select
        Bit 2 and 3 selects between one of the two ouputs, in that order:
        DAC 0
        DAC 1
        DAC 2
        DAC 2
        '''
        if self.bVerbose == True:
            print('setup_system_identification')
        if self.bCommunicationLogging == True:
            self.log_file.write('setup_system_identification(), ...\n')
#        print('Setting up system identification variables...')
        self.System_settling_time = System_settling_time
        self.first_modulation_frequency_in_hz = first_modulation_frequency_in_hz
        self.last_modulation_frequency_in_hz = last_modulation_frequency_in_hz
        self.number_of_frequencies = number_of_frequencies

        # Num_samples computed below has to be a multiple of 64.  We back out how many frequencies we need to ask from this.
        print('number of frequencies before = %d' % self.number_of_frequencies)
        num_samples_desired = self.number_of_frequencies*(2*64+32)/16
#        num_samples_desired = int(round(num_samples_desired/64)*64) # enforces a multiple of 64. this was only necessary with the Opal Kelly interface
        self.number_of_frequencies = int(num_samples_desired*16/(2*64+32))
        if self.number_of_frequencies == 0:
            self.number_of_frequencies = 1
        print('number of frequencies after = %d' % self.number_of_frequencies)
#        self.number_of_frequencies = int(np.floor(self.number_of_frequencies/8)*8)    # Must be a multiple of eight to keep the data on DDR2 burst boundaries

        self.modulation_frequency_step_in_hz = (
                self.last_modulation_frequency_in_hz
                -self.first_modulation_frequency_in_hz) / self.number_of_frequencies;
        self.first_modulation_frequency = int(2**self.dev.VNA_DDS_PHASE_ACCUM_N_BITS * self.first_modulation_frequency_in_hz/self.dev.ADC_CLK_Hz)
        self.modulation_frequency_step = int(2**self.dev.VNA_DDS_PHASE_ACCUM_N_BITS * self.modulation_frequency_step_in_hz/self.dev.ADC_CLK_Hz)
        self.number_of_cycles_integration = self.compute_integration_time_for_syst_ident(self.System_settling_time, self.first_modulation_frequency_in_hz)
        self.output_gain = int(output_amplitude)
        self.input_and_output_mux_selector = (
                self.set_bits(input_select, 0, bit_length=2)
                +self.set_bits(output_select, 2, bit_length=2))
        # Write Values to FPGA
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_number_of_cycles_integration),
                self.number_of_cycles_integration)
        self.dev.write_Zynq_register_uint64(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_first_modulation_frequency_lsbs),
                self.dev.dpll_write_address(self.dev.BUS_ADDR_first_modulation_frequency_msbs),
                self.first_modulation_frequency)
        self.dev.write_Zynq_register_uint64(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_modulation_frequency_step_lsbs),
                self.dev.dpll_write_address(self.dev.BUS_ADDR_modulation_frequency_step_msbs),
                self.modulation_frequency_step)
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_number_of_frequencies),
                self.number_of_frequencies)
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_output_gain),
                self.output_gain)
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_input_and_output_mux_selector),
                self.input_and_output_mux_selector)

        # If we are setting up settings for a system identification, we need to stop the dither:
        if bDither == False:
            self.setVNA_mode_register(0, 1, 0)   # Set no dither, stop any dither, and sine wave output
        # This makes sure that the output mode is 'sine wave' rather than 'square wave'
        self.setVNA_mode_register(0, 0, 0)   # Set no dither, no stop, and sine wave output

        # Need to also setup the write for enough samples that the VNA will put out:
        # This needs to be done last, so that the next call to trigger_write(self) works correctly.
        Num_samples = self.number_of_frequencies*(2*64+32)/16 #TODO: figure out what these numbers are
        print('setup_system_identification(): Num_samples = %d' % Num_samples)
        print('Num_samples = %d' % Num_samples)
#        print('self.number_of_frequencies = %d' % self.number_of_frequencies)
        self.setup_write(self.dev.SELECT_VNA, Num_samples)

    def setVNA_mode_register(self, trigger_dither, stop_flag, bSquareWave):
        if self.bVerbose == True:
            print('setVNA_mode_register')

        register_value = (
                self.set_bits(stop_flag, 0)
                + self.set_bits(trigger_dither, 1)
                + self.set_bits(bSquareWave, 2))
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_VNA_mode_control),
                register_value)

    def trigger_system_identification(self):
        ''' Trigger the start of the vector network analyzer.'''
        if self.bVerbose == True:
            print('trigger_system_identification')
        if self.bCommunicationLogging == True:
            self.log_file.write('trigger_system_identification()\n')
        # Start writing data to the DDR2 RAM:
        # self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_CMD_STROBE)
        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_TRIG_WRITE, 0) # not in dpll_wrapper address space
        # Start the system identification process:
        # self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_SYSTEM_IDENTIFICATION)
        self.dev.write_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION),
                0)

    ###########################################################################
    #--- Primary DAC Outputs:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Read/Write Primary DAC Output Settings:
    #

    def set_dac_offset(self, dac_number, offset_int):
        if self.bVerbose == True:
            print('set_dac_offset')
        if self.bCommunicationLogging == True:
            self.log_file.write('set_dac_offset()\n')
        self.DACs_offset[dac_number] = offset_int
        self.dev.write_Zynq_register_int16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_DAC_offset[dac_number]),
                offset_int)

    def get_dac_offset(self, dac_number):
        if self.bVerbose == True:
            print('get_dac_offset')
        offset_int = self.dev.read_Zynq_register_int16(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_DAC_offset[dac_number]))
        self.DACs_offset[dac_number] = offset_int
        return offset_int

    def set_dac_limits(self, dac_number, limit_low_int, limit_high_int, bSendToFPGA = True):
        assert isinstance(limit_low_int, int)
        assert isinstance(limit_high_int, int)

        if self.bVerbose == True:
            print('set_dac_limits')

        if self.bCommunicationLogging == True:
            self.log_file.write('set_dac_limits()\n')

        if dac_number == 0:
            # Clamp the value to the actual DAC limits:
            if limit_high_int > self.dev.DAC_LIM_HIGH_INT[0]:
                limit_high_int = self.dev.DAC_LIM_HIGH_INT[0]
            if limit_low_int < self.dev.DAC_LIM_LOW_INT[0]:
                limit_low_int = self.dev.DAC_LIM_LOW_INT[0]
            #print('dac = %d, low = %d, high = %d' % (dac_number, limit_low, limit_high))
            self.dev.write_Zynq_register_2x_int16(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_dac0_limits),
                    limit_low_int,
                    limit_high_int)
        if dac_number == 1:
            # Clamp the value to the actual DAC limits:
            if limit_high_int > self.dev.DAC_LIM_HIGH_INT[1]:
                limit_high_int = self.dev.DAC_LIM_HIGH_INT[1]
            if limit_low_int < self.dev.DAC_LIM_LOW_INT[1]:
                limit_low_int = self.dev.DAC_LIM_LOW_INT[1]
            #print('dac = %d, low = %d, high = %d' % (dac_number, limit_low, limit_high))
            self.dev.write_Zynq_register_2x_int16(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_dac1_limits),
                    limit_low_int,
                    limit_high_int)
        if dac_number == 2:
            # Clamp the value to the actual DAC limits:
            if limit_high_int > self.dev.DAC_LIM_HIGH_INT[2]:
                limit_high_int = self.dev.DAC_LIM_HIGH_INT[2]
            if limit_low_int < self.dev.DAC_LIM_LOW_INT[2]:
                limit_low_int = self.dev.DAC_LIM_LOW_INT[2]
            self.dev.write_Zynq_register_int32(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_dac2_limit_low),
                    limit_low_int)
            self.dev.write_Zynq_register_int32(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_dac2_limit_high),
                    limit_high_int)

        self.DACs_limit_low[dac_number] = limit_low_int
        self.DACs_limit_high[dac_number] = limit_high_int

    def get_dac_limits(self, dac_number):
        if self.bVerbose == True:
            print('get_dac_limits')
        if self.bCommunicationLogging == True:
            self.log_file.write('get_dac_limits()\n')

        if dac_number == 0:
            (limit_low, limit_high) = self.dev.read_Zynq_register_2x_int16(
                    self.dev.dpll_read_address(self.dev.BUS_ADDR_dac0_limits))
        elif dac_number == 1:
            (limit_low, limit_high) = self.dev.read_Zynq_register_2x_int16(
                    self.dev.dpll_read_address(self.dev.BUS_ADDR_dac1_limits))
        elif dac_number == 2:
            limit_low  = self.dev.read_Zynq_register_int32(
                    self.dev.dpll_read_address(self.dev.BUS_ADDR_dac2_limit_low))
            limit_high = self.dev.read_Zynq_register_int32(
                    self.dev.dpll_read_address(self.dev.BUS_ADDR_dac2_limit_high))

        self.DACs_limit_low[dac_number] = limit_low
        self.DACs_limit_high[dac_number] = limit_high

    ###########################################################################
    #--- Pulse Width Managed (PWM) DAC Outputs:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # PWM DAC Output Helper Functions:
    #

    def convertPWMCountsToVolts(self, standard, levels, counts):
        return np.float(standard)*np.float(counts)/np.float(levels)

    def convertPWMVoltsToCounts(self, standard, levels, volts):
        return int(np.round(np.float(levels)*np.float(volts)/np.float(standard)))

    #--------------------------------------------------------------------------
    # Read/Write PWM DAC Output Parameters:
    #

    def set_pwm_settings(self, levels, value, bSendToFPGA = True):
        if self.bVerbose == True:
            print('set_pwm_settings')
        value = int(round(value))
        # Clamp value
        if value > levels:
            value = levels
        if value < 0:
            value = 0
        # Send to FPGA
        if bSendToFPGA == True:
            self.dev.write_Zynq_register_uint32(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_PWM0),
                    value)

    ###########################################################################
    #--- Frequency Counters:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Frequency Counters Helper Functions:
    #

    def scaleCounterReadingsIntoHz(self, freq_counter_samples):
        if self.bVerbose == True:
            print('scaleCounterReadingsIntoHz')

        # Scale the counter values into Hz units:
        # f = data_out * fs / 2^N_INPUT_BITS / conversion_gain
        N_INPUT_BITS = self.dev.DDC_FREQ_N_BITS
        if self.bTriangularAveraging:
            conversion_gain = self.dev.COUNTER_GATE_TIME_N_CYCLES * (self.dev.COUNTER_GATE_TIME_N_CYCLES + 1)
        else:
            # Rectangular averaging:
            conversion_gain = self.dev.COUNTER_GATE_TIME_N_CYCLES
        freq_counter_samples = freq_counter_samples * self.dev.ADC_CLK_Hz / 2**(N_INPUT_BITS) / conversion_gain
        return freq_counter_samples

    def new_freq_setting(self):
        '''Used for testing the frequency counter transfer function with
        the VNA.
        '''
        # Check if dither is set, then call
        self.new_freq_setting_number = self.new_freq_setting_number + 1
        modulation_frequency_in_hz = ((self.new_freq_setting_number-1)/2) * 0.05 + 0.025 #TODO: what are these numbers?

        output_select = 0
        bSquareWave = False
        # half the time we turn the modulation on, half the time we turn it off
        if self.new_freq_setting_number % 2 == 0:
            bEnableDither = True
        else:
            bEnableDither = False
        output_amplitude = int(float(self.DACs_limit_high[output_select] - self.DACs_limit_low[output_select])*float(0.01)/2)

        # This is only really to set the dither
        # we don't care about these values:
        input_select = 0
        number_of_frequencies = 8
        System_settling_time = 1e-3
        self.setup_system_identification(input_select, output_select, modulation_frequency_in_hz, modulation_frequency_in_hz, number_of_frequencies, System_settling_time, output_amplitude, 0)

        print('new_freq_setting: (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither) = %d, %f, %f, %d, %d' % (output_select, modulation_frequency_in_hz, output_amplitude, bSquareWave, bEnableDither))

        trigger_dither = bEnableDither
        if bEnableDither == False:
            stop_flag = 1
        else:
            stop_flag = 0
        self.setVNA_mode_register(trigger_dither, stop_flag, bSquareWave)
        print('(trigger_dither, stop_flag, bSquareWave) = %d, %d, %d' % (trigger_dither, stop_flag, bSquareWave))

    #--------------------------------------------------------------------------
    # Read/Write Frequency Counter Parameters:
    #

    def setCounterMode(self, bTriangular):
        assert isinstance(bTriangular, int)
        if self.bVerbose == True:
            print('setCounterMode')
        # bTriangular = 1 means triangular averaging, bTriangular = 0 means rectangular averaging
        self.dev.write_Zynq_register_uint16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_triangular_averaging),
                bTriangular)
        self.bTriangularAveraging = bTriangular

    def getCounterMode(self):
        if self.bVerbose == True:
            print('getCounterMode')
        self.bTriangularAveraging = self.dev.read_Zynq_register_uint16(
                self.dev.dpll_read_address(self.dev.BUS_ADDR_triangular_averaging))
        return self.bTriangularAveraging

    def read_dual_mode_counter(self, output_number):
        # fetch data
        # reading at this address samples all frequency counter data at the same time (see registers_read.vhd for details)
        zdtc_samples_number_counter = self.dev.read_Zynq_register_uint32(self.dev.BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER*4)
        increments = zdtc_samples_number_counter - self.last_zdtc_samples_number_counter[output_number]
        if increments != 0:
            # # this is used only for internal testing of the frequency counter's transfer function
            # if output_number == 0:
            #     if zdtc_samples_number_counter-self.last_freq_update == 50 or self.last_freq_update == 0:
            #         self.new_freq_setting()
            #         self.last_freq_update = zdtc_samples_number_counter
            # we have new unread samples
            freq_counter0_sample = self.dev.read_Zynq_register_int64(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS), # use write address, legacy "Opal Kelly" I/O
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS))
            freq_counter1_sample = self.dev.read_Zynq_register_int64(
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS), # use write address, legacy "Opal Kelly" I/O
                    self.dev.dpll_write_address(self.dev.BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS))
            # print("zdtc_samples_number_counter = %d, was %d, read new values" % (zdtc_samples_number_counter, self.last_zdtc_samples_number_counter[output_number]))
            if increments>1 and self.last_zdtc_samples_number_counter[output_number] != 0:
                print("Warning, %d counter sample(s) dropped on counter #%d" % (zdtc_samples_number_counter-self.last_zdtc_samples_number_counter[output_number]-1, output_number))
        else:
            # we have already read all the counter samples for this output
            freq_counter0_sample = None
            freq_counter1_sample = None
            # print("zdtc_samples_number_counter = %d, was %d, didn't read values" % (zdtc_samples_number_counter, self.last_zdtc_samples_number_counter[output_number]))
        self.last_zdtc_samples_number_counter[output_number] = zdtc_samples_number_counter

        dac0_samples = self.dev.read_Zynq_register_int16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_DAC0_CURRENT)) # use write address, legacy "Opal Kelly" I/O
        dac1_samples = self.dev.read_Zynq_register_int16(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_DAC1_CURRENT)) # use write address, legacy "Opal Kelly" I/O

        # convert to numpy format:
        dac0_samples = np.array((dac0_samples,))
        dac1_samples = np.array((dac1_samples,))
        dac2_samples = np.array((0,))

        # scale to physical units
        if freq_counter0_sample is not None:
            freq_counter0_sample = self.scaleCounterReadingsIntoHz(freq_counter0_sample)
        if freq_counter1_sample is not None:
            freq_counter1_sample = self.scaleCounterReadingsIntoHz(freq_counter1_sample)

        time_axis = None # not currently used anymore
        if output_number == 0:
            return (freq_counter0_sample, time_axis, dac0_samples, dac1_samples, dac2_samples)
        elif output_number == 1:
            return (freq_counter1_sample, time_axis, dac0_samples, dac1_samples, dac2_samples)

    ###########################################################################
    #--- Data Logger:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Data Logger Helper Functions:
    #

    def wait_for_write(self):
        if self.bVerbose == True:
            print('wait_for_write')
        # Wait, seems necessary because setting the DDR2Logger to 'read' mode overrides the 'write' mode
        write_delay = 1.1*1024*(int(self.Num_samples_write/1024) + 1)/(self.dev.ADC_CLK_Hz/2)
#        print('Waiting for the DDR to fill up... (%f secs)' % ((write_delay)))
        time.sleep(write_delay)
#        print('Done!')

    #--------------------------------------------------------------------------
    # Read/Write Data Logger Parameters:
    #

    def setup_write(self, selector, Num_samples):
        if self.bVerbose == True:
            print('setup_write')
        if self.bCommunicationLogging == True:
            self.log_file.write('setup_write(), selector = {}, Num_samples = {}\n'.format(selector, Num_samples))
        self.Num_samples_write = int(Num_samples)  # no such restriction with the Red Pitaya implementation
        self.Num_samples_read = self.Num_samples_write

        # Select which data bus to put in the RAM:
        self.last_selector = selector
        self.dev.SetWireInValue(self.dev.BUS_ADDR_MUX_SELECTORS, self.last_selector)


    def setup_ADC0_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_ADC0_write')
        self.setup_write(self.dev.SELECT_ADC0, Num_samples)

    def setup_ADC1_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_ADC1_write')
        self.setup_write(self.dev.SELECT_ADC1, Num_samples)

    def setup_DDC0_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_DDC0_write')
        self.setup_write(self.dev.SELECT_DDC0, Num_samples)

    def setup_DDC1_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_DDC1_write')
        self.setup_write(self.dev.SELECT_DDC1, Num_samples)

    def setup_counter_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_counter_write')
        self.setup_write(self.dev.SELECT_COUNTER, Num_samples)

    def setup_DAC0_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_DAC0_write')
        self.setup_write(self.dev.SELECT_DAC0, Num_samples)

    def setup_DAC1_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_DAC1_write')
        self.setup_write(self.dev.SELECT_DAC1, Num_samples)

    def setup_DAC2_write(self, Num_samples):
        if self.bVerbose == True:
            print('setup_DAC2_write')
        self.setup_write(self.dev.SELECT_DAC2, Num_samples)

    def trigger_write(self):
        ''' Trigger writing to the data logger.'''
        if self.bVerbose == True:
            print('trigger_write')

        if self.bCommunicationLogging == True:
            self.log_file.write('trigger_write()\n')
        # Start writing data to the BRAM:
        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_TRIG_WRITE, 0) # address outside of "dpll_wrapper"
        #self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_CMD_STROBE)

    def read_raw_bytes_from_DDR2(self):
        if self.bVerbose == True:
            print('read_raw_bytes_from_DDR2')

        if self.bCommunicationLogging == True:
            self.log_file.write('read_raw_bytes_from_DDR2()\n')

        bytes_per_sample = 2
        Num_bytes_read = self.Num_samples_read*bytes_per_sample

        data_buffer = self.dev.read_Zynq_buffer_16(self.Num_samples_read)

        if Num_bytes_read != len(data_buffer):
            print('Error: did not receive the expected number of bytes. expected: %d, Received: %d' % (Num_bytes_read, len(data_buffer)))

        return data_buffer

    def read_adc_samples_from_DDR2(self):
        if self.bVerbose == True:
            print('read_adc_samples_from_DDR2')

        if self.bCommunicationLogging == True:
            self.log_file.write('read_adc_samples_from_DDR2()\n')

        data_buffer = self.read_raw_bytes_from_DDR2()
        samples_out = np.frombuffer(data_buffer, dtype=np.int16)
        if len(samples_out) == 0:
            ref_exp = np.array([1.0,])
            return (samples_out, ref_exp)

        # There is one additional thing we need to take care:
        # Samples #4 and 5 (counting from 0) contain the DDC reference exponential for this data packet:
        ref_exp_expected_position = 6
        magic_bytes_expected_position = ref_exp_expected_position+2
        ref_exp = samples_out[ref_exp_expected_position].astype(np.float) + 1j * samples_out[ref_exp_expected_position+1].astype(np.float)
        # ref_exp is the reference phasor at sample #4, we need to extrapolate it to the first correct output sample (#6, or two samples later)

        if self.last_selector ==  0 or self.last_selector == 1:
            # We have placed two magic bytes in sample 7, so that we can detect loss of synchronization on that data stream:
            magic_bytes = int('1010100010001111', 2) # from aux_data_mux.vhd: 1010_1000_1000_1111
            # magic_bytes is interpreted by python as an unsigned uint16, while samples_out[7] is interpreted as a signed int16
            N_bits = 16
            mask_negative_bit = (1<<(N_bits-1))
            mask_other_bits = mask_negative_bit-1
            magic_bytes = (magic_bytes & mask_other_bits) - (magic_bytes & mask_negative_bit)

            if samples_out[magic_bytes_expected_position] != magic_bytes:
                print('Comms bug! Sorry about that.')
                print('Loss of synchronization detected on Pipe 0xA1:')
                print('Original read length: %d' % self.Num_samples_read)
                actual_position = magic_bytes_expected_position
                for iter in range(len(samples_out)):
                    if samples_out[iter] == magic_bytes:
                        actual_position = iter
                        print('magic bytes found at position %d' % actual_position)
                        break
                print('magic bytes (hex) = 0x%x, samples_out[magic_bytes_expected_position] (hex) = 0x%x' % (magic_bytes, samples_out[magic_bytes_expected_position]))
                print('magic bytes (dec) = %d, samples_out[magic_bytes_expected_position] (dec) = %d' % (magic_bytes, samples_out[magic_bytes_expected_position]))
        # Here we need to know if this was ADC 0 or 1, so that we use the correct DDC reference frequency to extrapolate the phase:
        N_delay_between_ref_exp_and_datastream = 4
        if self.last_selector == 0:
            # ADC 0
            ref_exp = ref_exp * np.exp(-1j*2*np.pi*N_delay_between_ref_exp_and_datastream*(float(self.ddc0_int_phase_incr)/float(2**48)))
            # Strip off the samples that were used to pass side information
            samples_out = samples_out[magic_bytes_expected_position+1:]
        elif self.last_selector == 1:
            # ADC 1
            ref_exp = ref_exp * np.exp(-1j*2*np.pi*N_delay_between_ref_exp_and_datastream*(float(self.ddc1_int_phase_incr)/float(2**48)))
            # Strip off the samples that were used to pass side information
            samples_out = samples_out[magic_bytes_expected_position+1:]
        else:
            # Other (DAC0, DAC1 or DAC2): there is no ref exp in the samples
            ref_exp = 1
            samples_out = samples_out
        # Now ref_exp contains the reference phasor, aligned with the first sample that this function will return

        return (samples_out, ref_exp)

    def read_dac_samples_from_DDR2(self):
        if self.bVerbose == True:
            print('read_dac_samples_from_DDR2')
        if self.bCommunicationLogging == True:
            self.log_file.write('read_ddc_samples_from_DDR2()\n')
        data_buffer = self.read_raw_bytes_from_DDR2()
        samples_out = np.frombuffer(data_buffer, dtype=np.int16)
        return samples_out

    def read_ddc_samples_from_DDR2(self):
        if self.bVerbose == True:
            print('read_ddc_samples_from_DDR2')

        if self.bCommunicationLogging == True:
            self.log_file.write('read_ddc_samples_from_DDR2()\n')
        data_buffer = self.read_raw_bytes_from_DDR2()
        samples_out = np.frombuffer(data_buffer, dtype=np.int16)
        # The samples represent instantaneous frequency as: samples_out = diff(phi)/(2*pi*fs) * 2**12, where phi is the phase in radians
        inst_freq = (samples_out.astype(dtype=float)) * self.dev.DDC_FREQ_INT
        # print('Mean frequency error = %f Hz' % np.mean(inst_freq))
        return inst_freq

    def read_counter_samples_from_DDR2(self):
        if self.bVerbose == True:
            print('read_counter_samples_from_DDR2')

        if self.bCommunicationLogging == True:
            self.log_file.write('read_counter_samples_from_DDR2()\n')
        data_buffer = self.read_raw_bytes_from_DDR2()
        # convert to numpy array
        data_buffer = np.fromstring(data_buffer, dtype=np.uint8)

        bytes_per_sample = 2
        data_buffer_reshaped = np.reshape(data_buffer, (-1, bytes_per_sample))
        convert_4bytes_unsigned = np.array((2**(2*8), 2**(3*8), 2**(0*8), 2**(1*8)))
        convert_2bytes_signed = np.array((2**(0*8), 2**(1*8)), dtype=np.int16)
        samples_out         = np.dot(data_buffer_reshaped[:, :].astype(np.int16), convert_2bytes_signed)

        return samples_out

    def read_VNA_samples_from_DDR2(self):
        if self.bVerbose == True:
            print('read_VNA_samples_from_DDR2')

        if self.bCommunicationLogging == True:
            self.log_file.write('read_VNA_samples_from_DDR2()\n')
        data_buffer = self.read_raw_bytes_from_DDR2()
        # convert to numpy array
        data_buffer = np.fromstring(data_buffer, dtype=np.uint8)
        # Interpret the samples as coming form the system identification VNA:
        # In this format, the DDR contains:
        # INTEGRATOR_REALPART_BITS15_TO_0
        # INTEGRATOR_REALPART_BITS31_TO_16
        # INTEGRATOR_REALPART_BITS47_TO_32
        # INTEGRATOR_REALPART_BITS63_TO_48
        # INTEGRATOR_IMAGPART_BITS15_TO_0
        # INTEGRATOR_IMAGPART_BITS31_TO_16
        # INTEGRATOR_IMAGPART_BITS47_TO_32
        # INTEGRATOR_IMAGPART_BITS63_TO_48
        # INTEGRATION_TIME_BITS15_TO_0
        # INTEGRATION_TIME_BITS31_TO_16
        # Thus each tested frequency will produce 2*64+32 bits (16 bytes).
        bytes_per_frequency_vna = int((2*64+32)/8);
        #repr_vna_all = np.reshape(rep, (-1, bytes_per_frequency_vna))    # note that this gives number_of_frequencies samples
        print('self.number_of_frequencies = %d' % (self.number_of_frequencies))
        print('bytes_per_frequency_vna = %d' % (bytes_per_frequency_vna))
        print('len = %d' % (len(data_buffer)))
        if len(data_buffer) < (self.number_of_frequencies)*bytes_per_frequency_vna:
            # we don't have enough bytes for the whole array. only use the number of frequencies that will fit:
            actual_number_of_frequencies = int(np.floor(len(data_buffer)/bytes_per_frequency_vna))
            self.number_of_frequencies = actual_number_of_frequencies

        vna_raw_data = np.reshape(data_buffer[0:(self.number_of_frequencies)*bytes_per_frequency_vna], (self.number_of_frequencies, bytes_per_frequency_vna))    # note that this gives number_of_frequencies samples
        print(vna_raw_data)

        vna_real = vna_raw_data[:, 0:8]
        vna_imag = vna_raw_data[:, 8:16]
        vna_integration_time = vna_raw_data[:, 16:20]

        # collapse the 8 bytes into 64-bits signed values:
        # I am not sure whether this does the correct job with negative or very large values:
        convert_8bytes_signed = np.array(range(8), dtype=np.int64)
        convert_8bytes_signed = 2**(8*convert_8bytes_signed)
        integrator_real         = np.dot(vna_real[:, :].astype(np.int64), convert_8bytes_signed)
        integrator_imag         = np.dot(vna_imag[:, :].astype(np.int64), convert_8bytes_signed)

        convert_4bytes_unsigned = np.array(range(4), dtype=np.uint32)
        convert_4bytes_unsigned = 2**(8*convert_4bytes_unsigned)
        integration_time         = np.dot(vna_integration_time[:, :].astype(np.uint32), convert_4bytes_unsigned)

        # The frequency axis can be constructed from knowledge of
        # fs
        # first_modulation_frequency
        # modulation_frequency_step
        # number_of_frequencies
        frequency_axis = (self.first_modulation_frequency + self.modulation_frequency_step * np.array(range(self.number_of_frequencies), dtype=np.uint64)).astype(np.float64)/2**48*self.dev.ADC_CLK_Hz

        # While the overall gain is:
        # That is, a pure loop-back system from the output of the VNA to the input will
        #  give a modulus equal to overall_gain.
        overall_gain = np.array(2.**(15-1) * self.output_gain * float((self.number_of_cycles_integration)), dtype=np.float) # the additionnal divide by two is because cos(x) = 1/2*exp(jx)+1/2*exp(-jx)
        overall_gain = 2.**(15-1) * self.output_gain * integration_time.astype(np.float) # the additionnal divide by two is because cos(x) = 1/2*exp(jx)+1/2*exp(-jx)
#        print(self.number_of_cycles_integration)
#        overall_gain = 1
#        print('TODO: Remove this line! overallgain = 1')
        transfer_function_real = (integrator_real.astype(np.float)) / (overall_gain)
        transfer_function_imag = (integrator_imag.astype(np.float)) / (overall_gain)
        transfer_function_complex = transfer_function_real + 1j * transfer_function_imag
#        phi = np.angle(transfer_function_real + 1j*transfer_function_imag)
#        group_delay = ((-np.diff(phi)+np.pi) % (2*np.pi))-np.pi
#        group_delay = group_delay / np.diff(frequency_axis)/2.0/np.pi

        return (transfer_function_complex, frequency_axis)

    ###########################################################################
    #--- LEDs and Status Flags:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # LEDs and Status Flags Helper Functions:
    #

    def extractBit(self, value, N_bit):
        if self.bVerbose == True:
            print('extractBit')

        single_bit = (value >> N_bit) % 2
        return single_bit

    #--------------------------------------------------------------------------
    # Read/Write LEDs and Status Flags Parameters:
    #

    def readLEDs(self):
        if self.bVerbose == True:
            print('readLEDs')

        # We first need to check if the fifo has enough samples to send us:
        # status_flags = self.dev.GetWireOutValue(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
        status_flags = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_STATUS_FLAGS)) # use write address, legacy "Opal Kelly" I/O
        # print(status_flags)

        LED_G0        = self.extractBit(status_flags, 4)
        LED_R0        = self.extractBit(status_flags, 5)

        LED_G1        = self.extractBit(status_flags, 6)
        LED_R1        = self.extractBit(status_flags, 7)

        LED_G2        = self.extractBit(status_flags, 8)
        LED_R2        = self.extractBit(status_flags, 9)

        return (LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2)

    def readStatusFlags(self):
        if self.bVerbose == True:
            print('readStatusFlags')

        # We first need to check if the fifo has enough samples to send us:

        # status_flags = self.dev.GetWireOutValue(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
        status_flags = self.dev.read_Zynq_register_uint32(
                self.dev.dpll_write_address(self.dev.BUS_ADDR_STATUS_FLAGS)) # use write address, legacy "Opal Kelly" I/O
#        print(status_flags)
        output0_has_data        = (self.extractBit(status_flags, 0) == 0)
        output1_has_data        = (self.extractBit(status_flags, 1) == 0)
        PipeA1FifoEmpty         = self.extractBit(status_flags, 2)
        crash_monitor_has_data  = self.extractBit(status_flags, 3)

#        output0_has_data = ((status_flags & (1 << 0)) >> 0 == 0)
#        output1_has_data = ((status_flags & (1 << 1)) >> 1 == 0)
#        PipeA1FifoEmpty  = ((status_flags & (1 << 2)) >> 2 == 1)
#        PipeA1FifoEmpty  = ((status_flags & (1 << 2)) >> 2 == 1)

        return (output0_has_data, output1_has_data, PipeA1FifoEmpty, crash_monitor_has_data)

    ###########################################################################
    #--- VCO Output:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Read/Write VCO Output Parameters:
    #

    def set_internal_VCO_offset(self, offset):
        '''Scales the offset of the output tone produced by the VCO right
        before the DAC.

        offset = [-1 to 1]

        '''
        if self.bVerbose == True:
            print('set_internal_VCO_offset')
        self.vco_offset_in_volt = offset
        vco_offset = round(offset*(2**13-1)) #13 bits, because offset is signed
        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_vco_offset, vco_offset) # address outside "dpll_wrapper"

    def get_internal_VCO_offset(self):
        if self.bVerbose == True:
            print('get_internal_VCO_offset')
        raw = self.dev.read_Zynq_register_uint32(self.dev.BUS_ADDR_vco_offset) # address outside "dpll_wrapper"
        if raw > ((1<<13)-1):
            raw = -(0b11111111111111-raw+1)     #Because the value is consider as an signed integer
        offset = raw/(2**13-1)
        self.vco_offset_in_volt = offset
        return offset

    def set_internal_VCO_amplitude(self, amplitude):
        ''' Scales the magnitude of the output tone produced by the VCO right
        before the DAC.

        amplitude = [0 to 1]
        amplitude = 1 means 1 V peak of output, or 2 Vpeak-peak.

        '''
        if self.bVerbose == True:
            print('set_internal_VCO_amplitude')
        self.vco_amplitude_in_volt = amplitude
        vco_amplitude = round(amplitude*(2**15-1)) #15 bits, because amplitude is signed
        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_vco_amplitude, vco_amplitude) # address outside "dpll_wrapper"

    def get_internal_VCO_amplitude(self):
        if self.bVerbose == True:
            print('get_internal_VCO_amplitude')
        raw = self.dev.read_Zynq_register_uint32(self.dev.BUS_ADDR_vco_amplitude) # address outside "dpll_wrapper"
        if raw > ((1<<15)-1):
            raw = -(0xFFFF-raw+1)     #Because the value is consider as an signed integer
        amplitude = raw/(2**15-1)
        self.vco_amplitude_in_volt = amplitude
        return amplitude

    def set_mux_vco(self, data):
        '''This mux selects the source of the VCO frequency and the output DAC
        to which the VCO is connected.

        register_value = 0 :
            the VCO is not connected (normal operation)
        register_value = 1 :
            the VCO is connected to the DAC0
        register_value = 2 :
            the VCO is connected to the DAC1

        '''
        if self.bVerbose == True:
            print('set_mux_vco')

        self.dev.write_Zynq_register_uint32(self.dev.BUS_ADDR_vco_mux, data) # address outside "dpll_wrapper"
        if data == 0 :
            self.output_vco = [0, 0, 0]
        elif data == 1:
            self.output_vco = [1, 0, 0]
        elif data == 2:
            self.output_vco = [0, 1, 0]

    def get_mux_vco(self):
        if self.bVerbose == True:
            print('get_mux_vco')
        mux_value = self.dev.read_Zynq_register_uint32(self.dev.BUS_ADDR_vco_mux) # address outside "dpll_wrapper"
        if mux_value == 0 :
            self.output_vco = [0, 0, 0]
        elif mux_value == 1:
            self.output_vco = [1, 0, 0]
        elif mux_value == 2:
            self.output_vco = [0, 1, 0]
        return mux_value

    ###########################################################################
    #--- Auxiliary System Components:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Read/Write Auxiliary System Component Parameters:

    def setFan(self, fanState):
        addr = 0x18
        bus_address = (3 << 20) + addr

        self.fanState = fanState

        if fanState:
            data = 0b11000000
        else:
            data = 0b00000000

        self.dev.write_Zynq_register_uint32(bus_address, data) # address outside "dpll_wrapper"
