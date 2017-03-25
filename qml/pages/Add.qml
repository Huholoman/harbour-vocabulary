/*
 * Copyright 2016,2017 Marcus Soll
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    
    Component.onCompleted: {
        functions.load_list()
    }

    Item {
        id: functions

        function save_word() {
            if(simple_interface.addVocabulary(word.text, translation.text)) {
                pageStack.pop()
            }
            else {
                panel.show()
            }
        }

        function load_list() {
            listModel.clear()
            var wordlist = simple_interface.getAllWords()
            for(var i = 0; i < wordlist.length; ++i) {
                var word = simple_interface.getWord(wordlist[i])
                originModel.append({"id": wordlist[i], "word": word})
                listModel.append({"id": wordlist[i], "word": word})
            }
        }

        function filter_list(filter) {
            listModel.clear()
            listModel.showItemNo = 0
            filter = filter.toLowerCase()
            for(var i = 0; i < originModel.count; ++i) {
                var item = originModel.get(i)
                if(item.word.toLowerCase().indexOf(filter) !== -1) {
                    listModel.append(item)
                }
            }
            listModel.showItemNo = Math.floor(Math.random()*listModel.count)
        }
    }
    
    ListModel {
        id: listModel

        property int showItemNo: 0
    }

    ListModel {
        id: originModel
    }

    Timer {
        id: search_timer
        repeat: false
        interval: 750

        property string lastWord: ""

        onTriggered: {
            var newWord = word.text.trim()
            if(newWord !== lastWord) {
                lastWord = newWord
                functions.filter_list(newWord)
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset priority of match")
                enabled: best_match_result_label.text !== ""
                onClicked: {
                    var word = listModel.get(listModel.showItemNo).word
                    var id = listModel.get(listModel.showItemNo).id
                    remorse.execute(qsTr("Resetting priority of ") + word, function(){ if(!simple_interface.setPriority(id,100)){ panel_priority.show() }})
                }
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Add vocabulary")
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                enabled: word.text.trim() != "" && translation.text.trim() != "" && word.text.trim() != best_match_result_label.text.trim()
                width: parent.width
                text: qsTr("Save vocabulary")
                onClicked: functions.save_word()
            }
            
            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                Label {
                    id: number_similar_label
                    text: qsTr("Number similar: ")
                    color: Theme.primaryColor
                }
                Label {
                    width: parent.width - number_similar_label.width
                    text: "" + listModel.count
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }
            
            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                Label {
                    id: best_match_label
                    text: qsTr("Possible match: ")
                    color: Theme.primaryColor
                }
                Label {
                    id: best_match_result_label
                    width: parent.width - best_match_label.width - best_match_reset_icon.width
                    text: listModel.count===0 || listModel.count === originModel.count ? "" : listModel.get(listModel.showItemNo).word
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
                IconButton {
                    id: best_match_reset_icon
                    height: best_match_label.height
                    icon.source: "image://theme/icon-m-forward"
                    visible: best_match_result_label.text != ""
                    onClicked: {
                        listModel.showItemNo = (listModel.showItemNo + 1) % listModel.count
                    }
                }
            }

            TextArea {
                id: word
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input word or phrase here")
                label: qsTr("Word / phrase")
                onTextChanged: search_timer.restart()
            }

            TextArea {
                id: translation
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input translation here")
                label: qsTr("Translation")
            }
        }
    }

    RemorsePopup {
        id: remorse
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save vocabulary")
    }

    UpperPanel {
        id: panel_priority
        text: qsTr("Can not set priority")
    }
}
