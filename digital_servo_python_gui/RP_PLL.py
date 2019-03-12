# -*- coding: utf-8 -*-

from __future__ import print_function
import socket
import struct
import time

import sys

import numpy as np
#import matplotlib.pyplot as plt

class socket_placeholder():
    def __init__(self):
        pass
    def sendall(self, *args, **kwargs):
        print("socket_placeholder::sendall(): No active socket. Was called from {}".format(sys._getframe().f_back.f_code.co_name))
        pass
    def recv(self, *args, **kwargs):
        print("socket_placeholder::recv(): No active socket")
        return []

class RP_PLL_device():
    ###########################################################################
    #--- System Constants:
    ###########################################################################
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

    DAC_CLK_Hz = int(62.5e6)  # DAC sampling rate

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

    #--------------------------------------------------------------------------
    # Reset Signals:
    #

    # Reset Address Offsets:
    BUS_ADDR_TRIG_RESET_FRONTEND = 0x0044

    #--------------------------------------------------------------------------
    # Digital Down Conversion (DDC):
    #

    # DDC Address Offsets:
    BUS_ADDR_ddc_filter_select = 0x8002
    BUS_ADDR_ddc_angle_select = 0x8004

    # DDC 0 Address Offsets:
    BUS_ADDR_ref_freq0_lsbs = 0x8000
    BUS_ADDR_ref_freq0_msbs = 0x8001

    # DDC 1 Address Offsets:
    BUS_ADDR_REF_FREQ1_LSBs = 0x8010
    BUS_ADDR_REF_FREQ1_MSBs = 0x8011

    # DDC Direct Digital Synthesis (DDS) Local Oscilator Constants:
    DDC_DDS_PHASE_ACCUM_N_BITS = 48

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
    DDC_FREQ_Hz_HR = DDC_PHASE_SR_HR/2 * ADC_CLK_Hz # Frequency per half range, Hz/HR
    DDC_FREQ_INT = DDC_FREQ_Hz_HR/DDC_FREQ_INT_HR # Frequency per integer, Hz/N

    #--------------------------------------------------------------------------
    # Loop Filters:
    #

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
    BUS_OFFSET_GAIN_OL = 0x8 #[0x9010, 0x9011, 0x9012]

    # Loop Filter Constants:
    N_BITS_DIVIDE_P = [16]*3
    N_BITS_DIVIDE_I = [48]*3
    N_BITS_DIVIDE_II = [48]*3
    N_BITS_DIVIDE_D = [0]*3
    N_BITS_DIVIDE_DF = [18]*3

    # Loop Filter Constants:
    N_BITS_GAIN_P = [32]*3
    N_BITS_GAIN_I = [64]*3
    N_BITS_GAIN_II = [64]*3
    N_BITS_GAIN_D = [32]*3
    N_BITS_COEF_DF = [18]*3

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
    BUS_ADDR_DAC_offset = [0x6000, 0x6001, 0x6002] # 0x6002 not actively used
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

    ###########################################################################
    #--- Initialization:
    ###########################################################################
    #

    def __init__(self, controller = None):
        self.sock = socket_placeholder()
        self.controller = controller
        self.valid_socket = 0
        return

    ###########################################################################
    #--- Red Pitaya System Commands:
    ###########################################################################
    #

    def CloseTCPConnection(self):
        print("RP_PLL_device::CloseTCPConnection()")
        self.sock = socket_placeholder()
        self.valid_socket = 0

    def OpenTCPConnection(self, HOST, PORT=5000):
        print("RP_PLL_device::OpenTCPConnection(): HOST = '%s', PORT = %d" % (HOST, PORT))
        self.HOST = HOST
        self.PORT = PORT
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # self.sock.setblocking(1)
        self.sock.settimeout(2)
        self.sock.connect((self.HOST, self.PORT))
        self.valid_socket = 1

    # Function used to send a file write command:
    def write_file_on_remote(self, strFilenameLocal, strFilenameRemote):
        # open local file and load into memory:
        file_data = np.fromfile(strFilenameLocal, dtype=np.uint8)
        try:
            # send header
            packet_to_send = struct.pack('<III', self.MAGIC_BYTES_WRITE_FILE, len(strFilenameRemote), len(file_data))
            self.sock.sendall(packet_to_send)
            # send filename
            self.sock.sendall(strFilenameRemote.encode('ascii'))
            # send actual file
            self.sock.sendall(file_data.tobytes())
        except:
            print("RP_PLL.py: write_file_on_remote(): exception while sending file!")
            self.controller.stopCommunication()

    # Function used to send a shell command to the Red Pitaya:
    def send_shell_command(self, strCommand):

        try:
            # send header
            packet_to_send = struct.pack('<III', self.MAGIC_BYTES_SHELL_COMMAND, len(strCommand), 0)
            self.sock.sendall(packet_to_send)
            # send filename
            self.sock.sendall(strCommand.encode('ascii'))
        except:
            print("RP_PLL.py: send_shell_command(): exception while sending command!")
            self.controller.stopCommunication()

    # Function used to reboot the monitor-tcp program
    def send_reboot_command(self):

        try:
            # send header
            packet_to_send = struct.pack('<III', self.MAGIC_BYTES_REBOOT_MONITOR, 0, 0)
            self.sock.sendall(packet_to_send)
        except:
            print("RP_PLL.py: send_reboot_command(): exception while sending command!")
            self.controller.stopCommunication()

    ###########################################################################
    #--- Zynq I/O Helper Functions
    ###########################################################################
    #

    def dpll_read_address(self, dpll_addr_offset): #TODO: default value for uninitialized RAM is 0xEFFFFFFF...
        bus_address = self.DPLL_READ_CS + self.DPLL_MLTP*dpll_addr_offset
        return bus_address

    def dpll_write_address(self, dpll_addr_offset):
        bus_address = self.DPLL_CS + self.DPLL_MLTP*dpll_addr_offset
        return bus_address

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
            packet_to_send = struct.pack('<II',
                                         self.MAGIC_BYTES_WRITE_REG,
                                         self.RP_TOP_ADDR + address_uint32)
            packet_to_send = packet_to_send + data_buffer
            self.sock.sendall(packet_to_send)
        except:
            print("Unexpected error when writing Zynq register: ",
                  sys.exc_info()[0])
            self.controller.stopCommunication()
            raise

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
        # Limit the number of 16 bit points
        if number_of_points > self.MAX_SAMPLES_READ_BUFFER:
            number_of_points = self.MAX_SAMPLES_READ_BUFFER
            print("number of points clamped to %d." % number_of_points)
        # Read stream of 16 bit data from the Zynq buffer
        try:
            packet_to_send = struct.pack('<III',
                                         self.MAGIC_BYTES_READ_BUFFER,
                                         self.RP_TOP_ADDR,
                                         number_of_points)
            self.sock.sendall(packet_to_send)
            data_buffer = self.recvall(int(2*number_of_points)) # read number_of_points samples (16 bits each)
        except:
            print("Unexpected error when reading Zynq buffer: ",
                  sys.exc_info()[0])
            self.controller.stopCommunication()
            raise
        # Return unaltered data buffer
        if data_buffer is None:
            data_buffer = bytes()
        return data_buffer

    # Read 32 bit Zynq Register -----------------------------------------------
    def read_Zynq_register_32(self, address_uint32):
        # Check address alignment
        if address_uint32 % 4:
            raise OSError(('Address {:X} is not evenly divisible by 4.'
                           ' The implemented Zynq registers have offsets'
                           ' aligned to 4 bytes').format(address_uint32))
        # Read 32 bits from the Zynq register
        try:
            packet_to_send = struct.pack('<III',
                                         self.MAGIC_BYTES_READ_REG,
                                         self.RP_TOP_ADDR + address_uint32,
                                         0)  # last value is reserved
            self.sock.sendall(packet_to_send)
            data_buffer = self.recvall(4)   # read 4 bytes (32 bits)
        except:
            print("Unexpected error when reading Zynq register: ",
                  sys.exc_info()[0])
            self.controller.stopCommunication()
            raise
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

    def SetWireInValue(self, endpoint, value_16bits):
        # this only needs to update the internal state
        # for this, there would need to be two versions of the internal state, so that we can diff them and commit only the addresses that have changed
        # but its much simpler for now to just commit the change directly

        #print('SetWireInValue(): TODO')

        # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values
        if value_16bits < 0:
            # write as a signed value
            self.write_Zynq_register_int32(endpoint*4, value_16bits)
        else:
            # write as an unsigned value
            self.write_Zynq_register_uint32(endpoint*4, value_16bits)

    def GetWireOutValue(self, endpoint):
        # print('GetWireOutValue(): TODO')
        # this reads a single 32-bits value from the fpga registers
        # the Opal Kelly code expected a 16-bits value, so we mask them out for compatibility
        rep = self.read_Zynq_register_uint32(4*endpoint)
        return rep & 0xFFFF # the multiply by 4 is because right now the zynq code doesn't work unless reading on a 32-bits boundary, so we map the addresses to different values


