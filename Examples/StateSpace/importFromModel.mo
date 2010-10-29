within Modelica_LinearSystems2.Examples.StateSpace;
function importFromModel
  "This example demonstrates how to generate a linear state space system from a (nonlinear) Modelica moodel"
  extends Modelica.Icons.Function;

  import Modelica_LinearSystems2;
  import Modelica_LinearSystems2.StateSpace;

  input String modelName="Modelica_LinearSystems2.Controller.Examples.Components.DoublePendulum";
  input Real T_linearize=0
    "Simulate until T_linearize and then linearize the model";

  output StateSpace ss=StateSpace.Import.fromModel(modelName=modelName, T_linearize=T_linearize);
algorithm

annotation (interactive=true);
end importFromModel;
