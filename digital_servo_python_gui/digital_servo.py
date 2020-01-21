# -*- coding: utf-8 -*-
"""
#TODO: module docstring...
"""

import copy
import socket
import struct
import sys
import time
import threading

import numpy as np

from scipy.signal import lfilter



#%% Super Laser Land
###############################################################################

class SuperLaserLand:
    # super class wrapping up all of the control
    """
    self.dev

    self.loop_filter

    self.dac

    self.daq

    only 1 class for multiple "sub-devices", class methods must be told on
    which channel to operate.
    """
    def __init__(self):
        #----------------------------------------------------------------------
        # Initialize Device:
        #

        self.dev = RedPitayaDevice()

        #----------------------------------------------------------------------
        # Sub-Module Initialization:
        #

        self.loop_filter = LoopFilter(self.dev)
        self.dac = DigitalToAnalogConverter(self.dev)
        self.daq = DataAcquisition(self.dev)


#%% Red Pitaya Clases

class RedPitayaDevice:

    def __init__(self):
        self.sock = SocketPlaceholder()
        self.valid_socket = 0


    ###########################################################################
    #--- Red Pitaya System Commands:
    ###########################################################################
    #

    def open_TCP_connection(self, HOST, PORT=5000):
        print("RedPitayaDevice::open_TCP_connection(): HOST = '%s', PORT = %d" % (HOST, PORT))
        self.HOST = HOST
        self.PORT = PORT
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.sock.settimeout(2) # seconds
        self.sock.connect((self.HOST, self.PORT))
        self.valid_socket = 1

    def close_TCP_connection(self):
        print("RedPitayaDevice::close_TCP_connection()")
        try:
            self.sock.shutdown(socket.SHUT_RDWR)
            self.sock.close()
        except:
            pass
        self.sock = SocketPlaceholder()
        self.valid_socket = 0

    def restart_TCP_connection(self):
        self.close_TCP_connection()
        self.open_TCP_connection(self.HOST, self.PORT)

    # Function used to send a file write command:
    def write_file_on_remote(self, strFilenameLocal, strFilenameRemote):
        # open local file and load into memory:
        file_data = np.fromfile(strFilenameLocal, dtype=np.uint8)
        try:
            # send header
            packet_to_send = struct.pack('<III', MAGIC_BYTES_WRITE_FILE, len(strFilenameRemote), len(file_data))
            self.sock.sendall(packet_to_send)
            # send filename
            self.sock.sendall(strFilenameRemote.encode('ascii'))
            # send actual file
            self.sock.sendall(file_data.tobytes())
        except:
            print("RP_PLL.py: write_file_on_remote(): exception while sending file!")
            self.restart_TCP_connection()

    # Function used to send a shell command to the Red Pitaya:
    def send_shell_command(self, strCommand):

        try:
            # send header
            packet_to_send = struct.pack('<III', MAGIC_BYTES_SHELL_COMMAND, len(strCommand), 0)
            self.sock.sendall(packet_to_send)
            # send filename
            self.sock.sendall(strCommand.encode('ascii'))
        except:
            print("RP_PLL.py: send_shell_command(): exception while sending command!")
            self.restart_TCP_connection()

    # Function used to reboot the monitor-tcp program
    def send_reboot_command(self):

        try:
            # send header
            packet_to_send = struct.pack('<III', MAGIC_BYTES_REBOOT_MONITOR, 0, 0)
            self.sock.sendall(packet_to_send)
        except:
            print("RP_PLL.py: send_reboot_command(): exception while sending command!")
            self.restart_TCP_connection()

    ###########################################################################
    #--- Zynq I/O Helper Functions
    ###########################################################################
    #

    # from http://stupidpythonideas.blogspot.ca/2013/05/sockets-are-byte-streams-not-message.html
    def recvall(self, count):
        buf = b''
        while count:
            newbuf = self.sock.recv(count)
            if not newbuf: return None
            buf += newbuf
            count -= len(newbuf)
        return buf

    ###########################################################################
    #--- Write to Zynq Register:
    ###########################################################################
    #

    # Write 32 bit Zynq Register ----------------------------------------------
    def write_Zynq_register_32(self, address_uint32, data_buffer):
        # Check data buffer length and type
        if not isinstance(data_buffer, bytes):
            raise TypeError(('Data buffer type {:} is not an instance'
                             ' of bytes').format(type(data_buffer)))
        elif len(data_buffer) != 4:
            raise OSError(('Data buffer length {:} is not 32 bits. The'
                           ' transfer size of the implemented Zynq registers'
                           ' is 4 bytes.').format(len(data_buffer)))
        # Check address alignment
        if address_uint32 % 4:
            raise OSError(('Address {:X} is not evenly divisible by 4.'
                           ' The implemented Zynq registers have offsets'
                           ' aligned to 4 bytes').format(address_uint32))
        # Write 32 bits into the Zynq register
        try:
            packet_to_send = struct.pack(
                '<II',
                MAGIC_BYTES_WRITE_REG,
                RP_TOP_ADDR + address_uint32)
            packet_to_send = packet_to_send + data_buffer
            self.sock.sendall(packet_to_send)
        except:
            print("Unexpected error when writing Zynq register: ",
                  sys.exc_info()[0])
            self.restart_TCP_connection()

    # Write 2x Unsigned int16 Zynq Register -----------------------------------
    def write_Zynq_register_2x_uint16(self, address_uint32, data1_uint16, data2_uint16):
        '''2 16bit numbers can act as 1 32bit number with data1 the LSBs and
        data2 the MSBs'''
       # Parse two unsigned int16 (uint16) to buffer
        data_buffer = struct.pack('<HH', data1_uint16, data2_uint16)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32, data_buffer)

    # Write 2x Signed int16 Zynq Register -------------------------------------
    def write_Zynq_register_2x_int16(self, address_uint32, data1_int16, data2_int16):
        # Parse two signed int16 (int16) to buffer
        data_buffer = struct.pack('<hh', data1_int16, data2_int16)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32, data_buffer)

    # Write Unsigned int16 Zynq Register --------------------------------------
    def write_Zynq_register_uint16(self, address_uint32, data_uint16):
        '''Only keep the LSBs'''
        return self.write_Zynq_register_2x_uint16(address_uint32, data_uint16, 0)

    # Write Signed int16 Zynq Register ----------------------------------------
    def write_Zynq_register_int16(self, address_uint32, data_int16):
        '''Only keep the LSBs'''
        return self.write_Zynq_register_2x_int16(address_uint32, data_int16, 0)

    # Write Unsigned int32 Zynq Register --------------------------------------
    def write_Zynq_register_uint32(self, address_uint32, data_uint32):
        # Parse unsigned int32 (uint32) to buffer
        data_buffer = struct.pack('<I', data_uint32)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32, data_buffer)

    # Write Signed int32 Zynq Register ----------------------------------------
    def write_Zynq_register_int32(self, address_uint32, data_int32):
        # Parse signed int32 (int32) to buffer
        data_buffer = struct.pack('<i', data_int32)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32, data_buffer)

    # Write Single Precision binary32 Zynq Register ---------------------------
    def write_Zynq_register_float32(self, address_uint32, data_float32):
        # Parse single precision float (binary32) to buffer
        data_buffer = struct.pack('<f', data_float32)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32, data_buffer)

    # Write Unsigned int64 Zynq Register --------------------------------------
    def write_Zynq_register_uint64(self, address_uint32_lsb, address_uint32_msb, data_uint64):
        # Parse unsigned int64 (int64) to buffer
        data_buffer = struct.pack('<Q', data_uint64)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32_lsb, data_buffer[:4]) # LSBs
        self.write_Zynq_register_32(address_uint32_msb, data_buffer[4:]) # MSBs

    # Write Signed int64 Zynq Register ----------------------------------------
    def write_Zynq_register_int64(self, address_uint32_lsb, address_uint32_msb, data_int64):
        # Parse signed int64 (int64) to buffer
        data_buffer = struct.pack('<q', data_int64)
        # Write buffer into Zynq register
        self.write_Zynq_register_32(address_uint32_lsb, data_buffer[:4]) # LSBs
        self.write_Zynq_register_32(address_uint32_msb, data_buffer[4:]) # MSBs

    ###########################################################################
    #--- Read from Zynq Register:
    ###########################################################################
    #

    # Read 16 bit Zynq Buffer -------------------------------------------------
    def read_Zynq_buffer_16(self, number_of_points):
        '''Read from the DDR2 memory.

        Raw buffer can be read by struct.iter_unpack or np.frombuffer.
        '''
        data_buffer = None
        # Limit the number of 16 bit points
        if number_of_points > MAX_SAMPLES_READ_BUFFER:
            number_of_points = MAX_SAMPLES_READ_BUFFER
            print("number of points clamped to %d." % number_of_points)
        # Read stream of 16 bit data from the Zynq buffer
        try:
            packet_to_send = struct.pack(
                '<III',
                MAGIC_BYTES_READ_BUFFER,
                RP_TOP_ADDR,
                number_of_points)
            self.sock.sendall(packet_to_send)
            data_buffer = self.recvall(int(2*number_of_points)) # read number_of_points samples (16 bits each)
        except:
            print("Unexpected error when reading Zynq buffer: ",
                  sys.exc_info()[0])
            self.restart_TCP_connection()
        # Return unaltered data buffer
        if data_buffer is None:
            data_buffer = bytes()
        return data_buffer

    # Read 32 bit Zynq Register -----------------------------------------------
    def read_Zynq_register_32(self, address_uint32):
        data_buffer = None
        # Check address alignment
        if address_uint32 % 4:
            raise OSError(('Address {:X} is not evenly divisible by 4.'
                           ' The implemented Zynq registers have offsets'
                           ' aligned to 4 bytes').format(address_uint32))
        # Read 32 bits from the Zynq register
        try:
            packet_to_send = struct.pack(
                '<III',
                MAGIC_BYTES_READ_REG,
                RP_TOP_ADDR + address_uint32,
                0)  # last value is reserved
            self.sock.sendall(packet_to_send)
            data_buffer = self.recvall(4)   # read 4 bytes (32 bits)
        except:
            print("Unexpected error when reading Zynq register: ",
                  sys.exc_info()[0])
            self.restart_TCP_connection()
        # Return unaltered data buffer
        if data_buffer is None:
            data_buffer = (0).to_bytes(4, 'little')
        return data_buffer

    # Read 2x Unsigned int16 Zynq Register ------------------------------------
    def read_Zynq_register_2x_uint16(self, address_uint32):
        '''The LSBs are first'''
        # Read Zynq register into buffer
        data_buffer = self.read_Zynq_register_32(address_uint32)
        # Parse buffer to unsigned int16 (uint16)
        reg1_uint16, reg2_uint16 = struct.unpack('<HH', data_buffer)
        return (reg1_uint16, reg2_uint16)

    # Read 2x Signed int16 Zynq Register --------------------------------------
    def read_Zynq_register_2x_int16(self, address_uint32):
        '''The LSBs are first'''
        # Read Zynq register into buffer
        data_buffer = self.read_Zynq_register_32(address_uint32)
        # Parse buffer to signed int16 (int16)
        reg1_int16, reg2_int16 = struct.unpack('<hh', data_buffer)
        return (reg1_int16, reg2_int16)

    # Read Unsigned int16 Zynq Register ---------------------------------------
    def read_Zynq_register_uint16(self, address_uint32):
        '''Only keep the LSBs'''
        return self.read_Zynq_register_2x_uint16(address_uint32)[0]

    # Read Signed int16 Zynq Register -----------------------------------------
    def read_Zynq_register_int16(self, address_uint32):
        '''Only keep the LSBs'''
        return self.read_Zynq_register_2x_int16(address_uint32)[0]

    # Read Unsigned int32 Zynq Register ---------------------------------------
    def read_Zynq_register_uint32(self, address_uint32):
        # Read Zynq register into buffer
        data_buffer = self.read_Zynq_register_32(address_uint32)
        # Parse buffer to unsigned int32 (uint32)
        register_value = struct.unpack('<I', data_buffer)[0]
        return register_value

    # Read Signed int32 Zynq Register -----------------------------------------
    def read_Zynq_register_int32(self, address_uint32):
        # Read Zynq register into buffer
        data_buffer = self.read_Zynq_register_32(address_uint32)
        # Parse buffer to signed int32 (int32)
        register_value = struct.unpack('<i', data_buffer)[0]
        return register_value

    # Read Single Precision binary32 Zynq Register ----------------------------
    def read_Zynq_register_float32(self, address_uint32):
        # Read Zynq register into buffer
        data_buffer = self.read_Zynq_register_32(address_uint32)
        # Parse buffer into single precision float (binary32)
        register_value = struct.unpack('<f', data_buffer)[0]
        return register_value

    # Read Unsigned int64 Zynq Register ---------------------------------------
    def read_Zynq_register_uint64(self, address_uint32_lsb, address_uint32_msb):
        # Read Zynq registers into buffer
        results_lsb = self.read_Zynq_register_32(address_uint32_lsb)
        results_msb = self.read_Zynq_register_32(address_uint32_msb)
        # Parse buffer to unsigned int64 (uint64)
        register_value = struct.unpack('<Q', results_lsb+results_msb)[0]
        return register_value

    # Read Signed int64 Zynq Register -----------------------------------------
    def read_Zynq_register_int64(self, address_uint32_lsb, address_uint32_msb):
        # Read Zynq registers into buffer
        results_lsb = self.read_Zynq_register_32(address_uint32_lsb)
        results_msb = self.read_Zynq_register_32(address_uint32_msb)
        # Parse buffer to signed int64 (int64)
        register_value = struct.unpack('<q', results_lsb+results_msb)[0]
        return register_value


    ###########################################################################
    #--- Reset Signals:
    ###########################################################################
    #

    def reset_front_end(self):
        print('Resetting FPGA (reset_front_end)...')
        self.write_Zynq_register_uint32(BUS_ADDR_TRIG_RESET_FRONTEND*4, 0)


    #######################################################
    #--- Legacy "Opal Kelly" API Emulation:
    #######################################################
    # this function is now disabled because we simply implemented "triggers" differently: they are simply the update_flag of an empty, but otherwise standard parallel bus register
    # def ActivateTriggerIn(self, endpoint, value):
    #   # this should send a trigger, most likely by toggling a value, and having the fpga diff that value
    #   # or it could be simply a write to a dummy address and we just use the sys_we as the trigger
    #   # although I am not sure if it is guaranteed to be 1-clock-cycle long
    #   #print('ActivateTriggerIn(): TODO')
    #   self.write_Zynq_register_uint32((endpoint+value)*4+value*4, 0)

    def set_wire_in_value(self, endpoint, value_16bits):
        # this only needs to update the internal state
        # for this, there would need to be two versions of the internal state, so that we can diff them and commit only the addresses that have changed
        # but its much simpler for now to just commit the change directly

        #print('set_wire_in_value(): TODO')

        # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values
        if value_16bits < 0:
            # write as a signed value
            self.write_Zynq_register_int32(endpoint*4, value_16bits)
        else:
            # write as an unsigned value
            self.write_Zynq_register_uint32(endpoint*4, value_16bits)

    def get_wire_out_value(self, endpoint):
        # print('get_wire_out_value(): TODO')
        # this reads a single 32-bits value from the fpga registers
        # the Opal Kelly code expected a 16-bits value, so we mask them out for compatibility
        rep = self.read_Zynq_register_uint32(4*endpoint)
        return rep & 0xFFFF # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values

    ###########################################################################
    #--- Auxiliary System Components:
    ###########################################################################
    #

    def setFan(self, fanState):

        self.fanState = fanState

        if fanState:
            data = 0b11000000
        else:
            data = 0b00000000

        self.write_Zynq_register_uint32(BUS_ADDR_FAN_PWR, data) # address outside "dpll_wrapper"


