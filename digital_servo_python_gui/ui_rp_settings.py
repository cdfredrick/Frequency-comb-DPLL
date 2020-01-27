# -*- coding: utf-8 -*-
"""
June 2017

Description: Provides a graphical user interface (GUI) to configure the RP
@author: Alex Tourigny-Plante
"""

from PyQt5 import QtGui, Qt, QtCore, QtWidgets
import sys

from user_friendly_QLineEdit import user_friendly_QLineEdit


from digital_servo import SuperLaserLand


class ConfigRPSettingsUI(Qt.QWidget):
    """docstring for ConfigRP"""
    def __init__(self, sll, sp, controller, custom_style_sheet='', custom_shorthand=''):
        assert isinstance(sll, SuperLaserLand)
        super().__init__()
        self.sll = sll
        self.sp = sp
        self.controller = controller #link to the top class

        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)
        self.custom_shorthand = custom_shorthand

        self.initUI()
        self.loadParameters()

    def initUI(self):
        #######################################################################
        #--- Fan Power Control
        #######################################################################
        #

        self.qgroupbox_fanUI = Qt.QGroupBox('Fan Power')
        self.qgroupbox_fanUI.setAutoFillBackground(True)
        fanUI = Qt.QGridLayout()

        self.qradio_fan_on  = Qt.QRadioButton('Fan on')
        self.qradio_fan_off = Qt.QRadioButton('Fan off')
        self.qradio_fan_on.setChecked(True)
        self.qradio_fan_on.clicked.connect(self.set_fan)
        self.qradio_fan_off.clicked.connect(self.set_fan)

        fanUI.addWidget(self.qradio_fan_on,     0, 0)
        fanUI.addWidget(self.qradio_fan_off,     1, 0)

        self.qgroupbox_fanUI.setLayout(fanUI)

        #######################################################################
        #--- Connection Menu
        #######################################################################
        #

        self.qbtn_reconnect = QtGui.QPushButton('Open communication menu')
        self.qbtn_reconnect.clicked.connect(self.communication_menu)

        #######################################################################
        #--- Read Data
        #######################################################################
        #

        self.qgroupbox_read_data = Qt.QGroupBox('Read Data from DPLL Module')
        self.qgroupbox_read_data.setAutoFillBackground(True)
        read_data = Qt.QGridLayout()

        self.qbuttongroup_address_type = Qt.QButtonGroup()
        self.qradio_dpll_bram = Qt.QRadioButton('BRAM')
        self.qradio_dpll_legacy = Qt.QRadioButton('Legacy (Opal Kelly)')
        self.qbuttongroup_address_type.addButton(self.qradio_dpll_bram, 0)
        self.qbuttongroup_address_type.addButton(self.qradio_dpll_legacy, 1)
        self.qradio_dpll_bram.setChecked(True)

        self.qlabel_addr = Qt.QLabel('Address: 0x')
        self.qedit_addr = user_friendly_QLineEdit('9000')
        self.qedit_addr.setMaximumWidth(100)

        self.qlabel_data = Qt.QLabel('Data:')
        self.qedit_data = user_friendly_QLineEdit('0')
        self.qedit_data.setMaximumWidth(300)

        self.qbtn_1 = QtGui.QPushButton('Read data')
        self.qbtn_1.clicked.connect(self.read_RP)

        read_data.addWidget(self.qradio_dpll_bram,      0, 0)
        read_data.addWidget(self.qradio_dpll_legacy,    0, 1)
        read_data.addWidget(self.qlabel_addr,           1, 0)
        read_data.addWidget(self.qedit_addr,            1, 1)
        read_data.addWidget(self.qbtn_1,                1, 2)
        read_data.addWidget(self.qlabel_data,           2, 0)
        read_data.addWidget(self.qedit_data,            2, 1, 1, 2)

        read_data.setColumnStretch(3, 1)

        self.qgroupbox_read_data.setLayout(read_data)

        #######################################################################
        #--- Final Layout
        #######################################################################
        #

        self.group = Qt.QGroupBox('RP System Settings')
        self.group.setAutoFillBackground(True)
        group = Qt.QGridLayout()

        group.addWidget(self.qgroupbox_fanUI, 0, 0, 1, 1)
        group.addWidget(self.qbtn_reconnect, 0, 1, 1, 1)
        group.addWidget(self.qgroupbox_read_data, 1, 0, 2, 2)
        group.setColumnStretch(2, 1)

        self.group.setLayout(group)

        grid = Qt.QGridLayout()
        grid.addWidget(self.group)
        grid.setColumnStretch(1, 1)
        self.setLayout(grid)

    ###########################################################################
    #--- Qt Slots
    ###########################################################################
    #

    def communication_menu(self):
        # Open the initial menu in which we select the RP and if we want to reconnect to one. We can open a new connection without closing the GUI
        self.controller.connectionGUI()

    def read_RP(self):
        addr = int(self.qedit_addr.text(),16)
        if self.qradio_dpll_bram.isChecked():
            bus_address = self.sll.dev.dpll_read_address(addr)
        elif self.qradio_dpll_legacy.isChecked():
            bus_address = self.sll.dev.dpll_legacy_read_address(addr)
        value = str(self.sll.dev.read_Zynq_register_uint32(bus_address))
        self.qedit_data.blockSignals(True)
        self.qedit_data.setText(value)
        self.qedit_data.blockSignals(False)

    def set_fan(self):
        # Set the output of 2 IO pins (0 or 3.3V) for the activation of the fan
        self.sll.dev.set_fan(self.qradio_fan_on.isChecked())

    ###########################################################################
    #--- Set Values
    ###########################################################################
    #

    def pushDefaultValues(self):
        # Push the values from the xml file to the red pitaya (load + send)
        self.loadParameters()
        self.pushValues()

    def pushValues(self):
        # Send the values in the different fields to the RP
        self.set_fan()

    ###########################################################################
    #--- Get Values
    ###########################################################################
    #

    def loadParameters(self):
        # Load the default parameters from the selected xml file (select by the devices_data dictionnary in the controller class)
        fan_state = int((self.sp.getValue('RP_settings', "Fan_state")))
        if fan_state > 0:
            self.qradio_fan_on.setChecked(True)
        else:
            self.qradio_fan_off.setChecked(True)

    def getValues(self):
        pass #TODO: Include fan settings and others...


###############################################################################
#--- Main
###############################################################################
#
if __name__ == '__main__':

    app = QtCore.QCoreApplication.instance()
    if app is None:
        app = QtWidgets.QApplication(sys.argv)

    sll = SuperLaserLand()
    w = ConfigRPSettingsUI(sll)
    w.show()
    w.resize(800, 300)

    app.exec_()

