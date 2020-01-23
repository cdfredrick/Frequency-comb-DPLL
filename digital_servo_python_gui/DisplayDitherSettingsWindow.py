"""
XEM6010 Phase-lock box GUI, Dither settings controls
by JD Deschenes, October 2013

"""

import time
from PyQt5 import QtGui, Qt
import numpy as np

from user_friendly_QLineEdit import user_friendly_QLineEdit

import weakref
from digital_servo import SuperLaserLand

class DisplayDitherSettingsWindow(QtGui.QWidget):

    def __init__(self, sll, sp, output_number, modulation_frequency_in_hz=1e3, output_amplitude=1e-4, integration_time_in_seconds=0.1, bEnableDither=0, custom_style_sheet=''):
        assert isinstance(sll, SuperLaserLand)

        super(DisplayDitherSettingsWindow, self).__init__()



        self.output_number = output_number
        self.sll = weakref.proxy(sll)
        self.sp = sp
        self.setObjectName('MainWindow')
        self.setStyleSheet(custom_style_sheet)


        self.initUI(modulation_frequency_in_hz, output_amplitude, integration_time_in_seconds, bEnableDither)


    def loadParameters(self):
        strDAC = 'DAC{:01d}'.format(self.output_number)

        dither_frequency = float((self.sp.getValue('Dither_frequency', strDAC)))
        dither_integration_time = float((self.sp.getValue('Dither_integration_time', strDAC)))
        dither_amplitude = float((self.sp.getValue('Dither_amplitude', strDAC)))
        dither_mode = float((self.sp.getValue('Dither_mode', strDAC)))

        self.qedit_dither_freq.blockSignals(True)
        self.qedit_dither_freq.setText('{:.1e}'.format(dither_frequency))
        self.qedit_dither_freq.blockSignals(False)

        self.qedit_integration_time.blockSignals(True)
        self.qedit_integration_time.setText('{:.3f}'.format(dither_integration_time))
        self.qedit_integration_time.blockSignals(False)

        self.qedit_dither_amplitude.blockSignals(True)
        self.qedit_dither_amplitude.setText('{:.2e}'.format(dither_amplitude))
        self.qedit_dither_amplitude.blockSignals(False)


        if dither_mode == 0:
            self.qchk_mode_manual_off.setChecked(True)
        elif dither_mode == 1:
            self.qchk_mode_manual_on.setChecked(True)
        else:
            self.qchk_mode_auto.setChecked(True)


    def pushDefaultValues(self):
        self.loadParameters()
        self.pushValues()


    # This will make the window update the FPGA register
    def pushValues(self):
        self.ditherClicked()

    def getValues(self):
        (modulation_frequency_in_hz, integration_time_in_seconds, output_amplitude_V,
         mode_auto, bEnableDither) = self.sll.loop_filter.get_dither_settings(self.output_number)

        self.qedit_dither_freq.blockSignals(True)
        self.qedit_dither_freq.setText('{:.1e}'.format(modulation_frequency_in_hz))
        self.qedit_dither_freq.blockSignals(False)

        self.qedit_dither_amplitude.blockSignals(True)
        self.qedit_dither_amplitude.setText('{:.2e}'.format(output_amplitude_V))
        self.qedit_dither_amplitude.blockSignals(False)

        self.qedit_integration_time.blockSignals(True)
        self.qedit_integration_time.setText('{:.3f}'.format(integration_time_in_seconds))
        self.qedit_integration_time.blockSignals(False)

        if mode_auto == 1:
            self.qchk_mode_auto.setChecked(True)
        else:
            if bEnableDither ==1 :
                self.qchk_mode_manual_on.setChecked(True)
            elif bEnableDither == 0:
                self.qchk_mode_manual_off.setChecked(True)


    def readDitherSettings(self):

        # Amplitude
        # Frequency
        # Integration time
        # On/Off/Auto

        if self.qchk_mode_auto.isChecked():
            mode_auto = 1
            bEnableDither = 0
        else:
            mode_auto = 0
            if self.qchk_mode_manual_off.isChecked():
                bEnableDither = 0
            else:
                bEnableDither = 1

        try:
            output_amplitude = float(self.qedit_dither_amplitude.text())
        except:
            output_amplitude = 0
        if output_amplitude > 1:
            output_amplitude = 1
        if output_amplitude <= 0:
            output_amplitude = 0

        try:
            modulation_frequency_in_hz = float(self.qedit_dither_freq.text())
        except:
            modulation_frequency_in_hz = 1e3
            pass

        try:
            integration_time_in_seconds = float(self.qedit_integration_time.text())
            if integration_time_in_seconds < 1e-6:
                integration_time_in_seconds = 1e-6
        except:
            integration_time_in_seconds = 0.1
            pass

        return (integration_time_in_seconds, modulation_frequency_in_hz, output_amplitude, bEnableDither, mode_auto)



    def ditherClicked(self):
        (integration_time_in_seconds, modulation_frequency_in_hz, output_amplitude_V, bEnableDither, mode_auto) = self.readDitherSettings()

        if mode_auto == 0:
            # Manual mode:
            self.sll.loop_filter.set_dither_lock_in_parameters(self.output_number, modulation_frequency_in_hz, integration_time_in_seconds, output_amplitude_V, mode_auto, bEnableDither)
        else:
            self.sll.loop_filter.set_dither_lock_in_parameters(self.output_number, modulation_frequency_in_hz, integration_time_in_seconds, output_amplitude_V, mode_auto)

        return

    def initUI(self, modulation_frequency_in_hz, output_amplitude, integration_time_in_seconds, bEnableDither):

        # Create the widgets which control the dither module:

        # Controls for the dither mode:
        # Needs: output select, frequency, amplitude, Square/Sine select, dither on/off
        ######################################################################
        # Settings
        ######################################################################

        self.qgroupbox_dither = Qt.QGroupBox('Dither DAC%d settings' % self.output_number)
        self.qgroupbox_dither.setAutoFillBackground(True)


        # Modulation frequency:
        self.qedit_freq_label = Qt.QLabel('Frequency [Hz]:')
        self.qedit_dither_freq = user_friendly_QLineEdit(str(modulation_frequency_in_hz))
        self.qedit_dither_freq.editingFinished.connect(self.ditherClicked)
        self.qedit_dither_freq.setMaximumWidth(60)

        # Integration time:
        self.qedit_int_label = Qt.QLabel('Integration time [s]:')
        self.qedit_integration_time = user_friendly_QLineEdit(str(integration_time_in_seconds))
        self.qedit_integration_time.editingFinished.connect(self.ditherClicked)
        self.qedit_integration_time.setMaximumWidth(60)

        # Amplitude:
        self.qlabel_dither_amplitude = Qt.QLabel('Amplitude [0-1]:')
        self.qedit_dither_amplitude = user_friendly_QLineEdit(str(output_amplitude))
        self.qedit_dither_amplitude.editingFinished.connect(self.ditherClicked)
        self.qedit_dither_amplitude.setMaximumWidth(60)