class LoopFilter:
    def __init__(self, device):
        assert isinstance(device, RedPitayaDevice)

        self.dev = device # instance of RedPitayaDevice for device communications

        #######################################################################
        #--- Loop Filter Controller
        #

        # Lock Enable Register Register Address
        self.lock_en_addr = [base_addr + BUS_OFFSET_LOCK for base_addr in BUS_ADDR_PLL_BASE]

        # Proportional Gain Register Address
        self.gain_p_addr = [base_addr + BUS_OFFSET_GAIN_P for base_addr in BUS_ADDR_PLL_BASE]

        # Integral Gain Register Address
        self.gain_i_addr_lsbs = [base_addr + BUS_OFFSET_GAIN_I_LSBs for base_addr in BUS_ADDR_PLL_BASE]
        self.gain_i_addr_msbs = [base_addr + BUS_OFFSET_GAIN_I_MSBs for base_addr in BUS_ADDR_PLL_BASE]

        # Double Integral Gain Register Address
        self.gain_ii_addr_lsbs = [base_addr + BUS_OFFSET_GAIN_II_LSBs for base_addr in BUS_ADDR_PLL_BASE]
        self.gain_ii_addr_msbs = [base_addr + BUS_OFFSET_GAIN_II_MSBs for base_addr in BUS_ADDR_PLL_BASE]

        # Derivative Gain Register Address
        self.gain_d_addr = [base_addr + BUS_OFFSET_GAIN_D for base_addr in BUS_ADDR_PLL_BASE]

        # Derivative Filter Gain Register Address
        self.coef_df_addr = [base_addr + BUS_OFFSET_COEF_DF for base_addr in BUS_ADDR_PLL_BASE]

        # Open Loop Gain Register Address
        self.gain_ol_addr = [base_addr + BUS_OFFSET_GAIN_OL for base_addr in BUS_ADDR_PLL_BASE]

        # Loop Sign Register Address
        self.lf_sign_addr = [base_addr + BUS_OFFSET_LF_SIGN for base_addr in BUS_ADDR_PLL_BASE]

        # Manual Offset Register Address
        self.manual_offset_addr_lsbs = [base_addr + BUS_OFFSET_MAN_OFFSET_LSBs for base_addr in BUS_ADDR_PLL_BASE]
        self.manual_offset_addr_msbs = [base_addr + BUS_OFFSET_MAN_OFFSET_MSBs for base_addr in BUS_ADDR_PLL_BASE]

        # Gain Settings
        self.gain_p = [0 for channel in range(LF_CHANNELS)]
        self.gain_i = [0 for channel in range(LF_CHANNELS)]
        self.gain_ii = [0 for channel in range(LF_CHANNELS)]
        self.gain_d = [0 for channel in range(LF_CHANNELS)]
        self.coef_df = [0 for channel in range(LF_CHANNELS)]
        self.gain_ol = [0 for channel in range(LF_CHANNELS)]
        self.ol_gain_unit = ["Hz/V", "Hz/V", "Hz/Hz"]

        # Input Multiplexer
        self._loop_filter_1_input_mux = 0


        #######################################################################
        #--- Dither Lock-In:
        # TODO: channel 2 dither not implemented
        #

        self.dither_frequency_Hz = [1e2, 1e2, 1e2] # Hz
        self.integration_time_s = [0.1, 0.1, 0.1] # s
        self.dither_amplitude_V = [1e-3, 1e-3, 1e6] # V
        self.auto_dither_mode = [True, True, False]
        self.dither_enabled = [True, True, False]

        #######################################################################
        #--- DDC
        #

        self.ddc_ref_freq_addr_lsbs = [BUS_ADDR_REF_FREQ0_LSBs, BUS_ADDR_REF_FREQ1_LSBs]
        self.ddc_ref_freq_addr_msbs = [BUS_ADDR_REF_FREQ0_MSBs, BUS_ADDR_REF_FREQ1_MSBs]

        self.ddc_filter_select = [0, 0]
        self.ddc_angle_seelct = [0, 0]
        self.lf_residuals_selector = [0, 0]

        self.ddc_ref_freq_Hz = [125e6/4, 125e6/4]
        self.ddc_phase_incr_int = [self.DDS_phase_increment_parameter(target_frequency_Hz) for target_frequency_Hz in self.ddc_ref_freq_Hz]

    ###########################################################################
    #--- Loop Filter Parameter Limits:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Integer Parameter Limits:
    #

    def int_p_limits(self, channel):
        '''Gain P is signed 32 bit integer on the FPGA'''
        return (0,
                2**(N_BITS_GAIN_P[channel] - 1) -1)

    def int_i_limits(self, channel):
        '''Gain I is signed 32 bit integer on the FPGA'''
        return (0,
                2**(N_BITS_GAIN_I[channel] - 1) - 1)

    def int_ii_limits(self, channel):
        '''Gain II is signed 32 bit integer on the FPGA'''
        return (0,
                2**(N_BITS_GAIN_II[channel] - 1) - 1)

    def int_d_limits(self, channel):
        '''Gain D is signed 32 bit integer on the FPGA'''
        return (0,
                2**(N_BITS_GAIN_D[channel] - 1) - 1)

    def int_df_limits(self, channel):
        '''Filter Coefficient DF is signed 18 bit integer on the FPGA'''
        return (0,
                2**(N_BITS_COEF_DF[channel] - 1) - 1)

    #--------------------------------------------------------------------------
    # Scaled Parameter Limits:
    #

    def p_limits(self, channel):
        (min_int_p, max_int_p) = self.int_p_limits(channel)
        return (min_int_p/2.**N_BITS_DIVIDE_P[channel],
                max_int_p/2.**N_BITS_DIVIDE_P[channel])

    def i_limits(self, channel):
        (min_int_i, max_int_i) = self.int_i_limits(channel)
        return (min_int_i/2.**N_BITS_DIVIDE_I[channel],
                max_int_i/2.**N_BITS_DIVIDE_I[channel])

    def ii_limits(self, channel):
        (min_int_ii, max_int_ii) = self.int_ii_limits(channel)
        return (min_int_ii/2.**N_BITS_DIVIDE_II[channel],
                max_int_ii/2**N_BITS_DIVIDE_II[channel])

    def d_limits(self, channel):
        (min_int_d, max_int_d) = self.int_d_limits(channel)
        return (min_int_d/2.**N_BITS_DIVIDE_D[channel],
                max_int_d/2.**N_BITS_DIVIDE_D[channel])

    def df_limits(self, channel):
        (min_int_df, max_int_df) = self.int_df_limits(channel)
        return (min_int_df/2.**N_BITS_DIVIDE_DF[channel],
                max_int_df/2.**N_BITS_DIVIDE_DF[channel])

    ###########################################################################
    #--- Read/Write Loop Filter Settings:
    ###########################################################################
    #

    def set_lf_sign(self, channel, sign):
        self.dev.write_Zynq_register_int16(
            dpll_write_address(self.lf_sign_addr[channel]),
            int(np.signbit(sign)))

    def get_lf_sign(self, channel):
        sign_bit = self.dev.read_Zynq_register_int16(
            dpll_read_address(self.lf_sign_addr[channel]))
        sign = -1 if sign_bit else 1
        return sign

    def set_manual_offset(self, channel, offset_int):
        if channel == 2:
            # Channel 2 has a range of 48 bits
            self.dev.write_Zynq_register_int64(
                dpll_write_address(self.manual_offset_addr_lsbs[channel]),
                dpll_write_address(self.manual_offset_addr_msbs[channel]),
                offset_int)
        else:
            # Channels 0 and 1 have a range of 16 bits
            self.dev.write_Zynq_register_int16(
                dpll_write_address(self.manual_offset_addr_lsbs[channel]),
                offset_int)

    def get_manual_offset(self, channel):
        ''' This function only returns the most recent value written with the
        `set_manual_offset` method. This does not include adjustments made to this
        value by the PLL's integrator term.
        '''
        if channel == 2:
            # Channel 2 has a range of 48 bits
            offset_int = self.dev.read_Zynq_register_int64(
                dpll_read_address(self.manual_offset_addr_lsbs[channel]),
                dpll_read_address(self.manual_offset_addr_msbs[channel]))
        else:
            # Channels 0 and 1 have a range of 16 bits
            offset_int = self.dev.read_Zynq_register_int16(
                dpll_read_address(self.manual_offset_addr_lsbs[channel]))
        return offset_int

    def set_pll_settings(self, channel, gain_p, gain_i, gain_ii, gain_d, coef_df, bLock, gain_ol):
        bDebugOutput = True

        gain_p_int = int(round(gain_p*2.**N_BITS_DIVIDE_P[channel]))
        gain_i_int = int(round(gain_i*2.**N_BITS_DIVIDE_I[channel]))
        gain_ii_int = int(round(gain_ii*2.**N_BITS_DIVIDE_II[channel]))
        gain_d_int = int(round(gain_d*2.**N_BITS_DIVIDE_D[channel]))
        coef_df_int = int(round(coef_df*2.**N_BITS_DIVIDE_DF[channel]))

        if gain_p_int > max(self.int_p_limits(channel)):
            if bDebugOutput:
                print('P Gain maximized.')
            gain_p_int = max(self.int_p_limits(channel))
        elif gain_p_int < min(self.int_p_limits(channel)):
            if bDebugOutput:
                print('P Gain off.')
            gain_p_int = min(self.int_p_limits(channel))

        if gain_i_int > max(self.int_i_limits(channel)):
            if bDebugOutput:
                print('I Gain maximized.')
            gain_i_int = max(self.int_i_limits(channel))
        elif gain_i_int < min(self.int_i_limits(channel)):
            if bDebugOutput:
                print('I Gain off.')
            gain_i_int = min(self.int_i_limits(channel))

        if gain_ii_int > max(self.int_ii_limits(channel)):
            if bDebugOutput:
                print('II Gain maximized.')
            gain_ii_int = max(self.int_ii_limits(channel))
        elif gain_ii_int < min(self.int_ii_limits(channel)):
            if bDebugOutput:
                print('II Gain off.')
            gain_ii_int = min(self.int_ii_limits(channel))

        if gain_d_int > max(self.int_d_limits(channel)):
            if bDebugOutput:
                print('D Gain maximized.')
            gain_d_int = max(self.int_d_limits(channel))
        elif gain_d_int < min(self.int_d_limits(channel)):
            if bDebugOutput:
                print('D Gain off.')
            gain_d_int = min(self.int_d_limits(channel))

        if coef_df_int > max(self.int_df_limits(channel)):
            if bDebugOutput:
                print('DF Coef maximized.')
            coef_df_int = max(self.int_df_limits(channel))
        elif coef_df_int < min(self.int_df_limits(channel)):
            if bDebugOutput:
                print('DF Coef off.')
            coef_df_int = min(self.int_df_limits(channel))

        self.gain_p[channel] = gain_p_int/2.**N_BITS_DIVIDE_P[channel]
        self.gain_i[channel] = gain_i_int/2.**N_BITS_DIVIDE_I[channel]
        self.gain_ii[channel] = gain_ii_int/2.**N_BITS_DIVIDE_II[channel]
        self.gain_d[channel] = gain_d_int/2.**N_BITS_DIVIDE_D[channel]
        self.coef_df[channel] = coef_df_int/2.**N_BITS_DIVIDE_DF[channel]

        if bDebugOutput:
            print('P_gain = {:.4g}, in integer: P_gain = {:d} = 2^{:.3f}'.format(self.gain_p[channel], gain_p_int, 1+np.log2(gain_p_int)))
            print('I_gain = {:.4g}, in integer: I_gain = {:d} = 2^{:.3f}'.format(self.gain_i[channel], gain_i_int, 1+np.log2(gain_i_int)))
            print('II_gain = {:.4g}, in integer: II_gain = {:d} = 2^{:.3f}'.format(self.gain_ii[channel], gain_ii_int, 1+np.log2(gain_ii_int)))
            print('D_gain = {:.4g}, in integer: D_gain = {:d} = 2^{:.3f}'.format(self.gain_d[channel], gain_d_int, 1+np.log2(gain_d_int)))
            print('DF_gain = {:.4g}, in integer: DF_gain = {:d} = 2^{:.3f}'.format(self.coef_df[channel], coef_df_int, 1+np.log2(coef_df_int)))
            print('')

        # Send lock/unlock setting
        self.dev.write_Zynq_register_uint16(
            dpll_write_address(self.lock_en_addr[channel]),
            bLock)
        # Send P gain
        self.dev.write_Zynq_register_int32(
            dpll_write_address(self.gain_p_addr[channel]),
            gain_p_int)
        # Send I gain
        self.dev.write_Zynq_register_int64(
            dpll_write_address(self.gain_i_addr_lsbs[channel]),
            dpll_write_address(self.gain_i_addr_msbs[channel]),
            gain_i_int)
        # Send II gain
        self.dev.write_Zynq_register_int64(
            dpll_write_address(self.gain_ii_addr_lsbs[channel]),
            dpll_write_address(self.gain_ii_addr_msbs[channel]),
            gain_ii_int)
        # Send D gain
        self.dev.write_Zynq_register_int32(
            dpll_write_address(self.gain_d_addr[channel]),
            gain_d_int)
        # Send DF coef
        self.dev.write_Zynq_register_int32(
            dpll_write_address(self.coef_df_addr[channel]),
            coef_df_int)
        # Send OL gain
        self.dev.write_Zynq_register_float32(
            dpll_write_address(self.gain_ol_addr[channel]),
            gain_ol)

    def get_pll_settings(self, channel):
        # Get Lock/Unlock setting
        bLock = self.dev.read_Zynq_register_uint16(
            dpll_read_address(self.lock_en_addr[channel]))
        # Get P Gain
        gain_p_int = self.dev.read_Zynq_register_int32(
            dpll_read_address(self.gain_p_addr[channel]))
        # Get I Gain
        gain_i_int = self.dev.read_Zynq_register_int64(
            dpll_read_address(self.gain_i_addr_lsbs[channel]),
            dpll_read_address(self.gain_i_addr_msbs[channel]))
        # Get II Gain
        gain_ii_int = self.dev.read_Zynq_register_int64(
            dpll_read_address(self.gain_ii_addr_lsbs[channel]),
            dpll_read_address(self.gain_ii_addr_msbs[channel]))
        # Get D Gain
        gain_d_int = self.dev.read_Zynq_register_int32(
            dpll_read_address(self.gain_d_addr[channel]))
        # Get DF Coef
        coef_df_int = self.dev.read_Zynq_register_int32(
            dpll_read_address(self.coef_df_addr[channel]))
        # Get Open Loop Gain
        gain_ol = self.dev.read_Zynq_register_float32(
            dpll_read_address(self.gain_ol_addr[channel]))

        self.bLock   = bLock
        self.gain_p[channel]  = gain_p_int/2.**N_BITS_DIVIDE_P
        self.gain_i[channel]  = gain_i_int/2.**N_BITS_DIVIDE_I
        self.gain_ii[channel] = gain_ii_int/2.**N_BITS_DIVIDE_II
        self.gain_d[channel]  = gain_d_int/2.**N_BITS_DIVIDE_D
        self.coef_df[channel] = coef_df_int/2.**N_BITS_DIVIDE_DF
        self.gain_ol[channel] = gain_ol # float to float, no conversion
        return (self.gain_p[channel],  self.gain_i[channel], self.gain_ii[channel], self.gain_d[channel], self.coef_df[channel], self.bLock[channel], self.gain_ol[channel])

    def set_loop_filter_input_mux(self, channel, register_value):
        ''' This mux selects the source of the error signal to the loop filter
        of channel 1.

        This makes it possible to select:
            - register_value = 0:
                the output of DDC1 (the normal, 2 independent channels
                operation)
            - register_value = 1:
                the output of DDC0 (allows locking the same error signal with
                two actuators)
            - register_value = 2:
                the output of channel 0's loop filter (allows locking the DAC0
                actuator in the center of its range)
        '''
        if channel == 1:
            self.dev.write_Zynq_register_uint16(
                dpll_write_address(BUS_ADDR_MUX_PLL1),
                register_value)
            self._loop_filter_1_input_mux = register_value
            if register_value==2:
                self.ol_gain_unit[channel] = "V/V"
            else:
                self.ol_gain_unit[channel] = "Hz/V"

    def read_loop_filter_input_mux(self, channel):
        if channel == 1:
            register_value = self.dev.read_Zynq_register_uint32(
                dpll_read_address(BUS_ADDR_MUX_PLL1))
            self._loop_filter_1_input_mux = register_value
            if register_value==2:
                self.ol_gain_unit[channel] = "V/V"
            else:
                self.ol_gain_unit[channel] = "Hz/V"
            return register_value

    ###########################################################################
    #--- Loop Filter 2 Only Methods:
    ###########################################################################
    # RF to Optical Lock Steering
    #

    ###########################################################################
    #--- Loop Filter Helper Functions:
    ###########################################################################
    #

    def get_current_transfer_function(self, channel, freq_axis, fs):
        #TODO: scale by open loop gain?

        unit_delay_phase_ramp = 2*np.pi * freq_axis/fs
        H_cumsum = 1/(1-np.exp(1j*unit_delay_phase_ramp))
        #H_cumsum = 1/(1j*unit_delay_phase_ramp)

        afilt = self.coef_df[channel]
        H_filt = afilt/(1-(1-afilt)*np.exp(1j*unit_delay_phase_ramp))
        #H_filt = afilt/(afilt+(1-np.exp(1j*unit_delay_phase_ramp)))
        #H_filt = afilt/(afilt+1j*unit_delay_phase_ramp)
        H_diff = (1-np.exp(1j*unit_delay_phase_ramp))
        #H_diff = 1j*unit_delay_phase_ramp

        # The transfer function is the sum of the four terms (P, I, II, D)
        H_loop_filters_P = self.gain_p[channel] * np.exp(-1j*N_CYCLS_DELAY_P * unit_delay_phase_ramp)
        H_loop_filters_I = self.gain_i[channel] * H_cumsum * np.exp(-1j*N_CYCLES_DELAY_I * unit_delay_phase_ramp)
        H_loop_filters_II = self.gain_ii[channel] * H_cumsum**2 * np.exp(-1j*N_CYCLES_DELAY_II * unit_delay_phase_ramp)
        H_loop_filters_D = self.gain_d[channel] * H_diff * H_filt * np.exp(-1j*N_CYCLES_DELAY_D * unit_delay_phase_ramp)
        H_loop_filters = H_loop_filters_P + H_loop_filters_II + H_loop_filters_I + H_loop_filters_D
        #print(H_loop_filters)

        return H_loop_filters

    def open_loop_gain_unit_conversion_factor(self, channel):
        """
        error signal unit / feedback unit
        """
        if self.ol_gain_unit[channel]=="Hz/V":
            # DDC Hz error signal / DAC V outptut
            unit_conversion_factor = LF_ERR_SIG_Hz_INT / DAC_V_INT
        elif self.ol_gain_unit[channel]=="V/V":
            # V error signal / DAC V output
            unit_conversion_factor = LF_ERR_SIG_V_INT / DAC_V_INT
        elif self.ol_gain_unit[channel]=="Hz/Hz":
            # DDC Hz error signal / DDS Hz output
            unit_conversion_factor = LF_ERR_SIG_Hz_INT / DDC_DDS_FREQ_Hz_INT
        else:
            print("Open loop gain not configured")

        return unit_conversion_factor

    def open_loop_gain_parameter(self, channel, open_loop_gain):
        """

        Parameters
        ----------
        open_loop_gain : TYPE
            DESCRIPTION.
        channel : TYPE
            DESCRIPTION.

        Returns
        -------
        int_open_loop_gain_parameter : TYPE
            DESCRIPTION.

        """
        unit_conversion_factor = self.open_loop_gain_unit_conversion_factor(channel)

        int_open_loop_gain_parameter = open_loop_gain / unit_conversion_factor
        return int_open_loop_gain_parameter

    def open_loop_gain(self, int_open_loop_gain_parameter, channel):
        unit_conversion_factor = self.open_loop_gain_unit_conversion_factor(channel)

        ol_gain = int_open_loop_gain_parameter * unit_conversion_factor
        return ol_gain


    ###########################################################################
    #--- Read/Write Dither Lock-In Settings:
    ###########################################################################
    #

    def set_dither_lock_in_parameters(self, channel,
        modulation_frequency_Hz, integration_time_s, amplitude_V,
        mode_auto, enable_dither=None):
        """

        Parameters
        ----------
        channel : int
            Loop filter channel.
        modulation_frequency_Hz : float
            Frequency of the dither modulation frequency in Hz.
        integration_time_s : float
            Integration time in seconds. Note, this will be rounded to the next
            integer modulation period.
        amplitude_V : float
            Amplitude of the dither modulation in Volts.
        mode_auto : bool
            Enable auto dither and lock-in. If auto is enabled, the dither is
            off while the lock is engaed and on when the lock is disengaged.
        enable_dither : bool, optional
            Enable or disable the dither and lock-in. If None, the dither state
            remains unchanged. The default is None.

        Returns
        -------
        None.

        Notes
        -----
        The `mode_auto` is not yet implemented on the FPGA. The user must keep
        track of the "auto" state and manually update `enable_dither`.

        """
        modulation_period_in_samples = ADC_CLK_Hz/modulation_frequency_Hz
        modulation_period_divided_by_4_minus_one = int(round(modulation_period_in_samples/4-1))
        N_periods = int(np.ceil(integration_time_s * modulation_frequency_Hz))
        N_periods_integration_minus_one = N_periods-1
        dither_amplitude_int = int(round(amplitude_V / DAC_V_INT))
        dither_mode_auto = int(mode_auto)
        if enable_dither is not None:
            dither_enable = int(enable_dither)

        self.dither_frequency_Hz[channel] = ADC_CLK_Hz/((modulation_period_divided_by_4_minus_one+1)*4)
        self.integration_time_s[channel] = N_periods * self.dither_frequency_Hz[channel]
        self.dither_amplitude_V[channel] = dither_amplitude_int * DAC_V_INT
        self.auto_dither_mode[channel] = mode_auto
        if enable_dither is not None:
            self.dither_enabled[channel] = enable_dither

        # Dither Modulation Period
        self.dev.write_Zynq_register_uint32(
            dpll_write_address(BUS_ADDR_dither_period_divided_by_4_minus_one[channel]),
            modulation_period_divided_by_4_minus_one)
        # Dither Integration Time
        self.dev.write_Zynq_register_uint32(
            dpll_write_address(BUS_ADDR_dither_N_periods_minus_one[channel]),
            N_periods_integration_minus_one)
        # Dither Amplitude
        self.dev.write_Zynq_register_uint16(
            dpll_write_address(BUS_ADDR_dither_amplitude[channel]),
            dither_amplitude_int)
        # Auto Dither Enabled
        self.dev.write_Zynq_register_uint16(
            dpll_write_address(BUS_ADDR_dither_mode_auto[channel]),
            dither_mode_auto)
        # Dither Enabled
        if enable_dither is not None:
            self.dev.write_Zynq_register_uint16(
                dpll_write_address(BUS_ADDR_dither_enable[channel]),
                dither_enable)

    def set_dither_state(self, channel, enable_dither):
        self.set_dither_lock_in_parameters(
            channel,
            self.dither_frequency_Hz[channel],
            self.integration_time_s[channel],
            self.dither_amplitude_V[channel],
            self.auto_dither_mode[channel],
            enable_dither)

    def get_dither_settings(self, channel):
        # Dither Modulation Period
        modulation_period_divided_by_4_minus_one = self.dev.read_Zynq_register_uint32(
                dpll_read_address(BUS_ADDR_dither_period_divided_by_4_minus_one[channel]))
        # Dither Integration Time
        N_periods_integration_minus_one = self.dev.read_Zynq_register_uint32(
                dpll_read_address(BUS_ADDR_dither_N_periods_minus_one[channel]))
        # Dither Amplitude
        dither_amplitude_int = self.dev.read_Zynq_register_uint16(
                dpll_read_address(BUS_ADDR_dither_amplitude[channel]))
        # Auto Dither Enabled
        dither_mode_auto = self.dev.read_Zynq_register_uint16(
                dpll_read_address(BUS_ADDR_dither_mode_auto[channel]))
        # Dither Enabled
        dither_enable = self.dev.read_Zynq_register_uint16(
                dpll_read_address(BUS_ADDR_dither_enable[channel]))

        N_periods = N_periods_integration_minus_one + 1
        modulation_period_in_samples = (modulation_period_divided_by_4_minus_one + 1)*4
        modulation_frequency_Hz = ADC_CLK_Hz/modulation_period_in_samples
        integration_time_s = N_periods/modulation_frequency_Hz
        amplitude_V = dither_amplitude_int * DAC_V_INT

        self.dither_frequency_Hz[channel] = modulation_frequency_Hz
        self.integration_time_s[channel] = integration_time_s
        self.dither_amplitude_V[channel] = amplitude_V
        self.auto_dither_mode[channel] = dither_mode_auto
        self.dither_enabled[channel] = dither_enable

        return (self.dither_frequency_Hz[channel], self.integration_time_s[channel], self.dither_amplitude_V[channel], self.auto_dither_mode[channel], self.dither_enabled[channel])

    def read_dither_result(self, channel):
        """


        Parameters
        ----------
        channel : int
            The loop filter channel.

        Raises
        ------
        NotImplementedError
            If called with loop filter channel 2.

        Returns
        -------
        open_loop_gain : float
            The open loop gain of the servo channel. The units are scaled as in
            the channel's `self.ol_gain_unit`.
        open_loop_gain_unit : str
            A string containing the units of the open loop gain

        Notes
        -----
        A stable loop filter must have a negative feedback. The open loop gain
        retrieved in this function is scaled such that it is positive when the
        loop filter sign is correctly tuned.
        """
        if channel == 0:
            BASE_ADDR_REAL_LSB = BUS_ADDR_DITHER0_LOCKIN_REAL_LSB
            BASE_ADDR_REAL_MSB = BUS_ADDR_DITHER0_LOCKIN_REAL_MSB
        elif channel == 1:
            BASE_ADDR_REAL_LSB = BUS_ADDR_DITHER1_LOCKIN_REAL_LSB
            BASE_ADDR_REAL_MSB = BUS_ADDR_DITHER1_LOCKIN_REAL_MSB
        elif channel == 2:
            raise NotImplementedError

        # amplitude of the error signal at the lock-in frequency, summed for N_samples_integration.
        lock_in_amplitude_int_times_N_samples = self.dev.read_Zynq_register_int64(
            dpll_write_address(BASE_ADDR_REAL_LSB),
            dpll_write_address(BASE_ADDR_REAL_MSB))

        N_samples_integration = self.integration_time_s[channel] * ADC_CLK_Hz
        lock_in_amplitude_int = -lock_in_amplitude_int_times_N_samples/N_samples_integration

        dither_amplitude_int = self.dither_amplitude_V[channel] / DAC_V_INT

        unit_conversion_factor = self.open_loop_gain_unit_conversion_factor(channel)

        open_loop_gain = lock_in_amplitude_int/dither_amplitude_int * unit_conversion_factor

        return open_loop_gain, self.ol_gain_unit[channel]

    ###########################################################################
    #--- Direct Digital Synthesis (DDS) Helper Functions
    ###########################################################################
    #

    def DDS_phase_increment_parameter(self, target_frequency_Hz):
        '''Calculate the DDS integer phase increment parameter that will
        produce an output frequency nearest to the target.

        See the theory of operation in standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        # Magnitude of the fractional phase increment
        target_fractional_phase_increment = abs(target_frequency_Hz)/ADC_CLK_Hz
        # Magnitude of the target phase increment parameter
        target_phase_increment_parameter = target_fractional_phase_increment * 2**DDC_DDS_PHASE_ACCUM_N_BITS
        # Wrapped integer magnitude of the phase increment parameter
        int_phase_increment_parameter = int(round(target_phase_increment_parameter)) % 2**DDC_DDS_PHASE_ACCUM_N_BITS
        # Signed integer phase increment parameter
        int_phase_increment_parameter = int(int_phase_increment_parameter * np.sign(target_frequency_Hz))
        return int_phase_increment_parameter

    def DDS_frequency(self, int_phase_increment_parameter):
        '''Calculate the DDS output frequency in Hz given an integer phase
        increment parameter.

        See the theory of operation of standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        fractional_phase_increment = int_phase_increment_parameter / 2**DDC_DDS_PHASE_ACCUM_N_BITS
        frequency_Hz = fractional_phase_increment * ADC_CLK_Hz
        return frequency_Hz

    @property
    def DDS_frequency_resolution(self):
        '''Calculate the frequency resolution of the DDS.

        See the theory of operation of standard mode in the LogiCORE IP DDS
        Compiler Product Guide for more details.
        '''
        frequency_resolution = ADC_CLK_Hz / 2**DDC_DDS_PHASE_ACCUM_N_BITS
        return frequency_resolution

    ###########################################################################
    #--- Read/Write Digital Down Converter (DDC) Parameters
    ###########################################################################
    #

    def set_ddc_ref_freq(self, channel, frequency_Hz):
        # Calculate nearest phase increment parameter
        self.ddc_phase_incr_int[channel] = self.DDS_phase_increment_parameter(frequency_Hz)
        # Calculate the actual frequency
        self.ddc_ref_freq_Hz[channel] = self.DDS_frequency(self.ddc_phase_incr_int[channel])
        # Write to FPGA
        self.dev.write_Zynq_register_int64(
                dpll_write_address(self.ddc_ref_freq_addr_lsbs[channel]),
                dpll_write_address(self.ddc_ref_freq_addr_msbs[channel]),
                self.ddc_phase_incr_int[channel])

    def get_ddc_ref_freq(self, channel):
        # Read FPGA to get the current value
        self.ddc_phase_incr_int[channel] = self.dev.read_Zynq_register_int64(
                dpll_read_address(self.ddc_ref_freq_addr_lsbs[channel]),
                dpll_read_address(self.ddc_ref_freq_addr_msbs[channel]))
        self.ddc_ref_freq_Hz[channel] = self.DDS_frequency(self.ddc_phase_incr_int[channel])
        return self.ddc_ref_freq_Hz[channel]

    def set_ddc_filter(self, channel, filter_select, angle_select = 0):

        self.ddc_filter_select[channel] = filter_select
        self.ddc_angle_select[channel] = angle_select

        #TODO: Break apart setting into filter and angle selection?

        # DDC Filter Selection:
        register_value = (
                self.set_bits(self.ddc_filter_select[0], 0, bit_length=2)
                +self.set_bits(self.ddc_filter_select[1], 2, bit_length=2)
                +self.set_bits(self.lf_residuals_selector[0], 4)
                +self.set_bits(self.lf_residuals_selector[1], 5))
        self.dev.write_Zynq_register_uint32(
                dpll_write_address(BUS_ADDR_DDC_FILT_SEL),
                register_value)
        # "Angle" Selection:
        register_value = (self.set_bits(self.ddc_angle_select[0], 0, bit_length=4)
                          +self.set_bits(self.ddc_angle_select[0], 4, bit_length=4))
        self.dev.write_Zynq_register_uint32(
                dpll_write_address(BUS_ADDR_DDC_ANGLE_SEL),
                register_value)

    def get_ddc_filter_select(self):

        data = self.dev.read_Zynq_register_uint32(
                dpll_read_address(BUS_ADDR_DDC_FILT_SEL))

        self.ddc_filter_select[0] = self.get_bits(data, 0, bit_length=2)
        self.ddc_filter_select[1] = self.get_bits(data, 2, bit_length=2)

        return (self.ddc_filter_select[1], self.ddc_filter_select[0])

    def get_ddc_angle_select(self):

        data = self.dev.read_Zynq_register_uint32(
                dpll_read_address(BUS_ADDR_DDC_ANGLE_SEL))
        self.ddc_angle_select[0] = self.get_bits(data, 0, bit_length=4)
        self.ddc_angle_select[1] = self.get_bits(data, 4, bit_length=4)

        return (self.ddc_angle_select[1], self.ddc_angle_select[0])

    ###########################################################################
    #--- DDC Helper Functions
    ###########################################################################
    #

    def DDC_frequency(self, ddc_frequency_int):
        '''Convert the internal FPGA integer DDC output into frequency offset
        in Hz.
        '''
        return ddc_frequency_int * DDC_FREQ_HZ_INT

    def frontend_DDC_processing(self, channel, samples, ref_exp0):

        # Fractional Frequency Offset
        f_reference = self.DDS_frequency(self.ddc_int_phase_incr[channel]) / ADC_CLK_Hz

        ref_exp = (ref_exp0)/np.abs(ref_exp0) * np.exp(-1j*2*np.pi*f_reference*np.array(range(len(samples))))
        complex_baseband = (samples-np.mean(samples)) * ref_exp

        # There are two versions of the firmware in use: one uses a 20points boxcar filter,
        # the other one uses a wider bandwidth filter, consisting of a cascade of a 2-pts boxcar, another 2-pts boxcar, and finally a 4-points boxcar.
        filter_select = self.ddc_filter_select[channel]
        #angle_select  = self.ddc_angle_select[channel]

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
        complex_baseband = lfilter(lpf, 1, complex_baseband)[N_filter:]
        return complex_baseband

    def get_frontend_filter_response(self, channel, frequency_axis):

        f_reference = self.DDS_frequency(self.ddc_int_phase_incr[channel])

        filter_select = self.ddc_filter_select[channel]
        #angle_select  = self.ddc_angle_select[channel]

        if filter_select == 0:
            # wideband filter
            spc_filter = np.ones(frequency_axis.shape, dtype=float)
            N_filter = 2
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)
            N_filter = 4
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)

            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
        elif filter_select == 1:
            # narrowband filter
            N_filter = 16
            spc_filter = np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)
            N_filter = 4
            spc_filter = spc_filter * np.sin(np.pi * (abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)/ (np.pi*(abs(frequency_axis-abs(f_reference))+10)*N_filter/ADC_CLK_Hz)

            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)
        elif filter_select == 2:
            # minimum-phase fir filter:
            lpf = np.array([4533, 11833, 14589, 7610, -2628, -5400, -350, 3293, 1086, -1867, -1080, 956, 800, -462, -650, 338])/(2.**15-1)
            lpf = np.convolve(np.ones(2, dtype=float)/2., lpf)
            spc_ref = np.fft.fft(lpf, 2*len(frequency_axis))
            freq_axis_ref = np.linspace(0*ADC_CLK_Hz, 1*ADC_CLK_Hz, 2*len(frequency_axis))
            spc_filter = np.interp(abs(frequency_axis-abs(f_reference)), freq_axis_ref, np.abs(spc_ref))
            spc_filter = 20*np.log10(np.abs(spc_filter) + 1e-7)

        return spc_filter


