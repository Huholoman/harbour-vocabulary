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

    property int word_id: 0
    property bool word_changed: false

    onStatusChanged: {
        if(word_changed === true) {
            word_text.text = simple_interface.getWord(page.word_id)
            translation_text.text = simple_interface.getTranslationOfWord(page.word_id)
            priority.value = simple_interface.getPriorityOfWord(page.word_id)
            creation_text.text = simple_interface.getCreationDate(page.word_id).toLocaleDateString()
            modification_text.text = simple_interface.getModificationDate(page.word_id).toLocaleDateString()
            language_text.text = simple_interface.getLanguageName(simple_interface.getLanguageId(page.word_id))
            number_asked_text.text = "" + simple_interface.getNumberAsked(page.word_id)
            number_correct_text.text = "" + simple_interface.getNumberCorrect(page.word_id)

            var last_page = pageStack.previousPage(page)
            last_page.word_changed = true
            last_page.word_id = page.word_id

            word_changed = false
        }
    }

    RemorsePopup {
        id: remorse_popup
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not reset test count")
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset test count")
                onClicked: remorse_popup.execute(qsTr("Reset test count"), function() {if(!simple_interface.resetTestCounts(page.word_id)) { panel.show() } else {number_asked_text.text = "0"; number_correct_text.text = "0"} })
            }

            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Edit.qml"), { word_id: page.word_id })
                }
            }

            MenuItem {
                text: qsTr("Show on cover")
                onClicked: {
                    random_vocabulary.word = word_text.text
                    random_vocabulary.translation = translation_text.text
                }
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("Details")
            }

            Row {
                IconButton {
                    id: word_icon
                    height: word.height
                    width: height
                    icon.source: "image://theme/icon-s-clipboard"
                    onClicked: Clipboard.text = word_text.text
                }

                Label {
                    id: word
                    text: qsTr("Word: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: word_text
                    width: column.width - word.width - word_icon.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getWord(page.word_id)
                }
            }

            Row {
                IconButton {
                    id: translation_icon
                    height: translation.height
                    width: height
                    icon.source: "image://theme/icon-s-clipboard"
                    onClicked: Clipboard.text = translation_text.text
                }

                Label {
                    id: translation
                    text: qsTr("Translation: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: translation_text
                    width: column.width - translation.width - translation_icon.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getTranslationOfWord(page.word_id)
                }
            }

            Slider {
                id: priority
                width: column.width
                enabled: false
                handleVisible: false
                minimumValue: 1
                maximumValue: 100
                label: qsTr("Priority")
                valueText: "" + value
                value: simple_interface.getPriorityOfWord(page.word_id)
            }

            Row {
                Label {
                    id: creation
                    text: qsTr("Creation: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: creation_text
                    width: column.width - creation.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getCreationDate(page.word_id).toLocaleDateString()
                }
            }

            Row {
                Label {
                    id: modification
                    text: qsTr("Modification: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: modification_text
                    width: column.width - modification.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getModificationDate(page.word_id).toLocaleDateString()
                }
            }

            Row {
                Label {
                    id: language
                    text: qsTr("Language: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: language_text
                    width: column.width - modification.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getLanguageName(simple_interface.getLanguageId(page.word_id))
                }
            }

            Row {
                Label {
                    id: percentage_correct
                    text: qsTr("Percentage correct: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: percentage_correct_text
                    width: column.width - percentage_correct.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text:parseInt(number_asked_text.text) !== 0 ? "" + Math.round(100.0 * parseInt(number_correct_text.text) / parseInt(number_asked_text.text)) + "%" : ""
                }
            }

            Row {
                Label {
                    id: number_correct
                    text: qsTr("Number correct: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: number_correct_text
                    width: column.width - number_correct.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: "" + simple_interface.getNumberCorrect(page.word_id)
                }
            }

            Row {
                Label {
                    id: number_asked
                    text: qsTr("Number asked: ")
                    color: Theme.highlightColor
                }

                Label {
                    id: number_asked_text
                    width: column.width - number_asked.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: "" + simple_interface.getNumberAsked(page.word_id)
                }
            }
        }
    }
}
