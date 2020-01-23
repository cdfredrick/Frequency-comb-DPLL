# -*- coding: utf-8 -*-
"""
Phase-lock box main GUI script,
by JD Deschenes, October 2013
---
-- Ported to Red Pitaya platform - JDD 2017

"""
import sys
import time

from PyQt5 import QtGui, Qt, QtCore, QtWidgets


from digital_servo import SuperLaserLand
from XEM_GUI_MainWindow import XEM_GUI_MainWindow
from FreqErrorWindowWithTempControlV2 import FreqErrorWindowWithTempControlV2
from initialConfiguration_RP import initialConfiguration
from SLLSystemParameters import SLLSystemParameters

from DisplayDitherSettingsWindow import DisplayDitherSettingsWindow

from DisplayDividerAndResidualsStreamingSettingsWindow import DisplayDividerAndResidualsStreamingSettingsWindow

from ConfigurationRPSettingsUI import ConfigRPSettingsUI

from devicesData import devicesData


class controller(object):
    """Main class of the GUI. It contains most of the elements of the GUI, the main_window and the communication class"""
    def __init__(self):
        # Create the object that handles the communication with the FPGA board:
        self.sll = SuperLaserLand()
        self.updateDeviceData()

        self.sp = SLLSystemParameters(self.sll)

        # Start Qt:
        self.app = QtCore.QCoreApplication.instance()
        if self.app is None:
            self.app = QtWidgets.QApplication(sys.argv)


        self.main()


    def updateDeviceData(self):
        # Hardcoded dictionnary containing the known Red Pitaya
        # TODO : xml file, user can add RP from the GUI?
        self.devices_data = {}
        devices_xml = devicesData("devices_data.xml")
        self.devices_data = devices_xml.updateDictionnary(self.devices_data)


    def connectionGUI(self):
        strBroadcastAddress = '192.168.0.255'
        strFPGAFirmware=r'red_pitaya_top.bit'
        strCPUFirmware=u'monitor-tcp'
        self.initial_config = initialConfiguration(self.sll.dev, self, self.devices_data, strBroadcastAddress, strFPGAFirmware, strCPUFirmware)


    def main(self):
        # Start the User Interface



        bTriggerEvents = False
        bConnectedRP = False
        self.strSelectedSerial = "000000000000"

        # if self.initial_config.bOk == False:
        #     # User clicked cancel. simply close the program:
        #     return

        # if self.initial_config.qradio_pushValue.isChecked():
        #     print("Push")
        #     bTriggerEvents = True
        #     bConnectedRP = True
        #     self.loadDefaultValueFromConfigFile(self.initial_config.strSelectedSerial)
        # elif self.initial_config.qradio_existingRP.isChecked():
        #     print("Reconnection")
        #     bTriggerEvents = False
        #     bConnectedRP = True
        # elif self.initial_config.qradio_noRP.isChecked():
        #     print("No RP")
        #     bTriggerEvents = False
        #     bConnectedRP = False


        bUpdateFPGA = bTriggerEvents
        bSendToFPGA = bTriggerEvents

        ###########################################################################
        # Create the object which handles the configuration parameters (DAC offsets, DAC gains, beat frequency modulation range, etc):
        #sp = SLLSystemParameters()



    #    config_window = SLLConfigurationWindow()
    #    config_window.loadParameters(sp)
    #    config_window.hide()


        ###########################################################################
        # Load all our windows:

        # Style sheet which includes the color scheme for each specific box:
        try:
            # custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.initial_config.strSelectedSerial]['color'])
            custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.strSelectedSerial]['color'])
        except KeyError:
            custom_style_sheet = ''


        # The shorthand name which gets added to the window names:
        try:
            # custom_shorthand = self.devices_data[self.initial_config.strSelectedSerial]['shorthand']
            custom_shorthand = self.devices_data[self.strSelectedSerial]['shorthand']
        except KeyError:
            custom_shorthand = ''

        # Have to be careful with the modulus setting (double-check with a scope to make sure the output frequency is right)
        # I think the output frequency for the square wave mode is given by:
        # 200 MHz/(2*(modulus+1))
        # While for the pulsed mode (bPulses = 1), the frequency is:
        # 200 MHz/(modulus+1)
        self.divider_settings_window = DisplayDividerAndResidualsStreamingSettingsWindow(self.sll, self.sp, clk_divider_modulus=67e3, bDividerOn=0, bPulses=0, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand)


        # Optical lock window
        # self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sll, custom_shorthand + ': Optical lock', 1, (False, True, False), sp, custom_style_sheet, self.initial_config.strSelectedSerial, bUpdateFPGA = bSendToFPGA, bConnectedRP = bConnectedRP)
        self.xem_gui_mainwindow2 = XEM_GUI_MainWindow(self.sll, custom_shorthand + ': Optical lock', 1, (False, True, False), self.sp, custom_style_sheet, self.strSelectedSerial)

        # CEO Lock window
        # self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sll, custom_shorthand + ': CEO lock', 0, (True, False, False), sp, custom_style_sheet, self.initial_config.strSelectedSerial, bUpdateFPGA = bSendToFPGA, bConnectedRP = bConnectedRP)
        self.xem_gui_mainwindow = XEM_GUI_MainWindow(self.sll, custom_shorthand + ': CEO lock', 0, (True, False, False), self.sp, custom_style_sheet, self.strSelectedSerial)

        # The two frequency counter:
        strOfTime = time.strftime("%m_%d_%Y_%H_%M_%S_")

        try:
            # temp_control_port = self.devices_data[self.initial_config.strSelectedSerial]['port']
            temp_control_port = self.devices_data[self.strSelectedSerial]['port']
        except:
            temp_control_port = 0


        strNameTemplate = 'data_logging\%s' % strOfTime
        # strNameTemplate = '%s_%s_' % (strNameTemplate, self.initial_config.strSelectedSerial)
        strNameTemplate = '%s_%s_' % (strNameTemplate, self.strSelectedSerial)
        self.freq_error_window1 = FreqErrorWindowWithTempControlV2(self.sll, 'CEO beat in-loop counter', self.sp, 0, strNameTemplate, custom_style_sheet, 0, self.xem_gui_mainwindow)
        self.freq_error_window2 = FreqErrorWindowWithTempControlV2(self.sll, 'Optical beat in-loop counter', self.sp, 1, strNameTemplate, custom_style_sheet, temp_control_port, self.xem_gui_mainwindow2)

        self.counters_window = Qt.QWidget()
        self.counters_window.setObjectName('MainWindow')
        self.counters_window.setStyleSheet(custom_style_sheet)
        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.freq_error_window1)
        vbox.addWidget(self.freq_error_window2)
        self.counters_window.setLayout(vbox)
        self.counters_window.setWindowTitle(custom_shorthand + ': Frequency counters')
        #self.counters_window.setGeometry(993, 40, 800, 1010)
        #self.counters_window.setGeometry(0, 0, 750, 1000)
        #    self.counters_window.resize(600, 1080-100+30)
        #self.counters_window.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(985, 10))
        #self.counters_window.show()

        # Dither windows, this code could be moved to another class/file to help with clutter:
        self.dither_widget0 = DisplayDitherSettingsWindow(self.sll, self.sp, 0, modulation_frequency_in_hz='1e3', output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
        self.dither_widget1 = DisplayDitherSettingsWindow(self.sll, self.sp, 1, modulation_frequency_in_hz='5.1e3' , output_amplitude='1e-3', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)
        #dither_widget2 = DisplayDitherSettingsWindow(self.sll, self.sp, 2, modulation_frequency_in_hz='110' , output_amplitude='1e-4', integration_time_in_seconds='0.1', bEnableDither=True, custom_style_sheet=custom_style_sheet)

        self.RP_Settings = ConfigRPSettingsUI(self.sll, self.sp, self, custom_style_sheet=custom_style_sheet, custom_shorthand=custom_shorthand)

        self.settings_window = Qt.QWidget()
        self.settings_window.setObjectName('MainWindow')
        self.settings_window.setStyleSheet(custom_style_sheet)
        vbox1 = Qt.QVBoxLayout()
        vbox1.addWidget(self.dither_widget0)
        vbox1.addWidget(self.dither_widget1)
        #vbox1.addWidget(dither_widget2)
        vbox1.addStretch(1)
        vbox2 = Qt.QVBoxLayout()
        vbox2.addWidget(self.RP_Settings)
        vbox2.addWidget(self.divider_settings_window)
        hbox = Qt.QHBoxLayout()
        hbox.addLayout(vbox1)
        hbox.addLayout(vbox2)
        hbox.addStretch(1)
        self.settings_window.setLayout(hbox)
        self.settings_window.setWindowTitle(custom_shorthand + ': Dither controls')
        #self.settings_window.show()

    #    # Regroup the two windows into a single one:
        self.main_windows = Qt.QWidget()
        self.main_windows.setObjectName('MainWindow')
        self.main_windows.setStyleSheet(custom_style_sheet)


        tabs = QtGui.QTabWidget()
        # self.xem_gui_mainwindow2.resize(600, 700)

        # self.xem_gui_mainwindow.setContentsMargins(0, 0, 0, 0)
        # self.xem_gui_mainwindow.layout().setContentsMargins(0, 0, 0, 0)
        # self.xem_gui_mainwindow2.setContentsMargins(0, 0, 0, 0)
        # self.xem_gui_mainwindow2.layout().setContentsMargins(0, 0, 0, 0)
        # self.counters_window.setContentsMargins(0, 0, 0, 0)
        # self.counters_window.layout().setContentsMargins(0, 0, 0, 0)
        # dither_window.setContentsMargins(0, 0, 0, 0)
        # dither_window.layout().setContentsMargins(0, 0, 0, 0)
        # dfr_timing_gui.setContentsMargins(0, 0, 0, 0)
        # dfr_timing_gui.layout().setContentsMargins(0, 0, 0, 0)
        # self.divider_settings_window.setContentsMargins(0, 0, 0, 0)
        # self.divider_settings_window.layout().setContentsMargins(0, 0, 0, 0)

        #tabs.setMaximumSize(1920,1080-100+30)

        # self.main_windows.setMaximumSize(600,600)
        # self.xem_gui_mainwindow.setMaximumSize(600,600)
        # self.xem_gui_mainwindow2.setMaximumSize(600,600)
        # self.counters_window.setMaximumSize(600,600)

        # dither_window.setMaximumSize(600,600)
        # dfr_timing_gui.setMaximumSize(600,600)
        # self.divider_settings_window.setMaximumSize(600,600)
        tabs.addTab(self.xem_gui_mainwindow, "CEO Lock")
        tabs.addTab(self.xem_gui_mainwindow2, "Optical Lock")
        tabs.addTab(self.counters_window, "Counters")
        tabs.addTab(self.settings_window, "Settings")
        #FEATURE
        #tabs.addTab(dfr_timing_gui, "DFr trigger generator")
        #tabs.addTab(self.divider_settings_window, "Filter settings")
        # tabs.setGeometry(0, 0, 750, 1000)



        box = QtGui.QHBoxLayout()
        box.addWidget(tabs)
        self.main_windows.setLayout(box)
        self.main_windows.setWindowTitle(custom_shorthand)
        #self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(945-300, 0))
        self.main_windows.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(800-300, 0))

        self.main_windows.show()


        self.connectionGUI()

        # Enter main event loop
        #self.app.exec_()
        try:
            self.app.exec_()
        except:
            print("main_gui.py: Exception during app.exec_()")


    def loadDefaultValueFromConfigFile(self, strSelectedSerial):
        try:
            # custom_config_file = self.devices_data[self.initial_config.strSelectedSerial]['config file']
            custom_config_file = self.devices_data[strSelectedSerial]['config file']
            self.sp.loadFromFile(custom_config_file)
            print('Loaded configuration from %s' % custom_config_file)
        except (KeyError, IOError):
            strFileDefaultConfig = 'system_parameters_RP_Default.xml'
            # print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (self.initial_config.strSelectedSerial, strFileDefaultConfig))
            # print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (self.initial_config.strSelectedSerial, strFileDefaultConfig))
            print('Warning: Could not parse config file for FPGA serial: %s, loading values from file %s' % (strSelectedSerial, strFileDefaultConfig))
            custom_config_file = ''
            try:
                self.sp.loadFromFile(strFileDefaultConfig)
                print('Loaded configuration from %s' % strFileDefaultConfig)
            except (KeyError, IOError):

                # print('Warning: Could not parse config file "%s" for FPGA serial: %s, falling back on script-defined defaults' % (strFileDefaultConfig, self.initial_config.strSelectedSerial))
                print('Warning: Could not parse config file "%s" for FPGA serial: %s, falling back on script-defined defaults' % (strFileDefaultConfig, strSelectedSerial))
                self.sp.loadDefaults()

        # self.sp.loadDefaults()
        # self.sp.saveToFile('system_parameters_current.xml')

        self.sp.sendToFPGA(True)


    def setCustomStyleSheet(self, strSelectedSerial):
        # Style sheet which includes the color scheme for each specific box:
        try:
            # custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[self.initial_config.strSelectedSerial]['color'])
            custom_style_sheet = ('#MainWindow {color: white; background-color: %s;}' % self.devices_data[strSelectedSerial]['color'])
        except KeyError:
            custom_style_sheet = ''

        self.divider_settings_window.setStyleSheet(custom_style_sheet)
        self.freq_error_window1.setStyleSheet(custom_style_sheet)
        self.freq_error_window2.setStyleSheet(custom_style_sheet)
        self.xem_gui_mainwindow2.setStyleSheet(custom_style_sheet)
        self.xem_gui_mainwindow.setStyleSheet(custom_style_sheet)
        self.counters_window.setStyleSheet(custom_style_sheet)
        self.dither_widget0.setStyleSheet(custom_style_sheet)
        self.dither_widget1.setStyleSheet(custom_style_sheet)
        self.RP_Settings.setStyleSheet(custom_style_sheet)
        self.settings_window.setStyleSheet(custom_style_sheet)
        self.main_windows.setStyleSheet(custom_style_sheet)


    def pushDefaultValues(self, strSelectedSerial = "000000000000", ip_addr = "192.168.0.150"):
        self.setCustomStyleSheet(strSelectedSerial)

        if self.sll.dev.valid_socket:
            self.sll.dev.close_TCP_connection()

        self.sll.dev.open_TCP_connection(ip_addr)
        # Now we just need to reset the frontend to make sure we start everything in a nice state
        self.sll.dev.reset_front_end()
        self.loadDefaultValueFromConfigFile(strSelectedSerial)


        self.xem_gui_mainwindow2.pushDefaultValues()
        self.xem_gui_mainwindow.pushDefaultValues()
        self.freq_error_window1.pushDefaultValues()
        self.freq_error_window2.pushDefaultValues()
        self.RP_Settings.pushDefaultValues()
        self.divider_settings_window.pushDefaultValues()
        self.dither_widget0.pushDefaultValues()
        self.dither_widget1.pushDefaultValues()

    def pushActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150"):
        self.setCustomStyleSheet(strSelectedSerial)

        if self.sll.dev.valid_socket:
            self.sll.dev.close_TCP_connection()
        self.sll.dev.open_TCP_connection(ip_addr)
        self.xem_gui_mainwindow2.pushActualValues()
        self.xem_gui_mainwindow.pushActualValues()
        self.freq_error_window1.pushValues()
        self.freq_error_window2.pushValues()

    def getActualValues(self, strSelectedSerial, ip_addr = "192.168.0.150"):
        self.setCustomStyleSheet(strSelectedSerial)
        if self.sll.dev.valid_socket:
            self.sll.dev.close_TCP_connection()
        self.sll.dev.open_TCP_connection(ip_addr)

        self.xem_gui_mainwindow2.getValues()
        self.xem_gui_mainwindow.getValues()
        self.freq_error_window1.getValues()
        self.freq_error_window2.getValues()
        self.RP_Settings.getValues()
        self.divider_settings_window.getValues()
        self.dither_widget0.getValues()
        self.dither_widget1.getValues()
        # Reset the Connection
        # self.sll.dev.restart_TCP_connection(print_error=False)

    def stopCommunication(self):
        if self.sll.dev.valid_socket:
            self.sll.dev.close_TCP_connection()
        try:
            self.xem_gui_mainwindow2.killTimers()
            self.xem_gui_mainwindow.killTimers()
            self.freq_error_window1.killTimers()
            self.freq_error_window2.killTimers()
        except:
            print("Error while killing the Timers")

    def startCommunication(self, ip_addr = "192.168.0.150"):
        self.sll.dev.open_TCP_connection(ip_addr)
        self.xem_gui_mainwindow2.startTimers()
        self.xem_gui_mainwindow.startTimers()
        self.freq_error_window1.startTimers()
        self.freq_error_window2.startTimers()

    def restartCommunication(self, ip_addr="192.160.0.150"):
        self.stopCommunication()
        print("Notice: Restarting Communication") #!!!
        self.startCommunication(ip_addr=ip_addr)


#--- Main
if __name__ == '__main__':
    cntr = controller()