class DigitalToAnalogConverter:
    #contains dac and vco stuff
    def __init__(self):
        self.DACs_limit_low = copy.copy(DAC_LIM_LOW_INT) # [:] returns copy
        self.DACs_limit_high = copy.copy(DAC_LIM_HIGH_INT)

        self.DAC_limits_low_int = copy.copy(DAC_LIM_LOW_INT)
        self.DAC_limits_high_int = copy.copy(DAC_LIM_HIGH_INT)

        self.DAC_limits_low_V
        self.DAC_limits_high_V

        self.output_vco = [0, 0, 0]

        self.DAC_limits_addr = [BUS_ADDR_dac0_limits,
                                BUS_ADDR_dac1_limits,
                                {"low":BUS_ADDR_dac2_limit_low,
                                 "high":BUS_ADDR_dac2_limit_high}]

    ###########################################################################
    #--- Primary DAC Hardware Limits:
    ###########################################################################
    #

    def int_dac_hw_limit(self, channel):
        limit_low_int = DAC_LIM_LOW_INT[channel]
        limit_high_int = DAC_LIM_HIGH_INT[channel]
        return (limit_low_int, limit_high_int)

    def dac_hw_limit(self, channel):
        (limit_low_int, limit_high_int) = self.int_dac_hw_limit(channel)
        limit_low_V = limit_low_int * DAC_V_INT
        limit_high_V = limit_high_int * DAC_V_INT
        return (limit_low_V, limit_high_V)


    ###########################################################################
    #--- Read/Write Primary DAC Settings:
    ###########################################################################
    #

    def set_dac_limits(self, channel, limit_low_V, limit_high_V, bSendToFPGA = True):

        limit_low_int = int(round(limit_low_V / DAC_V_INT))
        limit_high_int = int(round(limit_high_V / DAC_V_INT))

        if limit_high_int > DAC_LIM_HIGH_INT[channel]:
            limit_high_int = DAC_LIM_HIGH_INT[channel]
        if limit_low_int < DAC_LIM_LOW_INT[channel]:
            limit_low_int = DAC_LIM_LOW_INT[channel]
        #print('dac = %d, low = %d, high = %d' % (channel, limit_low, limit_high))

        self.DACs_limit_low_int[channel] = limit_low_int
        self.DACs_limit_high_int[channel] = limit_high_int
        self.DACs_limit_low_V[channel] = limit_low_int * DAC_V_INT
        self.DACs_limit_high_V[channel] = limit_high_int * DAC_V_INT

        if (channel == 0) or (channel == 1):
            self.dev.write_Zynq_register_2x_int16(
                dpll_write_address(self.DAC_limits_addr[channel]),
                limit_low_int,
                limit_high_int)
        elif channel == 2:
            self.dev.write_Zynq_register_int32(
                dpll_write_address(self.DAC_limits_addr[channel]["low"]),
                limit_low_int)
            self.dev.write_Zynq_register_int32(
                dpll_write_address(self.DAC_limits_addr[channel]["high"]),
                limit_high_int)

    def get_dac_limits(self, channel):

        if (channel == 0) or (channel == 1):
            (limit_low_int, limit_high_int) = self.dev.read_Zynq_register_2x_int16(
                dpll_read_address(self.DAC_limits_addr[channel]))
        elif channel == 2:
            limit_low_int  = self.dev.read_Zynq_register_int32(
                dpll_read_address(self.DAC_limits_addr[channel]["low"]))
            limit_high_int = self.dev.read_Zynq_register_int32(
                dpll_read_address(self.DAC_limits_addr[channel]["high"]))

        self.DACs_limit_low[channel] = limit_low_int
        self.DACs_limit_high[channel] = limit_high_int
        self.DACs_limit_low_V[channel] = limit_low_int * DAC_V_INT
        self.DACs_limit_high_V[channel] = limit_high_int * DAC_V_INT

        return (self.DACs_limit_low_V[channel], self.DACs_limit_high_V[channel])

    ###########################################################################
    #--- Primary DAC Helper Functions:
    ###########################################################################
    #

    def dac_output_voltage(self, dac_output_int):
        dac_output_V = dac_output_int * DAC_V_INT
        return dac_output_V

    def dac_output_int(self, dac_output_V):
        dac_output_int = dac_output_V / DAC_V_INT
        return dac_output_int

    ###########################################################################
    #--- Pulse Width Managed (PWM) DAC Outputs:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # PWM DAC Output Helper Functions:
    #

    def pwm_output_volts(self, standard, levels, counts):
        return np.float(standard)*np.float(counts)/np.float(levels)

    def pwm_output_int(self, standard, levels, volts):
        return int(np.round(np.float(levels)*np.float(volts)/np.float(standard)))

    #--------------------------------------------------------------------------
    # Read/Write PWM DAC Output Parameters:
    #

    def set_pwm_settings(self, levels, value, bSendToFPGA = True):
        value = int(round(value))
        # Clamp value
        if value > levels:
            value = levels
        if value < 0:
            value = 0
        # Send to FPGA
        if bSendToFPGA == True:
            self.dev.write_Zynq_register_uint32(
                    dpll_write_address(BUS_ADDR_PWM0),
                    value)


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
        self.vco_offset_in_volt = offset
        vco_offset = round(offset*(2**13-1)) #13 bits, because offset is signed
        self.dev.write_Zynq_register_uint32(BUS_ADDR_vco_offset, vco_offset) # address outside "dpll_wrapper"

    def get_internal_VCO_offset(self):
        raw = self.dev.read_Zynq_register_uint32(BUS_ADDR_vco_offset) # address outside "dpll_wrapper"
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
        self.vco_amplitude_in_volt = amplitude
        vco_amplitude = round(amplitude*(2**15-1)) #15 bits, because amplitude is signed
        self.dev.write_Zynq_register_uint32(BUS_ADDR_vco_amplitude, vco_amplitude) # address outside "dpll_wrapper"

    def get_internal_VCO_amplitude(self):
        raw = self.dev.read_Zynq_register_uint32(BUS_ADDR_vco_amplitude) # address outside "dpll_wrapper"
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

        self.dev.write_Zynq_register_uint32(BUS_ADDR_vco_mux, data) # address outside "dpll_wrapper"
        if data == 0 :
            self.output_vco = [0, 0, 0]
        elif data == 1:
            self.output_vco = [1, 0, 0]
        elif data == 2:
            self.output_vco = [0, 1, 0]

    def get_mux_vco(self):
        mux_value = self.dev.read_Zynq_register_uint32(BUS_ADDR_vco_mux) # address outside "dpll_wrapper"
        if mux_value == 0 :
            self.output_vco = [0, 0, 0]
        elif mux_value == 1:
            self.output_vco = [1, 0, 0]
        elif mux_value == 2:
            self.output_vco = [0, 1, 0]
        return mux_value


