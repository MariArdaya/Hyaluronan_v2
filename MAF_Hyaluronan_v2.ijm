/*HABP particle quantification in a 63x confocal image
 * 
MARIA ARDAYA OCT 2019
@MariArdaya (Github)
mariaisabel.ardaya@ehu.eus

please, change the pre-established directories (see "saveAs" command paths)
*/ 


//Initial settings
run("Set Measurements...", "area mean limit redirect=None decimal=2");
run("Set Scale...", "distance=1 known=0.18 pixel=1 unit=micron");

//Global Variables
name=getTitle();

//Total area calculation
run("Split Channels");
selectWindow("C3-"+name);
run("Select All");
run("Measure");
area_total=getResult("Area", 0);
print("Total area is "+area_total+"");
run("Select None");

//Thresholding
selectWindow("C3-" +name);
setAutoThreshold("Intermodes dark");
setThreshold(70, 255);
waitForUser("Adjust Threshold");
getThreshold(low, up);
print("Threshold used = "+low);
run("Measure");
area_hyal=getResult("Area", 1);
per_hyal= (area_hyal/area_total)*100;
print("Hyaluronan labeling represents "+per_hyal+" % of total"); 
run("Create Selection");
roiManager("Add");
roiManager("Select", 0);
roiManager("Rename", "spots");
roiManager("Set Color", "yellow");
selectWindow("C3-" +name);
run("Make Binary");
run("Median...", "radius=1");
run("Analyze Particles...", "clear summarize");
saveAs("Results", "C:/...Summary0.csv");
close("Summary0.csv");

//cell mask+membrane mask+outmask
selectWindow("C2-" +name);
run("Gaussian Blur...", "sigma=2");
setAutoThreshold("Default dark");
setAutoThreshold("Intermodes dark");
setThreshold(20, 255);
waitForUser("Adjust Threshold");
getThreshold(low, up);
print("Threshold used = "+low);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Median...", "radius=5");
run("Create Selection");
roiManager("Add");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-3 pixel");
roiManager("Add");
roiManager("Select", 2);
makeRectangle(3, 3, 1018, 1018);
makeRectangle(3, 3, 1018, 1018);
makeRectangle(3, 3, 1018, 1018);
makeRectangle(3, 3, 1018, 1018);
makeRectangle(3, 3, 1018, 1018);
roiManager("Rename", "cell mask");
roiManager("Measure");
area_cell=getResult("Area", 0);
print("Cell area represents "+area_cell+"");
per_cell= (area_cell/area_total)*100;
print("GFAP labeling represents "+per_cell+" % of total");

roiManager("Select", 1);
run("Enlarge...", "enlarge=1 pixel");
roiManager("Add");
roiManager("Select", 3);
roiManager("Select", newArray(2,3));
roiManager("XOR");
roiManager("Add");
roiManager("Select", 4);
roiManager("Rename", "membrane mask");
roiManager("Measure");
roiManager("Select", 3);
run("Make Inverse");
roiManager("Add");
roiManager("Select", 5);
roiManager("Rename", "out space mask");
roiManager("Measure");
saveAs("Results", "C:/...resultsmask.csv");
roiManager("save", "C:/...ROI_mask.zip");

//overlay GFAP masks
selectWindow("C3-" +name);
roiManager("Select", 2);
run("Analyze Particles...", "pixel circularity=0.00-infinity show=Masks display clear summarize");
saveAs("Results", "C:/...Summaryspotsincell.txt");
close("Summaryspotsincell.txt");

selectWindow("C3-" +name);
roiManager("Select", 4);
run("Analyze Particles...", "pixel circularity=0.00-infinity show=Masks display clear summarize");
saveAs("Results","C:/...summarymembranecellmask.txt");
close("summarymembranecellmask.txt");

selectWindow("C3-" +name);
roiManager("Select", 5);
run("Analyze Particles...", "pixel circularity=0.00-infinity show=Masks display clear summarize");
saveAs("Results","C:/...summaryoutcellmask.txt");
close("summaryoutcellmask.txt");
saveAs("Results", "C:/...Summarysubzones.csv");

//Variable DAPI-total cell number
selectWindow("C1-"+name);
setThreshold(40, 255);
waitForUser("setThreshold");
run("Convert to Mask");
run("Median...", "radius=16");
run("Create Selection");
roiManager("Add");
roiManager("Select", 6);
roiManager("rename", "nuclei mask");
run("Analyze Particles...", "size=0-Infinity pixel show=[Bare Outlines] clear summarize");
saveAs("Results", "C:/...Summarynuclei.csv");
roiManager("Save", "C:/...RoinucleiSet.zip");

selectWindow("Log");
saveAs("Text");
close("Log");

Dialog.create("Close all images?");
Dialog.addChoice("Type:", newArray("Yes", "No"));
Dialog.show();
ans = Dialog.getChoice();
if (ans=="Yes") {
    run("Close All");
} 
