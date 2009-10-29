within Modelica_LinearSystems2.Tests.Design;
function testPoleAssignment "Function to assess algorithms for pole assignment"
  extends Modelica.Icons.Function;

  import Modelica_LinearSystems2.Math.Complex;
  import Re = Modelica_LinearSystems2.Math.Complex.real;
  import Im = Modelica_LinearSystems2.Math.Complex.imag;
  import Modelica_LinearSystems2.Math.Matrices;
  import Modelica_LinearSystems2.Tests.Design;
  import Modelica.Utilities.Streams.print;
  import Modelica_LinearSystems2.Tests.Internal.DesignData;

  annotation (Documentation(info="<html>
<p>
Computes the gain vector k for the state space system
<pre> 
ss = StateSpace(A=[-1,1;0,-2],B=[0, 1],C=[1,0; 0, 1],D=[0; 0])
</pre>
such that for the state feedback 
<pre>u = -k*y = -k*x</pre> the closed-loop
poles are placed at 
<pre>p = {-3,-4}.</pre>
</html>"));

  input DesignData data=Modelica_LinearSystems2.Tests.Design.data_Benner6(12);
  input Types.AssignPolesMethod method=Tests.Types.AssignPolesMethod.KNV
    "method for pole assignment";

protected
  Boolean isKprovided=min(size(data.K))>0;
  Real Ki[:,:]=if isKprovided then data.K else fill(0,0,0);
  Integer n=size(data.A, 1);
  Real S[n,n] "closed loop system matrix A-BK";
  Modelica_LinearSystems2.StateSpace ss=Modelica_LinearSystems2.StateSpace(A=data.A, B=data.B, C=zeros(1,n), D=zeros(1,size(data.B,2)));

public
  output Real K[size(data.B, 2),size(data.A, 1)] "Feedback gain matrix";
  output Complex calcPoles[size(data.A, 1)];
  output Real kappa2 "condition number kappa_2(X) = ||X||_2 * ||inv(X)||_2";
  output Real kappaF "condition number kappa_F(X) = ||X||_F * ||inv(X)||_F";
  output Real zeta
    "condition number by Byers, zeta(X) = (||X||_F)^2 + (||inv(X)||_F)^2";
  output Real cInf "condition number vu1=||c||_inf = max(c_j)";
  output Real nu2 "Euclidean norm of the feedback matrix";
  output Real nuF "Frobenius norm of the feedback matrix";
  output Real dlambda "Distance between the assigned and the calculated poles";
  output Real gap=0.0;
  output Real Jalpha[11]
    "Combined condition number, JKX=alpha/2*(kappa2X_B) + (1-alpha)/2*normFroK^2";
  output Complex X[:,:] "right eigenvectors of the closed loop system";

algorithm
  if method == Tests.Types.AssignPolesMethod.KNV then
// extented robust KNV-algortihm according to MATLAB's place-function
     (K,X) := Modelica_LinearSystems2.StateSpace.Internal.assignPolesMI_rob4(data.A, data.B, data.assignedPoles);
     S := data.A - data.B*K;
     calcPoles := Complex.eigenValues(S);
     if isKprovided then
       gap := Modelica.Math.Matrices.norm(K - Ki);
     end if;
  elseif method == Modelica_LinearSystems2.Tests.Types.AssignPolesMethod.Schur then
    (K,S,calcPoles,,,,X) := Modelica_LinearSystems2.StateSpace.Design.assignPolesMI(ss, data.assignedPoles, -1e10, Modelica.Math.Matrices.norm(ss.A, 1)*1e-12, true);
    if isKprovided then
      gap := Modelica.Math.Matrices.norm(K - Ki);
    end if;
  else
    assert(false, "Argument method (= " + String(method) + ") of testPoleAssignment is wrong. It has to be \"KNV\" or \"Schur\"");
  end if;

  (kappa2,kappaF,,cInf,nu2,nuF,zeta,Jalpha,dlambda) := conditionNumbers(K, X, data.assignedPoles, calcPoles);

  Matrices.printMatrix(K, 6, "K");
  Complex.Vectors.print("assignedPoles", data.assignedPoles);
  Complex.Vectors.print("calcPoles", calcPoles);
  Matrices.printMatrix(Re(X), 6, "ReX");
  Matrices.printMatrix(Im(X), 6, "ImX");
  print("kappa2 " + String(kappa2));
  print("kappaF " + String(kappaF));
  print("zeta " + String(zeta));
  print("cInf " + String(cInf));
  print("nu2 " + String(nu2));
  print("nuF " + String(nuF));
  print("dlambda " + String(dlambda));
  if isKprovided then
    print("gap " + String(gap));
  end if;
  print("Jalpha = "+Modelica_LinearSystems2.Math.Vectors.printVector(Jalpha));

end testPoleAssignment;