class DataAcquisition:
    # everything for reading time domain signals, frequency counters, dacs, leds, etc...
    def __init__(self):
        # Communication Locks
        self.bDDR2InUse = False  # TODO: change to threading.lock
        self.RAM_lock = threading.Lock()

        # Triangular averaging is on by default:
        self.bTriangularAveraging = 1

        # this holds a sample number used to make sure that we don't grab the same counter samples twice
        self.last_zdtc_samples_number_counter = [0, 0]

        self.last_freq_update = 0
        self.new_freq_setting_number = 0

    ###########################################################################
    #--- Frequency Counters:
    ###########################################################################
    #

    #--------------------------------------------------------------------------
    # Frequency Counters Helper Functions:
    #

    def scaleCounterReadingsIntoHz(self, freq_counter_samples):

        # Scale the counter values into Hz units:
        # f = data_out * fs / 2^N_INPUT_BITS / conversion_gain
        N_INPUT_BITS = DDC_FREQ_N_BITS
        if self.bTriangularAveraging:
            conversion_gain = COUNTER_GATE_TIME_N_CYCLES * (COUNTER_GATE_TIME_N_CYCLES + 1)
        else:
            # Rectangular averaging:
            conversion_gain = COUNTER_GATE_TIME_N_CYCLES
        freq_counter_samples = freq_counter_samples * ADC_CLK_Hz / 2**(N_INPUT_BITS) / conversion_gain
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
        # bTriangular = 1 means triangular averaging, bTriangular = 0 means rectangular averaging
        self.dev.write_Zynq_register_uint16(
                dpll_write_address(BUS_ADDR_triangular_averaging),
                bTriangular)
        self.bTriangularAveraging = bTriangular

    def getCounterMode(self):
        self.bTriangularAveraging = self.dev.read_Zynq_register_uint16(
                dpll_read_address(BUS_ADDR_triangular_averaging))
        return self.bTriangularAveraging

    def read_dual_mode_counter(self, output_number):
        # fetch data
        # reading at this address samples all frequency counter data at the same time (see registers_read.vhd for details)
        zdtc_samples_number_counter = self.dev.read_Zynq_register_uint32(BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER*4)
        increments = zdtc_samples_number_counter - self.last_zdtc_samples_number_counter[output_number]
        if increments != 0:
            # # this is used only for internal testing of the frequency counter's transfer function
            # if output_number == 0:
            #     if zdtc_samples_number_counter-self.last_freq_update == 50 or self.last_freq_update == 0:
            #         self.new_freq_setting()
            #         self.last_freq_update = zdtc_samples_number_counter
            # we have new unread samples
            freq_counter0_sample = self.dev.read_Zynq_register_int64(
                    dpll_write_address(BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS), # use write address, legacy "Opal Kelly" I/O
                    dpll_write_address(BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS))
            freq_counter1_sample = self.dev.read_Zynq_register_int64(
                    dpll_write_address(BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS), # use write address, legacy "Opal Kelly" I/O
                    dpll_write_address(BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS))
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
                dpll_write_address(BUS_ADDR_DAC0_CURRENT)) # use write address, legacy "Opal Kelly" I/O
        dac1_samples = self.dev.read_Zynq_register_int16(
                dpll_write_address(BUS_ADDR_DAC1_CURRENT)) # use write address, legacy "Opal Kelly" I/O

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
        # Wait, seems necessary because setting the DDR2Logger to 'read' mode overrides the 'write' mode
        write_delay = 1.1*1024*(int(self.Num_samples_write/1024) + 1)/(ADC_CLK_Hz/2)