def main():
    import matplotlib.pyplot as plt
    rp = RP_PLL_device()
    rp.OpenTCPConnection("192.168.1.100")
    #rp.sock.sendall(struct.pack('=IHhIiIhd', 0xABCD1236, 0, -8*1024, 3, 16*1024, 5, -1, 1.0000000000000004))
    magic_bytes_flank_servo = 0xABCD1236
    iStopAfterZC = 1    # 1 or 0 (true or false)
    ramp_minimum = -8*1024  # -8*1024 is the minimum of the DAC output (-1V into 50 ohms)
    number_of_ramps = 3
    number_of_steps = 16*1024   # 16*1024 is the full span of the dac output (2 Vpp into 50 ohms)
    max_iterations = 500000
    threshold_int16 = 2300
    ki = 1e-3

    print("calling sendall")
    for k in range(1):
        rp.sock.sendall(struct.pack('=IHhIiIhd', magic_bytes_flank_servo, iStopAfterZC,
                                    ramp_minimum, number_of_ramps, number_of_steps,
                                    max_iterations, threshold_int16, ki))
        print("after sendall, calling recvall")
        if max_iterations != 0:
            data_buffer = rp.recvall((number_of_ramps*number_of_steps+max_iterations)*2*2)
            print("after recvall")
            data_np = np.fromstring(data_buffer, dtype=np.int16)
    print('before sleep')
    if max_iterations == 0:
        time.sleep(5)
    print('after sleep')
    rp.sock.close()



    if max_iterations != 0:
        # show data
        plt.close('all')
        plt.figure()
        plt.plot(data_np[1::2], data_np[0::2])
        plt.figure()
        plt.plot(data_np[0::2])
        plt.figure()
        plt.plot(data_np[1::2])

        return data_np
    else:
        return 0