#        # On/Off button
#        self.qbtn_dither = QtGui.QPushButton('Activate dither')
#        self.qbtn_dither.clicked.connect(self.ditherClicked)
#        self.qbtn_dither.setCheckable(True)
#        self.qbtn_dither.setChecked(bool(bEnableDither))

        # Mode select button (Automatic, Manual Off, Manual On)
        self.qchk_mode_auto = QtGui.QRadioButton('Automatic')
        self.qchk_mode_manual_off = QtGui.QRadioButton('Manual Off')
        self.qchk_mode_manual_on = QtGui.QRadioButton('Manual On')
        qbtn_group = Qt.QButtonGroup()
        qbtn_group.addButton(self.qchk_mode_auto)
        qbtn_group.addButton(self.qchk_mode_manual_off)
        qbtn_group.addButton(self.qchk_mode_manual_on)
        self.qchk_mode_auto.setChecked(True)
        self.qchk_mode_auto.clicked.connect(self.ditherClicked)
        self.qchk_mode_manual_off.clicked.connect(self.ditherClicked)
        self.qchk_mode_manual_on.clicked.connect(self.ditherClicked)

        # Put all the widgets into a grid layout
        grid = QtGui.QGridLayout()

        grid.addWidget(self.qedit_freq_label,               0, 0)
        grid.addWidget(self.qedit_dither_freq,              0, 1)
        grid.addWidget(self.qedit_int_label,                1, 0)
        grid.addWidget(self.qedit_integration_time,         1, 1)

        grid.addWidget(self.qlabel_dither_amplitude,        2, 0)
        grid.addWidget(self.qedit_dither_amplitude,         2, 1)

        grid.addWidget(self.qchk_mode_auto,                 3, 0, 1, 2)
        grid.addWidget(self.qchk_mode_manual_off,           4, 0, 1, 2)
        grid.addWidget(self.qchk_mode_manual_on,            5, 0, 1, 2)
        self.qgroupbox_dither.setLayout(grid)

        vbox = Qt.QVBoxLayout()
        vbox.addWidget(self.qgroupbox_dither)
        self.setLayout(vbox)


        # Adjust the size and position of the window
#        self.resize(800, 600)
        self.center()
        self.setWindowTitle('Dither #%d control' % self.output_number)
        #self.show()



    def center(self):

        qr = self.frameGeometry()
        cp = QtGui.QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
#        self.move(qr.topLeft())
#        self.move(QtGui.QDesktopWidget().availableGeometry().topLeft() + Qt.QPoint(50, 50))




