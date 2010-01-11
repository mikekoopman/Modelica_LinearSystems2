within Modelica_LinearSystems2.Controller;
block Interpolator
  "Increasing the sampling frequency with linear interpolation and optional mean value filtering"
  extends Icons.PartialBlockIcon(cont=continuous);
  import Modelica_LinearSystems2.Controller.Types;
  parameter Modelica_LinearSystems2.Controller.Types.BlockTypeWithGlobalDefault
    blockType = Types.BlockTypeWithGlobalDefault.UseSampleClockOption
    "Type of block (Continuous/Discrete)" 
    annotation(Evaluate=true, Hide=true);
  final parameter Boolean continuous = blockType == Types.BlockTypeWithGlobalDefault.Continuous or 
                                 blockType == Types.BlockTypeWithGlobalDefault.UseSampleClockOption and 
                                 sampleClock.blockType == Types.BlockType.Continuous
    "= true, if continuous block, otherwise discrete block";
  parameter Integer outputSampleFactor(min=1)=1 if not continuous
    "Output sample time = outputSampleFactor * sampleClock.sampleTime" 
     annotation (Dialog(enable=blockType<>Modelica_LinearSystems2.Controller.Types.BlockTypeWithGlobalDefault.Continuous));
  parameter Integer inputSampleFactor(min=1)=1 if not continuous
    "Input sample time = inputSampleFactor * outputSampleFactor * sampleClock.sampleTime"
     annotation (Dialog(enable=blockType<>Modelica_LinearSystems2.Controller.Types.BlockTypeWithGlobalDefault.Continuous));
  parameter Boolean meanValueFilter = true
    "= true and discrete block, linearly interpolated signal is filtered by mean value filter"
    annotation(choices(__Dymola_checkBox=true));
  Modelica.Blocks.Interfaces.RealInput u
    "Continuous or discrete input signal of block" 
    annotation (extent=[-140, -20; -100, 20]);
  Modelica.Blocks.Interfaces.RealOutput y
    "Continuous or discrete output signal of block" 
    annotation (extent=[100, -10; 120, 10]);

protected
  outer SampleClock sampleClock "Global options";

  Internal.DiscreteInterpolator discreteInterpolator(
     outputSampleFactor = outputSampleFactor,
     inputSampleFactor = inputSampleFactor) if  not continuous 
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Internal.DiscreteFIR discreteFIR(sampleFactor=outputSampleFactor,
        a=fill(1/inputSampleFactor, inputSampleFactor)) if not continuous and meanValueFilter 
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Modelica.Blocks.Interfaces.RealOutput y_aux if not continuous and not meanValueFilter
    "Dummy port, if no filtering desired" 
    annotation (Placement(transformation(extent={{26,20},{46,40}})));
equation
   if continuous then
      y = u;
   end if;

  connect(discreteInterpolator.u, u) annotation (Line(
      points={{-42,0},{-120,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(discreteInterpolator.y, discreteFIR.u) annotation (Line(
      points={{-19,0},{18,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(discreteFIR.y, y) annotation (Line(
      points={{41,0},{110,0}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(discreteInterpolator.y, y_aux) annotation (Line(
      points={{-19,0},{0,0},{0,30},{36,30}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(y_aux, y) annotation (Line(
      points={{36,30},{60,30},{60,0},{110,0}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (
    Window(
      x=0.27,
      y=0.1,
      width=0.57,
      height=0.75),
    Icon(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics={
        Line(points={{-30,78},{-30,-46}}, color={192,192,192}),
        Polygon(
          points={{-30,92},{-38,70},{-22,70},{-30,90},{-30,92}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-42,-38},{82,-38}}, color={192,192,192}),
        Polygon(
          points={{90,-38},{68,-30},{68,-46},{90,-38}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-76,58},{-62,-44}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-50,58},{-88,58},{-70,92},{-50,58}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-30,-12},{20,40},{88,52}},
          color={0,0,0},
          smooth=Smooth.None),
        Rectangle(extent={{-36,-6},{-24,-18}}, lineColor={0,0,0}),
        Rectangle(extent={{14,46},{26,34}}, lineColor={0,0,0}),
        Rectangle(extent={{82,58},{94,46}}, lineColor={0,0,0}),
        Ellipse(
          extent={{-20,10},{-8,0}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-4,26},{8,16}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{34,48},{46,38}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{58,52},{70,42}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Text(
          visible=meanValueFilter,
          extent={{-28,94},{96,66}},
          lineColor={95,95,95},
          textString="filtered"),
        Text(
          extent={{-98,-56},{98,-90}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          textString="%inputSampleFactor*%outputSampleFactor")}),
    Diagram(coordinateSystem(
        preserveAspectRatio=true,
        extent={{-100,-100},{100,100}},
        grid={2,2}), graphics),
    Documentation(info="<html>
<p>
This block increases the sampling frequency by the integer factor <b>inputSampleFactor</b>.
This is performed by <b>linear interpolation</b> between the current and the last
sample leading to a delay of one input sampling period.
Optionally, the resulting signal is filtered with a mean value FIR-filter of length
inputSampleFactor, in order to remove undesired frequencies introduced by the linear
interpolation. In most cases it is adviceable to utilize this filter.
</p>

<p>
This block is demonstrated with example
<a href=\"Modelica://Modelica_LinearSystems2.Controller.Examples.Interpolator\">Examples.Interpolator</a>
leading to the following result when filtering a sine-signal with \"continous\" (interpolator1.y), \"discrete, unfiltered\" (interpolator2.y) and \"discrete, filtered\" (interpolator3.y) Interpolator:
</p>

<p align=\"center\">
<IMG SRC=\"../Extras/Images/Controller/Examples/Interpolator.png\">
</p>

</html>
"));

end Interpolator;