def main2():
#if 1:
    rp = RP_PLL_device()
    rp.OpenTCPConnection("192.168.2.12")

#    rp.write_file_on_remote(strFilenameLocal='d:\\test_file.bin', strFilenameRemote='/opt/test_file.bin')



    time.sleep(3)
    print("quitting")
    return


    addr_housekeeping = 3
    addr_leds = 0x00030

    address_uint32 = (addr_housekeeping << 20) + addr_leds
    data_uint32 = 8+1*16
    rp.write_Zynq_register_uint32(address_uint32, data_uint32)
#
#   addr_vco = 2Z
#   addr_vco_amplitude = 0x0000
#   addr_vco_freq_msb  = 0x0004
#   addr_vco_freq_lsb  = 0x0008
#
#   vco_amplitude = round(0.01*(2**15-1))
#   vco_freq_word = np.array([round((15e6/100e6+1./600.)*2.**48)]).astype(np.int64)
#   # break vco word into msbs and lsbs:
#   vco_freq_word_msbs = vco_freq_word >> 32
#   vco_freq_word_lsbs = np.bitwise_and(vco_freq_word, (1<<32)-1)
#
#   # write amplitude
#   address_uint32 = (addr_vco << 20) + addr_vco_amplitude
#   data_uint32 = vco_amplitude
#   rp.write_Zynq_register_uint32(address_uint32, data_uint32)
#   # write msbs
#   address_uint32 = (addr_vco << 20) + addr_vco_freq_msb
#   data_uint32 = vco_freq_word_msbs
#   rp.write_Zynq_register_uint32(address_uint32, vco_freq_word_msbs)
#   # write lsbs
#   address_uint32 = (addr_vco << 20) + addr_vco_freq_lsb
#   data_uint32 = vco_freq_word_lsbs
#   rp.write_Zynq_register_uint32(address_uint32, vco_freq_word_lsbs)

    # write some frequency
    addr_dpll = 0
    addr_ref_freq_msb = 0x8001
    address_uint32 = (addr_dpll << 20) + addr_ref_freq_msb*4    # times 4 due to address space translation
    rp.write_Zynq_register_uint32(address_uint32, 0x1000)

    # first trigger a write
    addr_logger = 1
    addr_trig_write = 0x1004
    address_uint32 = (addr_logger << 20) + addr_trig_write
    rp.write_Zynq_register_uint32(address_uint32, 0)

    address_uint32 = 0  # apparently this is currently unused
    number_of_points = rp.MAX_SAMPLES_READ_BUFFER
    data_buffer = rp.read_Zynq_buffer_16(number_of_points)
#   print("after recvall")
    data_np = np.fromstring(data_buffer, dtype=np.int16)
    print(data_np)
    for k in range(10):
        print('%d:\t%s' % (k, hex((data_np[k])&0xFFFF)))
#    print hex(data_np[7])
#    print hex(data_np[7])
#    print hex(data_np[7])

    plt.figure()
    plt.plot(data_np, '.-')

#   spc = np.fft.fft(data_np * np.blackman(len(data_np)))
#   plt.figure()
#   plt.plot(10*np.log10(np.abs(spc)**2.))

#   return data_np

if __name__ == '__main__':
##    data_np = main()
    data_np = main2()





# # Stuff for the initialization, which has to be completely re-done anyway:
# self.dev = ok.FrontPanel()
# n_devices = self.dev.GetDeviceCount()

# self.dev_list[k] = self.dev.GetDeviceListSerial(k)


# self.dev = ok.FrontPanel()

# self.dev.OpenBySerial(self.dev.GetDeviceListSerial(0))

# self.dev.OpenBySerial(str(strSerial))

# #if self.dev.IsOpen():

# error_code = self.dev.ConfigureFPGA(strFirmware)
