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

QtObject {
    property real scaleFactor: 1.0
    property real fontScaleFactor: 1.0
    property real gridUnit: 8.0 * scaleFactor

    function dp(p) {
        return scaleFactor * p;
    }

    function gu(u) {
        return gridUnit * u;
    }

    function fs(s) {
        if (s === "x-small")
            return 13.0 * scaleFactor * fontScaleFactor;
        if (s === "small")
            return 15.0 * scaleFactor * fontScaleFactor;
        if (s === "medium")
            return 17.0 * scaleFactor * fontScaleFactor;
        if (s === "large")
            return 20.0 * scaleFactor * fontScaleFactor;
        if (s === "x-large")
            return 24.0 * scaleFactor * fontScaleFactor;
    }

}
