/*
 * Copyright (C) 2021
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

DialogBase {
    id: dialog

    // note: connect the signal reply(bool) to process the response
    signal reply(bool accepted)

    onClosed: {
        reply((result === Dialog.Accepted));
    }
    onOpened: {
        result = Dialog.Rejected;
    }

    footer: Row {
        leftPadding: units.gu(1)
        rightPadding: units.gu(1)
        bottomPadding: units.gu(1)
        spacing: units.gu(1)
        layoutDirection: Qt.RightToLeft

        Button {
            flat: true
            text: qsTr("Ok")
            onClicked: {
                dialog.accept();
            }
        }
        Button {
            flat: true
            text: qsTr("Cancel")
            onClicked: {
                dialog.reject();
            }
        }
    }
}