#        print('Waiting for the DDR to fill up... (%f secs)' % ((write_delay)))
        time.sleep(write_delay)
#        print('Done!')

    #--------------------------------------------------------------------------
    # Read/Write Data Logger Parameters:
    #

    def setup_write(self, selector, Num_samples):
        self.Num_samples_write = int(Num_samples)  # no such restriction with the Red Pitaya implementation
        self.Num_samples_read = self.Num_samples_write

        # Select which data bus to put in the RAM:
        self.last_selector = selector
        self.dev.set_wire_in_value(BUS_ADDR_MUX_SELECTORS, self.last_selector)


    def setup_ADC0_write(self, Num_samples):
        self.setup_write(SELECT_ADC0, Num_samples)

    def setup_ADC1_write(self, Num_samples):
        self.setup_write(SELECT_ADC1, Num_samples)

    def setup_DDC0_write(self, Num_samples):
        self.setup_write(SELECT_DDC0, Num_samples)

    def setup_DDC1_write(self, Num_samples):
        self.setup_write(SELECT_DDC1, Num_samples)

    def setup_counter_write(self, Num_samples):
        self.setup_write(SELECT_COUNTER, Num_samples)

    def setup_DAC0_write(self, Num_samples):
        self.setup_write(SELECT_DAC0, Num_samples)

    def setup_DAC1_write(self, Num_samples):
        self.setup_write(SELECT_DAC1, Num_samples)

    def setup_DAC2_write(self, Num_samples):
        self.setup_write(SELECT_DAC2, Num_samples)

    def trigger_write(self):
        ''' Trigger writing to the data logger.'''
        # Start writing data to the BRAM:
        self.dev.write_Zynq_register_uint32(BUS_ADDR_TRIG_WRITE, 0) # address outside of "dpll_wrapper"
        #self.dev.ActivateTriggerIn(self.ENDPOINT_CMD_TRIG, self.TRIG_CMD_STROBE)

    def read_raw_bytes_from_DDR2(self):

        bytes_per_sample = 2
        Num_bytes_read = self.Num_samples_read*bytes_per_sample

        data_buffer = self.dev.read_Zynq_buffer_16(self.Num_samples_read)

        if Num_bytes_read != len(data_buffer):
            print('Error: did not receive the expected number of bytes. expected: %d, Received: %d' % (Num_bytes_read, len(data_buffer)))

        return data_buffer

    def read_adc_samples_from_DDR2(self):

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
        N_delay_between_ref_exp_and_datastream = 4 #TODO: make this 0 delay on the FPGA!
        if (self.last_selector == 0 or self.last_selector == 1):
            # ADC 0 or 1
            phase_increment_int = self.ddc_phase_incr_int[self.last_selector]
            ref_exp = ref_exp * np.exp(-1j*2*np.pi*N_delay_between_ref_exp_and_datastream*(float(phase_increment_int)/float(2**48)))
            # Strip off the samples that were used to pass side information
            samples_out = samples_out[magic_bytes_expected_position+1:]
        else:
            # Other (DAC0, DAC1 or DAC2): there is no ref exp in the samples
            ref_exp = 1
            samples_out = samples_out
        # Now ref_exp contains the reference phasor, aligned with the first sample that this function will return

        return (samples_out, ref_exp)

    def read_dac_samples_from_DDR2(self):
        data_buffer = self.read_raw_bytes_from_DDR2()
        samples_out = np.frombuffer(data_buffer, dtype=np.int16)
        return samples_out

    def read_ddc_samples_from_DDR2(self):
        data_buffer = self.read_raw_bytes_from_DDR2()
        samples_out = np.frombuffer(data_buffer, dtype=np.int16)
        # The samples represent instantaneous frequency as: samples_out = diff(phi)/(2*pi*fs) * 2**12, where phi is the phase in radians
        inst_freq = (samples_out.astype(dtype=float)) * DDC_FREQ_HZ_INT
        # print('Mean frequency error = %f Hz' % np.mean(inst_freq))
        return inst_freq

    def read_counter_samples_from_DDR2(self):
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
        frequency_axis = (self.first_modulation_frequency + self.modulation_frequency_step * np.array(range(self.number_of_frequencies), dtype=np.uint64)).astype(np.float64)/2**48*ADC_CLK_Hz

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

        single_bit = (value >> N_bit) % 2
        return single_bit

    #--------------------------------------------------------------------------
    # Read/Write LEDs and Status Flags Parameters:
    #

    def readLEDs(self):

        # We first need to check if the fifo has enough samples to send us:
        # status_flags = self.dev.get_wire_out_value(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
        status_flags = self.dev.read_Zynq_register_uint32(
                dpll_write_address(BUS_ADDR_STATUS_FLAGS)) # use write address, legacy "Opal Kelly" I/O
        # print(status_flags)

        LED_G0        = self.extractBit(status_flags, 4)
        LED_R0        = self.extractBit(status_flags, 5)

        LED_G1        = self.extractBit(status_flags, 6)
        LED_R1        = self.extractBit(status_flags, 7)

        LED_G2        = self.extractBit(status_flags, 8)
        LED_R2        = self.extractBit(status_flags, 9)

        return (LED_G0, LED_R0, LED_G1, LED_R1, LED_G2, LED_R2)

    def readStatusFlags(self):

        # We first need to check if the fifo has enough samples to send us:

        # status_flags = self.dev.get_wire_out_value(self.ENDPOINT_STATUS_FLAGS_OUT) # get value from dev object into our script
        status_flags = self.dev.read_Zynq_register_uint32(
                dpll_write_address(BUS_ADDR_STATUS_FLAGS)) # use write address, legacy "Opal Kelly" I/O
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


