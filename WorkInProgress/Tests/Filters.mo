within Modelica_LinearSystems2.WorkInProgress.Tests;
package Filters
  function plotFilter
    import ZP = Modelica_LinearSystems2.ZerosAndPoles;
    import Modelica_LinearSystems2.Types;
     input Modelica_LinearSystems2.Types.AnalogFilter analogFilter=Types.AnalogFilter.CriticalDamping
      "Analog filter characteristics (CriticalDamping/Bessel/Butterworth/Chebyshev)";
     input Modelica_LinearSystems2.Types.FilterType filterType=Types.FilterType.LowPass
      "Type of filter (LowPass/HighPass)";
     input Modelica.SIunits.Frequency f_cut=3 "Cut-off frequency";
     input Real A_ripple(unit="dB") = 0.5
      "Pass band ripple for Chebyshev filter (otherwise not used)";
     input Boolean normalized=true
      "= true, if amplitude at f_cut decreases/increases 3 db (for low/high pass filter), otherwise unmodified filter";
  protected
     ZP filter1 = ZP.Design.filter(analogFilter, filterType, order=1, f_cut=f_cut, A_ripple=A_ripple, normalized=normalized);
     ZP filter2 = ZP.Design.filter(analogFilter, filterType, order=2, f_cut=f_cut, A_ripple=A_ripple, normalized=normalized);
     ZP filter3 = ZP.Design.filter(analogFilter, filterType, order=3, f_cut=f_cut, A_ripple=A_ripple, normalized=normalized);
     ZP filter4 = ZP.Design.filter(analogFilter, filterType, order=4, f_cut=f_cut, A_ripple=A_ripple, normalized=normalized);
     ZP filter5 = ZP.Design.filter(analogFilter, filterType, order=5, f_cut=f_cut, A_ripple=A_ripple, normalized=normalized);
  algorithm
     //ZP.Plot.bode(filter1);
     //ZP.Plot.bode(filter2);
     //ZP.Plot.bode(filter3);
     //ZP.Plot.bode(filter4);
     ZP.Plot.bode(filter5);
  end plotFilter;

  function plotFilter2
    import ZP = Modelica_LinearSystems2.ZerosAndPoles;
    import Modelica_LinearSystems2.Types;
     input Modelica_LinearSystems2.Types.FilterType filterType
      "Type of filter (LowPass/HighPass)";
     input Modelica.SIunits.Frequency f_cut=3 "Cut-off frequency";
     input Real A_ripple(unit="dB") = 0.5
      "Pass band ripple for Chebyshev filter (otherwise not used)";
     input Boolean normalized=true
      "= true, if amplitude at f_cut decreases/increases 3 db (for low/high pass filter), otherwise unmodified filter";
  algorithm
     plotFilter(Types.AnalogFilter.CriticalDamping, filterType, f_cut, A_ripple, normalized);
     plotFilter(Types.AnalogFilter.Bessel,          filterType, f_cut, A_ripple, normalized);
     plotFilter(Types.AnalogFilter.Butterworth,     filterType, f_cut, A_ripple, normalized);
     plotFilter(Types.AnalogFilter.Chebyshev,       filterType, f_cut, A_ripple, normalized);

  end plotFilter2;

  function plotFilter3
    import ZP = Modelica_LinearSystems2.ZerosAndPoles;
    import Modelica_LinearSystems2.Types;
     input Modelica.SIunits.Frequency f_cut=3 "Cut-off frequency";
     input Real A_ripple(unit="dB") = 0.5
      "Pass band ripple for Chebyshev filter (otherwise not used)";
     input Boolean normalized=true
      "= true, if amplitude at f_cut decreases/increases 3 db (for low/high pass filter), otherwise unmodified filter";
  algorithm
     plotFilter2(Types.FilterType.LowPass,  f_cut, A_ripple, normalized);
     plotFilter2(Types.FilterType.HighPass, f_cut, A_ripple, normalized);
  end plotFilter3;

  function compareBaseFiltersWithTietzeSchenk
    "Compare normalized base filters with the table of Tietze/Schenk Halbleiterschaltungstechnik"
    import Modelica_LinearSystems2.Types;
    import ZP = Modelica_LinearSystems2.ZerosAndPoles;
    import Modelica.Utilities.Streams.print;
    import Modelica_LinearSystems2.Math.Complex;
    input String outputFile = "";
  protected
    constant Real machEps = 100*Modelica.Constants.eps;
    constant Real eps = 0.001;
    ZP zp;
    Integer maxOrder = 5;
    Boolean evenOrder "= true, if even filter order (otherwise uneven)";
    Real c;
    Real k;
    Boolean gainIsOne;

    function printCoefficients
      "Transform coefficients to Tietze/Schenk and print them"
      /*  Tietze/Schenk:  (a1*p + 1); (b2*p^2 + a2*p + 1)
        ZerosAndPoles:  (p + a3)  ; (p^2 + b3*p + a3)
        Therefore:      a1 = 1/a3 ; b2 = 1/a3, a2 = b3/a3
    */
      input ZP zp;
      input String outputFile = "";
    protected
      Real k;
      Boolean gainIsOne;
    algorithm
      k :=ZP.Analysis.dcGain(zp);
      gainIsOne := Modelica_LinearSystems2.Math.isEqual(k, 1.0, machEps);
      if not gainIsOne then
         print("!!! Gain of base filter is wrong (should be one, but is " + String(k) + ")", outputFile);
      end if;

      for i in 1:size(zp.d1,1) loop
         print("  a = " + String(1/zp.d1[i],format="6.5f") + ", b = 0", outputFile);
      end for;

      for i in 1:size(zp.d2,1) loop
         print("  a = " + String(zp.d2[i,1]/zp.d2[i,2],format="6.5f") +
               ", b = " + String(1/zp.d2[i,2],format="6.5f"), outputFile);
      end for;
    end printCoefficients;

    function getAmplitude "Compute amplitude at w=1 and return it as string"
      input ZP zp;
      output String str;
    protected
      Complex c;
      Real A;
    algorithm
      c := ZP.Analysis.evaluate(zp, Complex(0,1.0));
      A :=Complex.'abs'(c);

      if Modelica_LinearSystems2.Math.isEqual(A, 10^(-3/20), machEps) then
         str :="amplitude(w=1) = -3db";
      elseif Modelica_LinearSystems2.Math.isEqual(A, sqrt(2)/2, machEps) then
         str :="amplitude(w=1) = sqrt(2)/2";
      else
         str :="amplitude(w=1) = " + String(A);
      end if;
    end getAmplitude;
  algorithm
    print("\n" +
          "... The following values should be identical to the tables in Abb. 13.14\n"+
          "... of Tietze/Schenk 2002, pp. 828-834", outputFile);

    // Critical damping
    print("\nCriticalDamping filter (all even coefficients are identical):", outputFile);

    for i in 1:maxOrder loop
       zp :=Modelica_LinearSystems2.ZerosAndPoles.Internal.baseFilter(
                                 Types.AnalogFilter.CriticalDamping, order=i);
       print("\n  order = " + String(i) + ", " + getAmplitude(zp), outputFile);

       // Check that all coefficients are identical
       assert(size(zp.n1,1) == 0 and
              size(zp.n2,1) == 0 and
              size(zp.d2,1) == 0, "CriticalDamping base filter is wrong (1)");
       c :=zp.d1[1];
       for j in 2:i loop
          assert(zp.d1[i] == c, "CriticalDamping base filter is wrong (2)");
       end for;

       // Check that dc gain is one
       k :=ZP.Analysis.dcGain(zp);
       gainIsOne := Modelica_LinearSystems2.Math.isEqual(k,1.0,machEps);
       assert(gainIsOne, "CriticalDamping base filter is wrong (3)");

       /* Check coefficients of first and second order transfer functions
        Tietze/Schenk:  (a1*p + 1); (b2*p^2 + a2*p + 1)
        ZerosAndPoles:  (p + a3)  ; (p + a3)^2 = p^2 + 2*a3*p + a3^2)
        Therefore:       a1 = 1/a3; a2 = 2/a3, b2 = 1/a3^2 
     */
       evenOrder :=mod(i, 2) == 0;
       if i==1 then
          print("  a = " + String(1/zp.d1[1]), outputFile);

       elseif evenOrder then
          print("  a = " + String(2/zp.d1[1]) + ", b = " + String(1/zp.d1[1]^2), outputFile);

       else
          print("  a = " + String(1/zp.d1[1]) + "\n" +
                "  a = " + String(2/zp.d1[1]) + ", b = " + String(1/zp.d1[1]^2), outputFile);

       end if;
    end for;

    // Bessel filter
    print("\nBessel filter:", outputFile);
    for i in 1:maxOrder loop
       zp :=Modelica_LinearSystems2.ZerosAndPoles.Internal.baseFilter(
                                 Types.AnalogFilter.Bessel, order=i);
       print("\n  order = " + String(i)  + ", " + getAmplitude(zp), outputFile);
       printCoefficients(zp, outputFile);
    end for;

    // Butterworth filter
    print("\nButterworth filter:", outputFile);
    for i in 1:maxOrder loop
       zp :=Modelica_LinearSystems2.ZerosAndPoles.Internal.baseFilter(
                                 Types.AnalogFilter.Butterworth, order=i);
       print("\n  order = " + String(i)  + ", " + getAmplitude(zp), outputFile);
       printCoefficients(zp, outputFile);
    end for;

    // Chebyshev filter
    print("\nChebyshev filter (A_ripple = 0.5 db):", outputFile);
    for i in 1:maxOrder loop
       zp :=Modelica_LinearSystems2.ZerosAndPoles.Internal.baseFilter(
                                 Types.AnalogFilter.Chebyshev, A_ripple=0.5, order=i);
       print("\n  order = " + String(i)  + ", " + getAmplitude(zp), outputFile);
       printCoefficients(zp, outputFile);
    end for;

    print("\nChebyshev filter (A_ripple = 3 db):", outputFile);
    for i in 1:maxOrder loop
       zp :=Modelica_LinearSystems2.ZerosAndPoles.Internal.baseFilter(
                                 Types.AnalogFilter.Chebyshev, A_ripple=3, order=i);
       print("\n  order = " + String(i)  + ", " + getAmplitude(zp), outputFile);
       printCoefficients(zp, outputFile);
    end for;
    annotation (Documentation(info="<html>
<p>
This function compares the filters with the ones from
</p>

<dl>
<dt>Tietze U., and Schenk C. (2002):</dt>
<dd> <b>Halbleiter-Schaltungstechnik</b>.
     Springer Verlag, 12. Auflage, pp. 815-852.</dd>
</dl>

<p>
In tables Abb. 13.14 on pages 828-834 of (Tietze/Schenk 2002), the filter coefficients are
given with respect to normalized filters for a cut-off angular frequency
of 1 rad/s. The normalization is performed in such a way that at the cut-off
frequency the transfer function has an amplitude of -3db (= 10^(-3/20) = 0.7079457..).
In the tables, not the exact -3db value is used but the approximation 
sqrt(2)/2 (= 0.707106...). Due to \"historical\" reasons, function baseFilter
from the Modelica_LinearSystems library uses -3db for Bessel and Chebyshev filters
and sqrt(2)/2 for CriticalDamping and Butterworth filters. Furthermore, the table 
gives the values only up to 4 significant digits. For these reasons, in this test
function the comparison is performed up to 3 significant digits.
</p>

</html>"));
  end compareBaseFiltersWithTietzeSchenk;
end Filters;
