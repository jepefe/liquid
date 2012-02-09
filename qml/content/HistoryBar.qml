/*
    Copyright (C) 2011 Jocelyn Turcotte <turcotte.j@gmail.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this program; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import QtQuick 1.1

DeckLayout {
    id: container
    property string toolTipText
    property variant toolTipPos
    itemOverlap: 4
    minIncrementOffset: 2
    zoomAmount: 1.0
    zoomPos: 1.0
    model: backend.tabManager.currentTab ? backend.tabManager.currentTab.history : null
    delegate: Item {
        property string title: modelData.location.title
        function activate() {
            modelData.goTo();
        }
        BorderImage {
            id: fancyBorder
            anchors.fill: parent
            anchors { bottomMargin: -3; topMargin: -3; leftMargin: -3; rightMargin: -3 }
            border { left: 13; top: 13; right: 13; bottom: 13 }
            source: "pics/card-border.png"
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat
            visible: modelData.relativeIndex == 0
        }
        Rectangle {
            anchors.fill: parent
            border.color: "#DDDDDD"
            radius: 5
            visible: !fancyBorder.visible
        }

        property bool layouted: true
        height: container.height
        width: container.height

        Item {
            id: iconContainer
            anchors.fill: parent
            anchors { leftMargin: 10; rightMargin: 10; topMargin: 0 }
            Image {
                id: icon
                width: 16
                height: 16
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                source: modelData.iconSource
            }
        }
    }
    MouseArea {
        property double _pressedZoomPos: 0.0
        property int _pressedX: 0
        property int _pressedDistance: 0
        property int _lastMoveX: 0
        property Item _pressedChild
        // Make sure the mouse area is under the rest so that it doesn't get returned by parent.childAt.
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        anchors.fill: container
        onPressed: {
            _pressedX = mouse.x; _pressedZoomPos = container.zoomPos;
            _pressedDistance = 0;
            _lastMoveX = mouse.x;
            var pressedChild = container.childAt(mouse.x, mouse.y);
            _pressedChild = pressedChild.layouted ? pressedChild : null;
        }
        onReleased: {
            if (_pressedDistance < 25 && container.childAt(mouse.x, mouse.y) === _pressedChild)
                _pressedChild.activate();
        }
        onPositionChanged: {
            if (mouse.buttons) {
                _pressedDistance += Math.abs(_lastMoveX - mouse.x);
                _lastMoveX = mouse.x;
                container.zoomPos = Math.max(0.0, Math.min(1.0, _pressedZoomPos - (mouse.x - _pressedX) / width));
            }
            var hitTest = container.childAt(mouseX, mouseY);
            toolTipPos = Qt.point(mouseX, mouseY);
            if (hitTest && hitTest.title)
                toolTipText = hitTest.title;
            else if (hitTest && hitTest.title === "")
                toolTipText = "[No title]";
            else
                toolTipText = "";
        }
        onExited: toolTipText = ""
    }
}