#%% Red Pitaya Constants
"""
TODO: document constants...
"""

###########################################################################
#--- System Constants:
###########################################################################
# STEMlab 125-14
#

#--------------------------------------------------------------------------
# Primary ADC Inputs:
#

ADC_CLK_Hz = int(125e6)  # ADC sampling rate

ADC_N_BITS = 16 # actual output is 14, but 16 are used internally
ADC_INT_HR = 2**(ADC_N_BITS-1)-1 # Signed integers per half range, N/HR
ADC_V_HR = 1 # Voltage input per half range, V/HR
ADC_V_INT = ADC_V_HR/ADC_INT_HR # Voltage per integer, V/N

#--------------------------------------------------------------------------
# Primary DAC Outputs:
#

DAC_CLK_Hz = int(125e6)  # DAC sampling rate

DAC_N_BITS = 16 # actual output is 14, but 16 are used internally
DAC_INT_HR = 2**(DAC_N_BITS-1)-1 # Signed integers per half range, N/HR
DAC_V_HR = 1 # Voltage output per half range, V/HR
DAC_V_INT = DAC_V_HR/DAC_INT_HR # Voltage per integer, V/N

DAC_LIM_LOW_INT = [-DAC_INT_HR, -DAC_INT_HR, 0] # Hardware Limits
DAC_LIM_HIGH_INT = [DAC_INT_HR, DAC_INT_HR, 0]

