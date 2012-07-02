within Modelica_LinearSystems2.Utilities.Plot;
function diagram "Plot one diagram"
  import Modelica_LinearSystems2.Utilities.Plot.Types;
  import Modelica.Utilities.Streams.*;
   input Modelica_LinearSystems2.Utilities.Plot.Records.Diagram diagram
    "Diagram to be shown" annotation(Dialog);
   input Modelica_LinearSystems2.Utilities.Plot.Records.Device device=
      Modelica_LinearSystems2.Utilities.Plot.Records.Device()
    "Properties of device where figure is shown" annotation(Dialog);
protected
  Real mmToPixel= device.windowResolution/25.4;
  Real position[4];
  Integer style;
  Integer nCurves=size(diagram.curve,1);
  Boolean OK;
  Integer id;
algorithm
   position := {device.xTopLeft,
                device.yTopLeft,
                device.diagramWidth,
                diagram.heightRatio*device.diagramWidth}*mmToPixel;

   id:= createPlot(id=-1,
                   position=integer(position),
                   erase=true,
                   autoscale=true,
                   autoerase=false,
                   subPlot=1,
                   heading=diagram.heading,
                   grid=diagram.grid,
                   logX=diagram.logX,
                   logY=diagram.logY,
                   bottomTitle=diagram.xLabel,
                   leftTitle=diagram.yLabel,
                   color=device.autoLineColor,
                   legend=diagram.legend,
                   legendHorizontal=diagram.legendHorizontal,
                   legendFrame=diagram.legendFrame,
                   legendLocation=diagram.legendLocation);

   for i in 1:nCurves loop
       if diagram.curve[i].autoLine or
          diagram.curve[i].lineSymbol==Types.PointSymbol.None then
          style :=0;
       elseif diagram.curve[i].linePattern==Types.LinePattern.None then
          style :=-(diagram.curve[i].lineSymbol - 1);
       else
          style :=diagram.curve[i].lineSymbol - 1;
       end if;

       OK :=plotArray(diagram.curve[i].x,
                      diagram.curve[i].y,
                      legend=diagram.curve[i].legend,
                      style=style,
                      id=id);
    end for;

  annotation (interactive = true, Documentation(info="<html>
<p>
This function plots a set of 2-dimensional curves in a diagram.
For an overview, see the documentation of package
<a href=\"modelica://Modelica_LinearSystems2.Utilities.Plot\">Modelica_LinearSystems2.Utilities.Plot</a>.
</p>

</html>"));
end diagram;
