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
                  //curScore.startCmd();
                  cmd("select-similar");
                  //curScore.endCmd();

                  
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
                  
                  var partsList = curScore.excerpts;
                  console.log(excerptsAccess.count(partsList));
                  var partNum = 0;
                  for (partNum = 0; partNum < excerptsAccess.count(partsList); partNum++) {
                        addBreaksToPart (partsList [partNum].partScore, measNoPageBreak, measNoLineBreak, measNoSectionBreak, measNoNoBreak, true, true, true, true) 
                  }
                  
                  printList(measNoLineBreak);
                  Qt.quit();
            }
      }
      
      function printList(list) {
            var i = 0;
            for (i = 0; i < list.length; i++)
                  console.log(list[i])
      }
      
      function findMeasureNumber (mea) {
            if (!mea) {
                  console.log("findMeasureNumber: no measure provided");
                  return 0;
            }
            
            var ms = mea
            var i = 1;
            while (ms.prevMeasure) {
                  ms = ms.prevMeasure;
                  if (ms.is (curScore.firstMeasure)){
                        return i;
                  }
                  // todo: don't count measure if excluded from measure count
                  i++;
            }
            if (i > 1){
                  console.log("findMeasureNumber: measure not found");
                  return 0;
            }
            return 1; // it was measure number 1
      }
            
      function addBreaksToPart (part, pageArray, lineArray, sectionArray, noBreakArray, addPage, addLine, addSection, addNoBreak) {
            var cursor = part.newCursor ();
            cursor.track = 0;
            cursor.rewind(Cursor.SCORE_START)
            
            var curMeasure = 1;
            
            var pbreak = newElement(element.LAYOUT_BREAK);
            pbreak.setLayoutBreakType (LayoutBreak.PAGE);
            
            var lbreak = newElement(element.LAYOUT_BREAK);
            lbreak.setLayoutBreakType (LayoutBreak.LINE);
            
            var sbreak = newElement(element.LAYOUT_BREAK);
            sbreak.setLayoutBreakType (LayoutBreak.SECTION);
            
            var nobreak = newElement(element.LAYOUT_BREAK);
            nobreak.setLayoutBreakType (LayoutBreak.NOBREAK);
            
            do  {
                  if (addPage) {
                        if (arrayContains(pageArray, curMeasure))
                              cur.Add (pbreak.clone());
                  } else if (addLine) {
                        if (arrayContains(lineArray, curMeasure))
                              cur.Add (lbreak.clone());
                  } else if (addSection) {
                        if (arrayContains(sectionArray, curMeasure))
                              cur.Add (sbreak.clone());
                  } else if (addNoBreak) {
                        if (arrayContains(noBreakArray, curMeasure))
                              cur.Add (nobreak.clone());
                  }
                  i++
            } while (cursor.nextMeasure());
      }
      
      function arrayContains(array, value) {
            var i;
            for (i = 0; i < array.count; i++) {
                  if (array [i] == value)
                        return true
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
            text: qsTr("Please select a line break before running this plugin.")
            onAccepted: {
                  Qt.quit()
            }
      }
      QmlExcerptsListAccess  {
            id: excerptsAccess
      }
}