###########################################################################
#--- Zynq Register Commands:
###########################################################################
#

MAGIC_BYTES_WRITE_REG       = 0xABCD1233
MAGIC_BYTES_READ_REG        = 0xABCD1234
MAGIC_BYTES_READ_BUFFER     = 0xABCD1235

MAGIC_BYTES_WRITE_FILE      = 0xABCD1237
MAGIC_BYTES_SHELL_COMMAND   = 0xABCD1238
MAGIC_BYTES_REBOOT_MONITOR  = 0xABCD1239

###########################################################################
#--- Red Pitaya Top Module:
###########################################################################
# red_pitaya_top.v
#

# Red Pitaya Top Zynq Address:
RP_TOP_ADDR = 0x40000000

#--------------------------------------------------------------------------
# System Bus Read/Write Enable Decoder and Multiplexer:
#

# Red Pitaya Code Segment Address Offsets:
DPLL_CS =           (0 << (6-1)*4 ) # DPLL write and legacy "Opal Kelly" IO
DATA_LOGGER_CS =    (1 << (6-1)*4 ) # Data Logger
DPLL_READ_CS =      (2 << (6-1)*4 ) # DPLL read
RP_HK_CS =          (3 << (6-1)*4 ) # Red Pitaya house keeping (HK)
RP_AMS_CS =         (4 << (6-1)*4 ) # Red Pitaya analog mixed signlas (AMS)
VCO_MUX_CS =        (5 << (6-1)*4 ) # VCO Output MUX
VCO_CS =            (6 << (6-1)*4 ) # VCO
FREE_CS =           (7 << (6-1)*4 ) # not actively used

###########################################################################
#--- DPLL:
###########################################################################
# dpll_wrapper.v
#

# Internal DPLL offset to Zynq Compatible Offset Address Multiplier:
DPLL_MLTP = 4

def dpll_read_address(dpll_addr_offset):
    #TODO: default value for uninitialized RAM is 0xEFFFFFFF...
    bus_address = DPLL_READ_CS + DPLL_MLTP*dpll_addr_offset
    return bus_address

def dpll_write_address(dpll_addr_offset):
    bus_address = DPLL_CS + DPLL_MLTP*dpll_addr_offset
    return bus_address

#--------------------------------------------------------------------------
# Reset Signals:
#

# Reset Address Offsets:
BUS_ADDR_TRIG_RESET_FRONTEND = 0x0044

#--------------------------------------------------------------------------
# Digital Down Conversion (DDC):
#

# DDC Address Offsets:
BUS_ADDR_DDC_FILT_SEL = 0x8002
BUS_ADDR_DDC_ANGLE_SEL = 0x8004

# DDC 0 Address Offsets:
BUS_ADDR_REF_FREQ0_LSBs = 0x8000
BUS_ADDR_REF_FREQ0_MSBs = 0x8001

# DDC 1 Address Offsets:
BUS_ADDR_REF_FREQ1_LSBs = 0x8010
BUS_ADDR_REF_FREQ1_MSBs = 0x8011

# DDC Direct Digital Synthesis (DDS) Local Oscilator Constants:
DDC_DDS_PHASE_ACCUM_N_BITS = 48
DDC_DDS_FREQ_INT_HR = 2**(DDC_DDS_PHASE_ACCUM_N_BITS-2)
DDC_DDS_FREQ_Hz_HR = 1/2 * ADC_CLK_Hz/2
DDC_DDS_FREQ_Hz_INT = DDC_DDS_FREQ_Hz_HR/DDC_DDS_FREQ_INT_HR

# DDC Constants:
# Number of fractional bits (phase ranges from (-1 to 1-2**-N) * pi).
# The CORDIC implementation actually outputs 2 additional integer bits, but
# these bits are discarded since they are empty when the output is in
# "Scaled Radians" (-pi to pi -> -1 to 1). See the LogiCore CORDIC product
# guide for details.
DDC_SR_PHASE_N_BITS = DDC_FREQ_N_BITS = 10
DDC_SR_PHASE_INT_HR = DDC_FREQ_INT_HR = 2**(DDC_SR_PHASE_N_BITS-1)-1 # Signed integers per half range, N/HR
DDC_PHASE_SR_HR = 1 - 2**(-DDC_SR_PHASE_N_BITS) # Scaled radians per half range, SR/HR
# The frequency offset is calculated as the cycle difference per clock cycle
DDC_FREQ_Hz_HR = DDC_PHASE_SR_HR * ADC_CLK_Hz/2 # Frequency per half range, Hz/HR
DDC_FREQ_HZ_INT = DDC_FREQ_Hz_HR/DDC_FREQ_INT_HR # Frequency per integer, Hz/N

#--------------------------------------------------------------------------
# Loop Filters:
#

LF_CHANNELS = 3

# Error Signal Unit Conversion
LF_ERR_SIG_BITS = DDC_FREQ_N_BITS
LF_ERR_SIG_INT_HR = 2**(LF_ERR_SIG_BITS-1)-1 # Signed integers per half range, N/HR
LF_ERR_SIG_Hz_INT = DDC_FREQ_Hz_HR/LF_ERR_SIG_INT_HR # Frequency error per integer, Hz/N
LF_ERR_SIG_V_INT = DAC_V_HR/LF_ERR_SIG_INT_HR # Voltage error per integer, V/N

