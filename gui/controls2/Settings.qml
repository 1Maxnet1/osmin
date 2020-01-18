/*
 * Copyright (C) 2020
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQml.Models 2.3
import QtQuick.Layouts 1.3
import Osmin 1.0
import "./components"

MapPage {
    id: favorites
    pageTitle: qsTr("General Settings")
    pageFlickable: body

    onPopped: {
//        var needRestart = (styleBox.currentIndex !== styleBox.styleIndex ||
//                scaleBox.realValue !== scaleBox.acceptedValue);
//        settings.style = styleBox.displayText;
//        if (needRestart) {
//            mainView.jobRunning = true;
//            Qt.exit(16);
//        }
    }

    Flickable {
        id: body
        anchors.fill: parent
        contentHeight: settingsColumn.implicitHeight
        ScrollBar.vertical: ScrollBar {}

        Column {
            id: settingsColumn
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(1)

            RowLayout {
                spacing: 0
                MapIcon {
                    height: units.gu(5)
                    width: height
                    source: "qrc:/images/font-scalling.svg"
                    hoverEnabled: false
                }
                SpinBox {
                    id: fontScaleBox
                    enabled: !Android
                    from: 50
                    value: settings.fontScaleFactor * 100
                    to: 150
                    stepSize: 10
                    font.pointSize: units.fs("medium");
                    Layout.fillWidth: true

                    property int decimals: 2
                    property real realValue: value / 100
                    property real acceptedValue: settings.fontScaleFactor

                    validator: DoubleValidator {
                        bottom: Math.min(fontScaleBox.from, fontScaleBox.to)
                        top:  Math.max(fontScaleBox.from, fontScaleBox.to)
                    }

                    textFromValue: function(value, locale) {
                        return Number(value / 100).toLocaleString(locale, 'f', fontScaleBox.decimals)
                    }

                    valueFromText: function(text, locale) {
                        return Number.fromLocaleString(locale, text) * 100
                    }

                    onValueModified: {
                        settings.fontScaleFactor = realValue
                    }
                }
            }

            RowLayout {
                spacing: 0
                MapIcon {
                    height: units.gu(5)
                    width: height
                    source: "qrc:/images/graphic-scalling.svg"
                    hoverEnabled: false
                }
                SpinBox {
                    id: scaleBox
                    enabled: !Android
                    from: 50
                    value: settings.scaleFactor * 100
                    to: 400
                    stepSize: 10
                    font.pointSize: units.fs("medium");
                    Layout.fillWidth: true

                    property int decimals: 2
                    property real realValue: value / 100
                    property real acceptedValue: settings.scaleFactor

                    validator: DoubleValidator {
                        bottom: Math.min(scaleBox.from, scaleBox.to)
                        top:  Math.max(scaleBox.from, scaleBox.to)
                    }

                    textFromValue: function(value, locale) {
                        return Number(value / 100).toLocaleString(locale, 'f', scaleBox.decimals)
                    }

                    valueFromText: function(text, locale) {
                        return Number.fromLocaleString(locale, text) * 100
                    }

                    onValueModified: {
                        mainView.width = Math.round(realValue * mainView.width / settings.scaleFactor);
                        mainView.height = Math.round(realValue * mainView.height / settings.scaleFactor);
                        settings.scaleFactor = realValue
                    }
                }
            }

//            RowLayout {
//                spacing: units.gu(1)
//                Layout.fillWidth: true
//                Label {
//                    text: qsTr("Style")
//                    font.pointSize: units.fs("medium");
//                }
//                ComboBox {
//                    id: styleBox
//                    flat: true
//                    property int styleIndex: -1
//                    model: AvailableStyles
//                    Component.onCompleted: {
//                        styleIndex = find(settings.style, Qt.MatchFixedString)
//                        if (styleIndex !== -1)
//                            currentIndex = styleIndex
//                    }
//                    onActivated: {
//                        // reset theme when not supported
//                        if (currentText !== "Material" && currentText !== "Universal") {
//                            settings.theme = 0;
//                        }
//                    }
//                    Layout.fillWidth: true
//                    font.pointSize: units.fs("medium");
//                    popup {
//                        font.pointSize: units.fs("medium");
//                    }
//                }
//            }

            RowLayout {
//                visible: styleBox.currentText === "Material" || styleBox.currentText === "Universal"
                spacing: units.gu(1)
                Layout.fillWidth: true
                Label {
                    text: qsTr("Theme")
                    font.pointSize: units.fs("medium");
                }
                ComboBox {
                    id: themeBox
                    flat: true
                    property int acceptedValue: settings.theme
                    model: [
                        qsTr("Light"),
                        qsTr("Dark")
                    ]

                    currentIndex: settings.theme
                    onActivated: {
                        settings.theme = index
                    }

                    Layout.fillWidth: true
                    font.pointSize: units.fs("medium");
                    Component.onCompleted: {
                        popup.font.pointSize = units.fs("medium");
                    }
                }
            }

//            Label {
//                text: qsTr("Restart is required")
//                font.pointSize: units.fs("medium")
//                color: "red"
//                opacity: styleBox.currentIndex !== styleBox.styleIndex ||
//                         scaleBox.realValue !== scaleBox.acceptedValue ? 1.0 : 0.0
//                horizontalAlignment: Label.AlignHCenter
//                verticalAlignment: Label.AlignVCenter
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//            }
        }
    }
}