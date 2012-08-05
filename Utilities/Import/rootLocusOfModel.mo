within Modelica_LinearSystems2.Utilities.Import;
function rootLocusOfModel
  "Return the root locus of one parameter (= eigen values of the model that is linearized for every parameter value)"
  import Modelica.Utilities.Streams.print;
  input String modelName "Name of the Modelica model" annotation(Dialog(__Dymola_translatedModel));
  input Modelica_LinearSystems2.Records.ParameterVariation modelParam[:]
    "Model parameter to be varied and modified values for other parameters";
  input Boolean linearizeAtInitial=true
    "= true, if linearization at inital time; otherwise simulate until t_linearize"
     annotation (choices(__Dymola_checkBox=true));
  input Modelica.SIunits.Time t_linearize= 0
    "Simulate until t_linearize and then linearize, if linearizeAtInitial == false"
                                                                                    annotation(Dialog(enable=not linearizeAtInitial));
  input Modelica_LinearSystems2.Records.SimulationOptionsForLinearization simulationSetup=
      Modelica_LinearSystems2.Records.SimulationOptionsForLinearization()
    "Simulation options it t_linearize > 0, if linearizeAtInitial == false" annotation(Dialog(enable=not linearizeAtInitial));
  input Boolean reorder=false
    "True, if eigen values shall be reordered so that they are closest to the previous ones";
  output Real Re[:,:]
    "Re[nx,np] Real values of eigenvalues Re[j,i], where i are the different parameter values and j the eigenvalue numbers";
  output Real Im[:,:]
    "Im[nx,np] Imaginary values of eigenvalues Im[j,i], where i are the different parameter values and j the eigenvalue numbers";
  output Real s[:]
    "s[np] The different parameter values s[i] associated with Re[i,j] and Im[i,j]";
  output String paramName "Name of the parameter that was varied";
  output String paramUnit "Unit of parameter paramName";
protected
  Integer nParam = size(modelParam,1);
  Boolean OK;
  String parameterModel="_rootLocusOfOneParameter_model";
  String parameterModelFile = parameterModel + ".mo";
  String str;
  Integer index_p_var;
  Integer is[:] "File indices X of the dslinX.mat files";
  Integer np;

  String fileName="dslin";
  String fileName2;
  Real nxMat[1,1];
  Integer ABCDsizes[2];
  Integer nx;
  Integer nu;
  Integer ny;
  Boolean newModel=false;
  Boolean first;
  Real Min;
  Real Max;
  Real logMin;
  Real logMax;
algorithm
  // Check that the system has eigen values
  // assert(nx > 0,"Model " + modelName + " does not has states. Therefore, root locus does not make sense.");

  // Determine the parameter to be varied and assign new parameter values to the model if necessary
  if nParam == 0 then
     // No parameter defined
     Modelica.Utilities.Streams.error("No parameter defined that shall be varied for the root locus");

  elseif nParam == 1 then
     // Exactly one parameter defined
     assert(modelParam[1].nVar > 1, "One parameter defined, but nVar (= the number of variations) is not > 1");
     np :=modelParam[1].nVar;
     index_p_var :=1;
     OK :=closeModel();

  else
     // More as one parameter defined; find the parameter to be varied
     index_p_var :=0;
     for i in 1:nParam loop
        if modelParam[i].nVar > 1 then
           if index_p_var > 0 then
              Modelica.Utilities.Streams.print("Parameters " + modelParam[index_p_var] + " and " + modelParam[i] +
                                               " shall be varied,\n" + "but this is only possible for one parameter.\n"+
                                               " Therefore, the variation over " + modelParam[i] + " is not performed.");
           else
              index_p_var :=i;
           end if;
        end if;
     end for;
     assert(index_p_var > 0, "No parameter defined that shall be varied for the root locus.");
     np :=modelParam[index_p_var].nVar;

     // Translate model and set the new parameter values
     OK:=translateModel(modelName);
     assert(OK, "Translation of model " + modelName + " failed.");
     for i in 1:nParam loop
        if i <> index_p_var then
           OK :=SetVariable(modelParam[i].Name, modelParam[i].Value);
           assert(OK, "Setting parameter " + modelParam[i].Name + " = " + String(modelParam[i].Value) + " failed.");
        end if;
     end for;
  end if;

  // Parameter that is varied
  paramName :=modelParam[index_p_var].Name;
  paramUnit :=modelParam[index_p_var].Unit;

  // Check min/max values
  Min :=modelParam[index_p_var].Min;
  Max :=modelParam[index_p_var].Max;
  assert(Min > -1e99, "Minimum value not set for parameter to be varied: " + paramName);
  assert(Max <  1e99, "Maximum value not set for parameter to be varied: " + paramName);

  // Compute all parameter values
  if modelParam[index_p_var].logVar then
     // logarithmic spacing
     assert(Min*Max >= 0.0, "Since logVar = true for parameter to be varied: " + paramName +
                            "\nThe Min and Max values need to have the same sign");
     if Min < 0.0 then
        logMin :=-log10(Min);
     elseif Min > 0.0 then
        logMin :=log10(Min);
     else
        // Min = 0.0
        logMin :=log10(1e-15);
     end if;

     if Max < 0.0 then
        logMax :=-log10(Max);
     elseif Max > 0.0 then
        logMax :=log10(Max);
     else
        // Max = 0.0
        logMax :=-log10(1e-15);
     end if;

     s := linspace(logMin, logMax, np);
     for i in 1:size(s,1) loop
       s[i] :=10^s[i];
     end for;
  else
    s := linspace(Min, Max, np);
  end if;

  is := 1:np;
  if linearizeAtInitial then
    // Linearization of all parameter variants at once at the initial point
    OK :=simulateMultiExtendedModel(
      problem=modelName,
      startTime=0,
      stopTime=0,
      initialNames={paramName,"linearize:"},
      initialValues=[s,is],
      finalNames=fill("", 0),
      method=simulationSetup.method,
      tolerance=simulationSetup.tolerance,
      fixedstepsize=simulationSetup.fixedStepSize);
    assert(OK, "Linearization with function simulateMultiExtendedModel failed\n(maybe some parameter values are not meaningful?).");
  else
    // Simulate always until t_lineare and only then linearize
    Modelica.Utilities.Streams.error("Option not yet implemented");
  end if;

  // Determine array dimensions of the first linearization point
  fileName2 := fileName+String(is[1])+".mat";
  nxMat :=readMatrix(fileName2, "nx", 1, 1);
  ABCDsizes :=readMatrixSize(fileName2, "ABCD");
  nx:=integer(nxMat[1, 1]);
  nu:=ABCDsizes[2] - nx;
  ny:=ABCDsizes[1] - nx;

  // Read all matrices from file, compute eigenvalues and store them in output arrays
  (Re,Im) :=Modelica_LinearSystems2.Internal.eigenValuesFromLinearization(is, nx, nu, ny, reorder);

  annotation (__Dymola_interactive=true);
end rootLocusOfModel;