# Loop Filters Address Offsets:
BUS_ADDR_PLL_BASE = [0x7000, 0x7010, 0x7020]
BUS_OFFSET_LOCK = 0x0       # [0x7000, 0x7010, 0x7020]
BUS_OFFSET_GAIN_P = 0x1     # [0x7001, 0x7011, 0x7021]
BUS_OFFSET_GAIN_I_LSBs = 0x2     # [0x7002, 0x7012, 0x7022]
BUS_OFFSET_GAIN_I_MSBs = 0x3     # [0x7003, 0x7013, 0x7023]
BUS_OFFSET_GAIN_II_LSBs = 0x4    # [0x7004, 0x7014, 0x7024]
BUS_OFFSET_GAIN_II_MSBs = 0x5    # [0x7005, 0x7015, 0x7025]
BUS_OFFSET_GAIN_D = 0x6     # [0x7006, 0x7016, 0x7026]
BUS_OFFSET_COEF_DF = 0x7    # [0x7007, 0x7017, 0x7027]
BUS_OFFSET_GAIN_OL = 0x8    # [0x7008, 0x7018, 0x7028]
BUS_OFFSET_LF_SIGN = 0x9    # [0x7009, 0x7019, 0x7029]
BUS_OFFSET_MAN_OFFSET_LSBs = 0xA    # [0x700A, 0x701A, 0x702A]
BUS_OFFSET_MAN_OFFSET_MSBs = 0xB    # [0x700B, 0x701B, 0x702B]


# Loop Filter Constants:
N_BITS_DIVIDE_P =  [16, 16, 0]
N_BITS_DIVIDE_I =  [48, 48, 20]
N_BITS_DIVIDE_II = [48, 48, 38]
N_BITS_DIVIDE_D =  [0, 0, 0]
N_BITS_DIVIDE_DF = [18, 18, 0]

N_BITS_GAIN_P =  [32, 32, 0]
N_BITS_GAIN_I =  [64, 64, 64]
N_BITS_GAIN_II = [64, 64, 64]
N_BITS_GAIN_D =  [32, 32, 0]
N_BITS_COEF_DF = [18, 18, 0]

N_CYCLS_DELAY_P = [5]*3 # TODO: put the correct values here
N_CYCLES_DELAY_I = [8]*3 # TODO: put the correct values here
N_CYCLES_DELAY_II = [10]*3 # TODO: put the correct values here
N_CYCLES_DELAY_D = [12]*3 # TODO: put the correct values here

# Channel 1 Loop Filter Input Multiplexer Address Offset:
BUS_ADDR_MUX_PLL1 = 0x9000

#--------------------------------------------------------------------------
# Dither and Lock-In:
#

# Dither and Lock-in settings:
BUS_ADDR_dither_enable = [0x8100, 0x8200, 0x8300]
BUS_ADDR_dither_period_divided_by_4_minus_one = [0x8101, 0x8201, 0x8301]
BUS_ADDR_dither_N_periods_minus_one = [0x8102, 0x8202, 0x8302]
BUS_ADDR_dither_amplitude = [0x8103, 0x8203, 0x8303]
BUS_ADDR_dither_mode_auto = [0x8104, 0x8204, 0x8304] # For reconnection purpose

#--------------------------------------------------------------------------
# Vector Network Analyzer (VNA)
#

# VNA Address Offsets:
BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION                 = 0x0042
BUS_ADDR_number_of_cycles_integration               = 0x5000
BUS_ADDR_first_modulation_frequency_lsbs            = 0x5001
BUS_ADDR_first_modulation_frequency_msbs            = 0x5002
BUS_ADDR_modulation_frequency_step_lsbs             = 0x5003
BUS_ADDR_modulation_frequency_step_msbs             = 0x5004
BUS_ADDR_number_of_frequencies                      = 0x5005
BUS_ADDR_output_gain                                = 0x5006
BUS_ADDR_input_and_output_mux_selector              = 0x5007
BUS_ADDR_VNA_mode_control                           = 0x5008

# VNA Direct Digital Synthesis (DDS) Local Oscilator Constants:
VNA_DDS_PHASE_ACCUM_N_BITS = 48 #TODO: make these distinct IPs from the DDC

#--------------------------------------------------------------------------
# Primary DAC Outputs:
#

# Primary DAC Output Address Offsets:
BUS_ADDR_DAC_offset = [0x6000, 0x6001, 0x6002]
BUS_ADDR_dac0_limits = 0x6101
BUS_ADDR_dac1_limits = 0x6102
BUS_ADDR_dac2_limit_low = 0x6103 # not actively used
BUS_ADDR_dac2_limit_high = 0x6104 # not actively used

#--------------------------------------------------------------------------
# Pulse Width Managed (PWM) DAC Outputs:
#

# PWM DAC Address Offsets:
BUS_ADDR_PWM0                                       = 0x6621

#--------------------------------------------------------------------------
# Frequency Counters:
#

# Frequency Counters Address Offsets:
BUS_ADDR_triangular_averaging = 0x8501

# Gate Time in Number of Samples for the Frequency Counter:
COUNTER_GATE_TIME_N_CYCLES = int(125e6)

#--------------------------------------------------------------------------
# Residuals Monitor:
#

# Redisuals Monitor Address Offsets:
BUS_ADDR_phase_residuals_threshold = [0x8400, 0x8401]
BUS_ADDR_freq_residuals0_threshold = 0x8410

#--------------------------------------------------------------------------
# Data Logger Interface:
#

# Data Logger Multiplexer Address Offset:
BUS_ADDR_MUX_SELECTORS  = 0x0003

# Data Logger Multiplexer Constants:
SELECT_ADC0             = 0
SELECT_ADC1             = 1
SELECT_DDC0             = 2
SELECT_DDC1             = 3
SELECT_VNA              = 4
SELECT_COUNTER          = 5
SELECT_DAC0             = 6
SELECT_DAC1             = 7
SELECT_DAC2             = 8
SELECT_CRASH_MONITOR    = 2**4
SELECT_IN10             = 2**4 + 2**3

#--------------------------------------------------------------------------
# Legacy "Opal Kelly" Interface:
#

# Status Flags Address Offset:
BUS_ADDR_STATUS_FLAGS = 0x0025

# Dither Lock-In Address Offsets:
BUS_ADDR_DITHER0_LOCKIN_REAL_LSB = 0x0026
BUS_ADDR_DITHER0_LOCKIN_REAL_MSB = 0x0027 # must be read after 0x0026
BUS_ADDR_DITHER1_LOCKIN_REAL_LSB = 0x0029
BUS_ADDR_DITHER1_LOCKIN_REAL_MSB = 0x002A # must be read after 0x0029

# Counter and DAC Stream Address Offsets:
BUS_ADDR_ZERO_DEADTIME_SAMPLES_NUMBER = 0x0030
BUS_ADDR_ZERO_DEADTIME_COUNTER0_LSBS = 0x0031 # must be read after 0x0030
BUS_ADDR_ZERO_DEADTIME_COUNTER0_MSBS = 0x0032 # must be read after 0x0030
BUS_ADDR_ZERO_DEADTIME_COUNTER1_LSBS = 0x0033 # must be read after 0x0030
BUS_ADDR_ZERO_DEADTIME_COUNTER1_MSBS = 0x0034 # must be read after 0x0030
BUS_ADDR_DAC0_CURRENT = 0x0035 # must be read after 0x0030
BUS_ADDR_DAC1_CURRENT = 0x0036 # must be read after 0x0030

# FIFO Address Offsets:
BUS_ADDR_FIFO_TOUT = 0x0037 # not actively used
BUS_ADDR_FIFO_EMPTY = 0x0038 # not actively used
BUS_ADDR_FIFO_DOUT = 0x0039 # not actively used
BUS_ADDR_FIFO_COUNT = 0x0040 # not actively used
BUS_ADDR_FIFO_WRT_ENABLE = 0x0041 # not actively used
BUS_ADDR_FIFO_RESET = 0x0042 # !!!: Conflict with BUS_ADDR_TRIG_SYSTEM_IDENTIFICATION

###########################################################################
#--- Data Logger:
###########################################################################
# ram_data_logger.vhd
#

BUS_ADDR_TRIG_WRITE = DATA_LOGGER_CS + 0x1004    # writing anything to this address triggers the write mode in ram_data_logger.vhd
# NOTE THAT THIS MODULE (ram_data_logger.vhd) IS IMPLEMENTED OUTSIDE OF DPLL_WRAPPER.V AND THUS IT is part of a different address mapping: this is a direct address offset in the Zynq address space, contrary to most of the other addresses here, which are multiplied by 4 by the conversion layer to avoid breaking 32 bits boundaries

MAX_SAMPLES_READ_BUFFER = 2**15 # should be equal to 2**ADDRESS_WIDTH from ram_data_logger.vhd

###########################################################################
#--- DPLL Read:
###########################################################################
# addr_packed.vhd
#

# Default value returned from uninitiated ram
DPLL_READ_DEFAULT = 0xEFFFFFFF

###########################################################################
#--- House Keeping (HK):
###########################################################################
# red_pitaya_hk.v
#

#--------------------------------------------------------------------------
# Auxiliary Components
#

BUS_ADDR_FAN_PWR = (3 << 20) + 0x18

###########################################################################
#--- Analog Mixed Signals (AMS):
###########################################################################
# red_pitaya_ams.v
#

# ...contains parameters related to the XADC and slow PWM DAC controls

###########################################################################
#--- VCO:
###########################################################################
# mux_internal_vco.vhd
#

# Address to change the amplitude and the offset of the VCO
BUS_ADDR_vco_amplitude = (6 << 20) + 0x00000
BUS_ADDR_vco_offset = (5 << 20) + 0x00004

# This mux connect the VCO to the selected DAC
BUS_ADDR_vco_mux = (5 << 20) + 0x00000


#%% Helper Classes

class SocketPlaceholder():
    def __init__(self):
        pass

    def sendall(self, *args, **kwargs):
        print("SocketPlaceholder::sendall(): No active socket. Was called from {}".format(sys._getframe().f_back.f_code.co_name))
        pass

    def recv(self, *args, **kwargs):
        print("SocketPlaceholder::recv(): No active socket")
        return []


#%% Helper Functions

def set_bits(bit_values, N_bit_start_loc, bit_length=1):
    assert isinstance(bit_values, int)
    assert isinstance(N_bit_start_loc, int)
    assert isinstance(bit_length, int)

    if bit_values.bit_length() > bit_length:
        raise ValueError("{:} is greater than {:} bits".format(bit_values, bit_length))
    return bit_values << N_bit_start_loc

def get_bits(bit_values,  N_bit_start_loc, bit_length=1):
    assert isinstance(N_bit_start_loc, int)
    assert isinstance(bit_length, int)

    return (bit_values >> N_bit_start_loc) % 2**bit_length