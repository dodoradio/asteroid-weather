/*
 * Copyright (C) 2021 - Timo Könnecke <github.com/eLtMosen>
 *               2016 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import Nemo.Configuration 1.0
import 'qrc:/icons.js' as IconTools

Application {
    id: app

    centerColor: "#990019"
    outerColor: "#0C0200"

    function availableDays(day0) {
        var currentDate = new Date();
        var day0Date    = new Date(day0);
        var daysDiff = Math.round((currentDate-day0Date)/(1000*60*60*24));
        if(daysDiff > 5 || daysDiff < 0) daysDiff = 5;
        return 5-daysDiff;
    }

    function dayNbFromIndex(i) {
        var currentDate = new Date();
        var day0Date    = new Date(timestampDay0.value*1000);
        var daysDiff = Math.round((currentDate-day0Date)/(1000*60*60*24));
        if(daysDiff > 5) daysDiff = 5;
        return i+daysDiff;
    }

    function nameOfDay(i) {
        switch(i) {
            case 0:
                //% "Today"
                return qsTrId("id-today");
                break;
            case 1:
                //% "Tomorrow"
                return qsTrId("id-tomorrow");
                break;
            default:
                return Qt.formatDate(new Date(new Date().getTime() + i * 1000*60*60*24), "dddd");
        }
    }

    function kelvinToTemperatureNumber(kelvin) {
        var celsius = (kelvin-273);
        if(!useFahrenheit.value)
            return celsius;
        else
            return Math.round(((celsius)*9/5) + 32);
    }

    function kelvinToTemperatureString(kelvin) {
        var celsius = (kelvin-273);
        if(!useFahrenheit.value)
            return celsius + "°C";
        else
            return Math.round(((celsius)*9/5) + 32) + "°F";
    }

    ConfigurationValue {
        id: timestampDay0

        key: "/org/asteroidos/weather/timestamp-day0"
        defaultValue: 0
    }

    ConfigurationValue {
        id: useFahrenheit

        key: "/org/asteroidos/settings/use-fahrenheit"
        defaultValue: false
    }

    ConfigurationValue {
        id: cityName

        key: "/org/asteroidos/weather/city-name"
        //% "Unknown"
        defaultValue: qsTrId("id-unknown")
    }

    StatusPage {
        //% "<h3>No data</h3>Sync AsteroidOS with your phone."
        text: qsTrId("id-no-data-sync")
        icon: "ios-sync"
        visible: availableDays(timestampDay0.value*1000) <= 0
    }

    Item {
        visible: availableDays(timestampDay0.value*1000) > 0
        anchors.fill: parent

        Label {
            id: cityNameDisplay

            property string cityCount: cityName.value

            height: Dims.h(44)
            width: Dims.l(62)
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            renderType: Text.NativeRendering
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            lineHeight: Dims.l(0.2)
            font {
                styleName: "SemiCondensed ExtraLight"
                letterSpacing: -Dims.l(0.05)
                pixelSize: cityCount.length > 16 ? Dims.l(8.4) : cityCount.length > 14 ? Dims.l(9) : Dims.l(10)
            }
            text: cityName.value
        }

        Component {
            id: dayDelegate

            Item {
                width: app.width; height: app.height
                property int dayNb: dayNbFromIndex(index)

                ConfigurationValue {
                    id: owmId
                    key: "/org/asteroidos/weather/day" + dayNb + "/id"
                    defaultValue: 0
                }
                ConfigurationValue {
                    id: minTemp
                    key: "/org/asteroidos/weather/day" + dayNb + "/min-temp"
                    defaultValue: 0
                }
                ConfigurationValue {
                    id: maxTemp
                    key: "/org/asteroidos/weather/day" + dayNb + "/max-temp"
                    defaultValue: 0
                }

                Label {
                    height: Dims.h(42)
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        pixelSize: Dims.l(10)
                        styleName: "SemiCondensed ExtraLight"
                    }
                    text: nameOfDay(index)
                }

                Rectangle {
                    id: minCircle

                    width: Dims.w(30)
                    height: width
                    radius: width/2
                    color: "#00ffffff"
                    anchors {
                        centerIn: parent
                        horizontalCenterOffset: Dims.w(-30)
                    }

                    Label {
                        id: minDisplay

                        width: parent.width
                        height: width
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            styleName: "ExtraCondensed ExtraLight"
                            pixelSize: width/2
                        }
                        text: kelvinToTemperatureString(minTemp.value)

                        Label {
                            id: minLabel

                            color: "#99ffffff"
                            anchors {
                                centerIn: minDisplay
                                verticalCenterOffset: -parent.height/3
                            }
                            font {
                                styleName: "Bold"
                                pixelSize: Dims.w(5)
                            }
                            //% "Min:"
                            text: qsTrId("id-min")
                        }

                        Label {
                            id: minArrow

                            color: "#88ffffff"
                            anchors {
                                centerIn: minDisplay
                                verticalCenterOffset: parent.height/3
                            }
                            font {
                                styleName: "Light"
                                pixelSize: Dims.w(6)
                            }
                            text: "\u25bc"
                        }
                    }
                }

                Rectangle {
                    id: maxCircle

                    width: Dims.w(30)
                    height: width
                    radius: width/2
                    color: "#00ffffff"
                    anchors {
                        centerIn: parent
                        horizontalCenterOffset: Dims.w(+30)
                    }

                    Label {
                        id: maxDisplay

                        width: parent.width
                        height: width
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            styleName: "ExtraCondensed ExtraLight"
                            pixelSize: width/2
                        }
                        text: kelvinToTemperatureString(maxTemp.value)

                        Label {
                            id: maxLabel

                            color: "#99ffffff"
                            anchors {
                                centerIn: maxDisplay
                                verticalCenterOffset: parent.height/3
                            }
                            font {
                                styleName: "Bold"
                                pixelSize: Dims.w(5)
                            }
                            //% "Max:"
                            text: qsTrId("id-max")
                        }

                        Label {
                            id: maxArrow

                            color: "#88ffffff"
                            anchors {
                                centerIn: maxDisplay
                                verticalCenterOffset: -parent.height/3
                            }
                            font {
                                styleName: "Light"
                                pixelSize: Dims.h(6)
                            }
                            text: "\u25b2"
                        }
                    }
                }

                Rectangle {
                    id: iconCircle

                    width: Dims.w(24)
                    height: width
                    radius: width/2
                    color: "#00ffffff"
                    anchors {
                        centerIn: parent
                    }

                    Icon {
                        id: iconDisplay

                        name: IconTools.getIconName(owmId.value)
                        width: Dims.w(24)
                        height: width
                        opacity: 1
                        anchors.centerIn: parent
                    }
                }
            }
        }

        ListView {
            id: lv

            anchors.fill:parent
            model: availableDays(timestampDay0.value * 1000)
            delegate: dayDelegate
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
        }

        PageDot {
            height: Dims.h(3)
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: Dims.h(3.8)
            }
            currentIndex: lv.currentIndex
            dotNumber: availableDays(timestampDay0.value*1000)
        }
    }
}
