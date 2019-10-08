import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0

MuseScore {
      menuPath: "Plugins.moveBreaksToParts"
      description: "This plugin moves breaks from the score to parts."
      version: "1.0"
      requiresScore: true
      onRun: {
            if (!curScore)
                  Qt.quit();
            
            if ((mscoreMajorVersion < 3) || (mscoreMinorVersion < 3)) {
                  versionError.open();
                  Qt.quit();
            } else if (curScore.selection.elements.length == 0) {
                  selectionError.open();
                  Qt.quit();
            } else if (curScore.selection.elements[0].type != Element.LAYOUT_BREAK ){
                  selectionError.open();
                  Qt.quit();
            } else {

                  cmd("select-similar");
                  
                  var elements = curScore.selection.elements;
                  
                  var measNoPageBreak = new Array();
                  var measNoLineBreak = new Array();
                  var measNoSectionBreak = new Array();
                  var measNoNoBreak = new Array();
                  
                  for (var idx = 0; idx < elements.length; idx++) {
                        var element = elements[idx];
                        if (element.type == Element.LAYOUT_BREAK ) {
                              if (element.layoutBreakType == LayoutBreak.PAGE)
                                    measNoPageBreak.push (findMeasureNumber (element.parent))
                              else if  (element.layoutBreakType == LayoutBreak.LINE)
                                    measNoLineBreak.push (findMeasureNumber (element.parent))
                              else if  (element.layoutBreakType == LayoutBreak.SECTION)
                                    measNoSectionBreak.push (findMeasureNumber (element.parent))
                              else if  (element.layoutBreakType == LayoutBreak.NOBREAK)
                                    measNoNoBreak.push (findMeasureNumber (element.parent))
                              else console.log("Error in finding layout break type")
                        }
                  }
                  
                  printList(measNoPageBreak, "measNoPageBreak: ");
                  printList(measNoLineBreak, "measNoLineBreak: ");
                  printList(measNoSectionBreak, "measNoSectionBreak: ");
                  printList(measNoNoBreak, "measNoNoBreak: ");

                  var partsList = curScore.excerpts;
                  var partNum;
                  for (partNum = 0; partNum < partsList.length; partNum++) {
                        console.log(partsList [partNum].title)
                        addBreaksToPart (partsList [partNum].partScore, measNoPageBreak, measNoLineBreak, measNoSectionBreak, measNoNoBreak, true, true, true, true) 
                  }
                  
                  
                  // delete measNoPageBreak;
                  // delete measNoLineBreak;
                  // delete measNoSectionBreak;
                  // delete measNoNoBreak;
                  Qt.quit();
            }
      }
      
      function printList(list, text) {
            var i = 0;
            for (i = 0; i < list.length; i++)
                  console.log(text, list[i])
      }
      
      function findMeasureNumber (mea) {
            if (!mea) {
                  console.log("findMeasureNumber: no measure provided");
                  return 0;
            }
            
            var ms = mea
            var i = 1;
            while (ms.prevMeasure) {
                  // todo: don't count measure if excluded from measure count
                  i++;

                  ms = ms.prevMeasure;
                  if (ms.is (curScore.firstMeasure))
                        return i;
            }
            if (i > 1){
                  console.log("findMeasureNumber: measure not found error");
                  return 0;
            }
            return 1; // it was measure number 1
      }
            
      function addBreaksToPart (part, pageArray, lineArray, sectionArray, noBreakArray, addPage, addLine, addSection, addNoBreak) {
            curScore.startCmd();
            
            var cursor = part.newCursor ();
            cursor.rewind(Cursor.SCORE_START)
            
            
            var pbreak = newElement (Element.LAYOUT_BREAK);
            pbreak.layoutBreakType = LayoutBreak.PAGE;
            
            var lbreak = newElement (Element.LAYOUT_BREAK);
            lbreak.layoutBreakType = LayoutBreak.LINE;
            
            var sbreak = newElement (Element.LAYOUT_BREAK);
            sbreak.layoutBreakType = LayoutBreak.SECTION;
            
            var nobreak = newElement (Element.LAYOUT_BREAK);
            nobreak.layoutBreakType = LayoutBreak.NOBREAK;
            
            var curMeasure = 1;
            do  {
                  if (addPage && arrayContains (pageArray, curMeasure))
                        cursor.add (pbreak.clone ());
                  else if (addLine && arrayContains(lineArray, curMeasure))
                        cursor.add (lbreak.clone ());
                  else if (addSection && arrayContains (sectionArray, curMeasure))
                        cursor.add (sbreak.clone ());
                  else if (addNoBreak&& arrayContains (noBreakArray, curMeasure))
                        cursor.add (nobreak.clone ());
                  curMeasure++
            } while (cursor.nextMeasure ());
            
            // delete pbreak;
            // delete lbreak;
            // delete sbreak;
            // delete nobreak;
            
            curScore.endCmd();
      }
      
      function arrayContains(array, value) {
            var i;
            for (i = 0; i < array.length; i++) {
                  if (array [i] == value) {
                        return true
                  }
            }
            
            return false
      }
      
      MessageDialog {
            id: versionError
            visible: false
            title: qsTr("Unsupported MuseScore version")
            text: qsTr("This plugin needs MuseScore 3.3 or later.")
            onAccepted: {
                  Qt.quit()
            }
      }
      MessageDialog {
            id: selectionError
            visible: false
            title: qsTr("Plugin selection error")
            text: qsTr("Please select a layout break before running this plugin.")
            onAccepted: {
                  Qt.quit()
            }
      }
}