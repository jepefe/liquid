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
import liquidext 1.0

Item {
    id: container
    property int itemOverlap: 0
    property int scrollPos: 0
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property Item rightAlignedItem

    function layout() {
        var items = getItems();
        if (!items.length)
            return;

        // The itemOvelap is also substracted from the last item to allow any
        // item anchored to the container to overlap the last item.
        var contentsWidth = items.reduce(function(accum, val) { return accum + val.width - itemOverlap; }, 0);
        scrollPos = Math.max(0, Math.min(contentsWidth - width, scrollPos));

        var curMathX = -scrollPos;
        for (var i in items) {
            items[i].x = Math.max(0, Math.min(width, curMathX));
            curMathX += items[i].width - itemOverlap;
        }
    }

    function getItems() {
        var items = [];
        for (var i = 0; i < children.length; ++i)
            if (children[i].layouted)
                items.push(children[i]);
        return items;
    }

    onWidthChanged: layout()
    onScrollPosChanged: layout()
    onRightAlignedItemChanged: {
        if (!rightAlignedItem)
            return;

        // Find the scroll position to place the item on the left, then adjust with width to place it on the right.
        var items = getItems();
        var scrollPosToItem = 0;
        var found = false;
        for (var i in items) {
            if (items[i] === rightAlignedItem) {
                found = true;
                break;
            }
            scrollPosToItem += items[i].width - itemOverlap;
        }
        if (found)
            scrollPos = scrollPosToItem - (width - rightAlignedItem.width + itemOverlap);
    }

    Repeater {
        id: repeater
        onItemAdded: if (item.layouted && item.width) layout()
        onItemRemoved: layout()
    }
}
