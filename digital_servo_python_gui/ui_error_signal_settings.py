"""
DDC and error signal generation settings

"""


from PyQt5 import QtGui, Qt
from digital_servo import SuperLaserLand


class ErrorSignalSettingsUI(QtGui.QWidget):

    def __init__(self, sll, sp, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet='', custom_shorthand=''):
        assert isinstance(sll, SuperLaserLand)

        super(ErrorSignalSettingsUI, self).__init__()

        self.clk_divider_modulus = clk_divider_modulus
        self.bDividerOn = bDividerOn
        self.bPulses = bPulses

        self.sp = sp
        self.sll = sll
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        self.custom_shorthand = custom_shorthand

#        sll.set_clk_divider_settings(bOn=1, bPulses=0, modulus=67e3+1-1)

        self.initUI()


    def initUI(self):
        ######################################################################
        #--- DDC settings
        ######################################################################
        #

        self.qgroupbox_ddc = Qt.QGroupBox('DDC Settings')
        self.qgroupbox_ddc.setAutoFillBackground(True)

        # Wideband/narrowband DDC0:
        self.qlbl_ddc0 = Qt.QLabel('DDC 0 filter BW:')
        self.qchk_Wideband0 = Qt.QRadioButton('Wideband (31 MHz)')
        self.qchk_Narrowband0 = Qt.QRadioButton('Narrowband (7.5 MHz)')
        self.qchk_WidebandFIR0 = Qt.QRadioButton('Wideband FIR (62 MHz)')
        self.qddc0_group = Qt.QButtonGroup(self)
        self.qddc0_group.addButton(self.qchk_Wideband0)
        self.qddc0_group.addButton(self.qchk_Narrowband0)
        self.qddc0_group.addButton(self.qchk_WidebandFIR0)

        self.qchk_Wideband0.setChecked(True)
        self.qchk_Narrowband0.setChecked(False)
        self.qchk_WidebandFIR0.setChecked(False)

        self.qchk_Wideband0.clicked.connect(self.ddcClicked)
        self.qchk_Narrowband0.clicked.connect(self.ddcClicked)
        self.qchk_WidebandFIR0.clicked.connect(self.ddcClicked)

        # DDC0 CORDIC or Quadrature
        self.qlbl_ddc0angle = Qt.QLabel('DDC 0 CORDIC or Quadrature:')
        self.qchk_cordic0 = Qt.QRadioButton('CORDIC')
        self.qchk_quadrature_msb0 = Qt.QRadioButton('Quadrature MSB')
        self.qchk_quadrature_lsb0 = Qt.QRadioButton('Quadrature LSB')
        self.qchk_inphase_msb0 = Qt.QRadioButton('In-Phase MSB')
        self.qchk_inphase_lsb0 = Qt.QRadioButton('In-Phase LSB')
        self.qddc0_group = Qt.QButtonGroup(self)
        self.qddc0_group.addButton(self.qchk_cordic0)
        self.qddc0_group.addButton(self.qchk_quadrature_msb0)
        self.qddc0_group.addButton(self.qchk_quadrature_lsb0)
        self.qddc0_group.addButton(self.qchk_inphase_msb0)
        self.qddc0_group.addButton(self.qchk_inphase_lsb0)

        self.qchk_cordic0.setChecked(True)
        self.qchk_quadrature_msb0.setChecked(False)
        self.qchk_quadrature_lsb0.setChecked(False)

        self.qchk_cordic0.clicked.connect(self.ddcClicked)
        self.qchk_quadrature_msb0.clicked.connect(self.ddcClicked)
        self.qchk_quadrature_lsb0.clicked.connect(self.ddcClicked)
        self.qchk_inphase_msb0.clicked.connect(self.ddcClicked)
        self.qchk_inphase_lsb0.clicked.connect(self.ddcClicked)

        # Wideband/narrowband DDC1:
        self.qlbl_ddc1 = Qt.QLabel('DDC 1 filter BW:')
        self.qchk_Wideband1 = Qt.QRadioButton('Wideband (31 MHz)')
        self.qchk_Narrowband1 = Qt.QRadioButton('Narrowband (7.5 MHz)')
        self.qchk_WidebandFIR1 = Qt.QRadioButton('Wideband FIR (62 MHz)')
        self.qddc1_group = Qt.QButtonGroup(self)
        self.qddc1_group.addButton(self.qchk_Wideband1)
        self.qddc1_group.addButton(self.qchk_Narrowband1)
        self.qddc1_group.addButton(self.qchk_WidebandFIR1)

        self.qchk_Wideband1.setChecked(True)
        self.qchk_Narrowband1.setChecked(False)
        self.qchk_WidebandFIR1.setChecked(False)

        self.qchk_Wideband1.clicked.connect(self.ddcClicked)
        self.qchk_Narrowband1.clicked.connect(self.ddcClicked)
        self.qchk_WidebandFIR1.clicked.connect(self.ddcClicked)

        # DDC1 CORDIC or Quadrature
        self.qlbl_ddc1angle = Qt.QLabel('DDC 1 CORDIC or Quadrature:')
        self.qchk_cordic1 = Qt.QRadioButton('CORDIC')
        self.qchk_quadrature_msb1 = Qt.QRadioButton('Quadrature MSB')
        self.qchk_quadrature_lsb1 = Qt.QRadioButton('Quadrature LSB')
        self.qchk_inphase_msb1 = Qt.QRadioButton('In-Phase MSB')
        self.qchk_inphase_lsb1 = Qt.QRadioButton('In-Phase LSB')
        self.qddc1_group = Qt.QButtonGroup(self)
        self.qddc1_group.addButton(self.qchk_cordic1)
        self.qddc1_group.addButton(self.qchk_quadrature_msb1)
        self.qddc1_group.addButton(self.qchk_quadrature_lsb1)
        self.qddc1_group.addButton(self.qchk_inphase_msb1)
        self.qddc1_group.addButton(self.qchk_inphase_lsb1)

        self.qchk_cordic1.setChecked(True)
        self.qchk_quadrature_msb1.setChecked(False)
        self.qchk_quadrature_lsb1.setChecked(False)

        self.qchk_cordic1.clicked.connect(self.ddcClicked)
        self.qchk_quadrature_msb1.clicked.connect(self.ddcClicked)
        self.qchk_quadrature_lsb1.clicked.connect(self.ddcClicked)
        self.qchk_inphase_msb1.clicked.connect(self.ddcClicked)
        self.qchk_inphase_lsb1.clicked.connect(self.ddcClicked)

        grid = QtGui.QGridLayout()

        grid.addWidget(self.qlbl_ddc0,                0, 0)
        grid.addWidget(self.qchk_Wideband0,           0, 1)
        grid.addWidget(self.qchk_Narrowband0,         0, 2)
        grid.addWidget(self.qchk_WidebandFIR0,        0, 3)

        #FEATURE
        grid.addWidget(self.qlbl_ddc0angle,           1, 0)
        grid.addWidget(self.qchk_cordic0,             1, 1)
        grid.addWidget(self.qchk_quadrature_msb0,     1, 2)
        grid.addWidget(self.qchk_quadrature_lsb0,     1, 3)
        grid.addWidget(self.qchk_inphase_msb0,        2, 2)
        grid.addWidget(self.qchk_inphase_lsb0,        2, 3)

        grid.addWidget(self.qlbl_ddc1,                3, 0)
        grid.addWidget(self.qchk_Wideband1,           3, 1)
        grid.addWidget(self.qchk_Narrowband1,         3, 2)
        grid.addWidget(self.qchk_WidebandFIR1,        3, 3)

        #FEATURE
        grid.addWidget(self.qlbl_ddc1angle,           4, 0)
        grid.addWidget(self.qchk_cordic1,             4, 1)
        grid.addWidget(self.qchk_quadrature_msb1,     4, 2)
        grid.addWidget(self.qchk_quadrature_lsb1,     4, 3)
        grid.addWidget(self.qchk_inphase_msb1,        5, 2)
        grid.addWidget(self.qchk_inphase_lsb1,        5, 3)

        self.qgroupbox_ddc.setLayout(grid)

        #######################################################################
        #--- Loop Filter 1 Input Multiplexer
        #######################################################################
        #

        self.qgroupbox_MUX_pll1 = Qt.QGroupBox('Loop Filter 1 Input')
        self.qgroupbox_MUX_pll1.setAutoFillBackground(True)
        MUX_pll1 = Qt.QGridLayout()

        self.qradio_ddc1_to_pll1 = Qt.QRadioButton('DDC 1 output to LF 1 input')
        self.qradio_ddc0_to_pll1 = Qt.QRadioButton('DDC 0 output to LF 1 input')
        self.qradio_pll0_to_pll1 = Qt.QRadioButton('LF 0 output to LF 1 input')

        self.qradio_ddc1_to_pll1.setChecked(True)
        self.qradio_pll0_to_pll1.clicked.connect(self.mux_pll1_Action)
        self.qradio_ddc0_to_pll1.clicked.connect(self.mux_pll1_Action)
        self.qradio_ddc1_to_pll1.clicked.connect(self.mux_pll1_Action)

        MUX_pll1.addWidget(self.qradio_ddc1_to_pll1,     0, 0)
        MUX_pll1.addWidget(self.qradio_ddc0_to_pll1,     1, 0)
        MUX_pll1.addWidget(self.qradio_pll0_to_pll1,     2, 0)
        MUX_pll1.setRowStretch(2, 0)

        self.qgroupbox_MUX_pll1.setLayout(MUX_pll1)

        ######################################################################
        #--- Final Layout
        ######################################################################
        #

        self.group = Qt.QGroupBox('Error Signal Settings')
        self.group.setAutoFillBackground(True)
        group_layout = Qt.QGridLayout()
        group_layout.addWidget(self.qgroupbox_ddc,      0, 0, 1, 2)
        group_layout.addWidget(self.qgroupbox_MUX_pll1, 1, 0)
        group_layout.setColumnStretch(1, 1)

        self.group.setLayout(group_layout)

        final_layout = Qt.QGridLayout()
        final_layout.addWidget(self.group)
        self.setLayout(final_layout)

    ###########################################################################
    #--- Qt Slots
    ###########################################################################
    #

    def ddcClicked(self):
        # (data_delay, trigger_delay, boxcar_filter_size) = self.readStreamingSettings()  # Default (1,1,2)
        # rst_residuals_streaming = 0
        # self.sll.setResidualsStreamingSettings(data_delay, trigger_delay, boxcar_filter_size, rst_residuals_streaming)   # Default (1,1,2,0)

        adc_number = 0
        if self.qchk_Wideband0.isChecked():
            filter_select = 0
        elif self.qchk_Narrowband0.isChecked():
            filter_select = 1
        elif self.qchk_WidebandFIR0.isChecked():
            filter_select = 2

        if self.qchk_cordic0.isChecked():
            angle_select = 0
        elif self.qchk_quadrature_msb0.isChecked():
            angle_select = 1
        elif self.qchk_quadrature_lsb0.isChecked():
            angle_select = 2
        elif self.qchk_inphase_msb0.isChecked():
            angle_select = 3
        elif self.qchk_inphase_lsb0.isChecked():
            angle_select = 4
        self.sll.loop_filter.set_ddc_filter(adc_number, filter_select, angle_select)


        adc_number = 1
        if self.qchk_Wideband1.isChecked():
            filter_select = 0
        elif self.qchk_Narrowband1.isChecked():
            filter_select = 1
        elif self.qchk_WidebandFIR1.isChecked():
            filter_select = 2

        if self.qchk_cordic1.isChecked():
            angle_select = 0
        elif self.qchk_quadrature_msb1.isChecked():
            angle_select = 1
        elif self.qchk_quadrature_lsb1.isChecked():
            angle_select = 2
        elif self.qchk_inphase_msb1.isChecked():
            angle_select = 3
        elif self.qchk_inphase_lsb1.isChecked():
            angle_select = 4
        self.sll.loop_filter.set_ddc_filter(adc_number, filter_select, angle_select)

    def mux_pll1_Action(self):
        if self.qradio_ddc1_to_pll1.isChecked():
            data = 0
        elif self.qradio_ddc0_to_pll1.isChecked():
            data = 1
        elif self.qradio_pll0_to_pll1.isChecked():
            data = 2
        self.sll.loop_filter.set_loop_filter_input_mux(1, data)

    ###########################################################################
    #--- Set Values to RP
    ###########################################################################
    #

    def pushValues(self):
        self.ddcClicked()
        self.mux_pll1_Action()

    def pushDefaultValues(self):
        self.loadParameters()
        self.pushValues()

    ###########################################################################
    #--- Get Values from RP
    ###########################################################################
    #

    def loadParameters(self):
        #--- DDC
        filter_select_1    = int((self.sp.getValue('Filter_select', "DAC1")))

        if filter_select_1 == 0:
            self.qchk_Wideband1.setChecked(True)
        elif filter_select_1 == 1:
            self.qchk_Narrowband1.setChecked(True)
        elif filter_select_1 == 2:
            self.qchk_WidebandFIR1.setChecked(True)

        filter_select_0    = int((self.sp.getValue('Filter_select', "DAC0")))

        if filter_select_0 == 0:
            self.qchk_Wideband0.setChecked(True)
        elif filter_select_0 == 1:
            self.qchk_Narrowband0.setChecked(True)
        elif filter_select_0 == 2:
            self.qchk_WidebandFIR0.setChecked(True)

        angle_select_1     = int((self.sp.getValue('Angle_select', "DAC1")))

        if angle_select_1 == 0:
            self.qchk_cordic1.setChecked(True)
        elif angle_select_1 == 1:
            self.qchk_quadrature_msb1.setChecked(True)
        elif angle_select_1 == 2:
            self.qchk_quadrature_lsb1.setChecked(True)
        elif angle_select_1 == 3:
            self.qchk_inphase_msb1.setChecked(True)
        elif angle_select_1 == 4:
            self.qchk_inphase_lsb1.setChecked(True)

        angle_select_0     = int((self.sp.getValue('Angle_select', "DAC0")))

        if angle_select_0 == 0:
            self.qchk_cordic0.setChecked(True)
        elif angle_select_0 == 1:
            self.qchk_quadrature_msb0.setChecked(True)
        elif angle_select_0 == 2:
            self.qchk_quadrature_lsb0.setChecked(True)
        elif angle_select_0 == 3:
            self.qchk_inphase_msb0.setChecked(True)
        elif angle_select_0 == 4:
            self.qchk_inphase_lsb0.setChecked(True)

        #--- Loop Filter 1 Input
        mux_pll1 = int((self.sp.getValue('RP_settings', "PLL1_connection")))

        if mux_pll1 == 0:
            self.qradio_ddc1_to_pll1.setChecked(True)
        elif mux_pll1 == 1:
            self.qradio_ddc0_to_pll1.setChecked(True)
        elif mux_pll1 == 2:
            self.qradio_pll0_to_pll1.setChecked(True)

    def getValues(self):
        #Get filter_select(0, 1 or 2) for both adc
        (filter_select_1, filter_select_0) = self.sll.loop_filter.get_ddc_filter_select()
        #Check correspoding radio button
        if filter_select_1 == 0:
            self.qchk_Wideband1.setChecked(True)
        elif filter_select_1 == 1:
            self.qchk_Narrowband1.setChecked(True)
        elif filter_select_1 == 2:
            self.qchk_WidebandFIR1.setChecked(True)

        if filter_select_0 == 0:
            self.qchk_Wideband0.setChecked(True)
        elif filter_select_0 == 1:
            self.qchk_Narrowband0.setChecked(True)
        elif filter_select_0 == 2:
            self.qchk_WidebandFIR0.setChecked(True)

        #Get angle_select (0, 1, 2, 3 or 4) for both adc
        (angle_select_1, angle_select_0) = self.sll.loop_filter.get_ddc_angle_select()
        #Check correspoding radio button
        if angle_select_1 == 0:
            self.qchk_cordic1.setChecked(True)
        elif angle_select_1 == 1:
            self.qchk_quadrature_msb1.setChecked(True)
        elif angle_select_1 == 2:
            self.qchk_quadrature_lsb1.setChecked(True)
        elif angle_select_1 == 3:
            self.qchk_inphase_msb1.setChecked(True)
        elif angle_select_1 == 4:
            self.qchk_inphase_lsb1.setChecked(True)


        if angle_select_0 == 0:
            self.qchk_cordic0.setChecked(True)
        elif angle_select_0 == 1:
            self.qchk_quadrature_msb0.setChecked(True)
        elif angle_select_0 == 2:
            self.qchk_quadrature_lsb0.setChecked(True)
        elif angle_select_0 == 3:
            self.qchk_inphase_msb0.setChecked(True)
        elif angle_select_0 == 4:
            self.qchk_inphase_lsb0.setChecked(True)

        #get value for the pll1 connection
        mux_pll1 = self.sll.loop_filter.read_loop_filter_input_mux(1)
        if mux_pll1 == 0:
            self.qradio_ddc1_to_pll1.setChecked(True)
        elif mux_pll1 == 1:
            self.qradio_ddc0_to_pll1.setChecked(True)
        elif mux_pll1 == 2:
            self.qradio_pll0_to_pll1.setChecked(True)

