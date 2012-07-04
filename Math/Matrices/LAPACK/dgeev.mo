within Modelica_LinearSystems2.Math.Matrices.LAPACK;
function dgeev
  "Compute the eigenvalues and the (real) left and right eigenvectors of matrix A"

  input Real A[:,size(A, 1)];

  output Real alphaReal[size(A, 1)]
    "Real part of alpha (eigenvalue=(alphaReal+i*alphaImag))";
  output Real alphaImag[size(A, 1)]
    "Imaginary part of alpha (eigenvalue=(alphaReal+i*alphaImag))";
  output Real lEigenVectors[size(A, 1),size(A, 1)]
    "left eigenvectors of matrix A";
  output Real rEigenVectors[size(A, 1),size(A, 1)]
    "right eigenvectors of matrix A";
  output Integer info;
protected
  Integer n=size(A, 1);
  Integer lwork=4*n;
  Real work[lwork];

external "Fortran 77" dgeev(
    "V",
    "V",
    n,
    A,
    n,
    alphaReal,
    alphaImag,
    lEigenVectors,
    n,
    rEigenVectors,
    n,
    work,
    size(work, 1),
    info) annotation(Library = {"lapack"});

  annotation (Documentation(info="Lapack documentation:

   Purpose
   =======

   DGEEV computes for an N-by-N real nonsymmetric matrix A, the
   eigenvalues and, optionally, the left and/or right eigenvectors.

   The right eigenvector v(j) of A satisfies
                    A * v(j) = lambda(j) * v(j)
   where lambda(j) is its eigenvalue.
   The left eigenvector u(j) of A satisfies
                 u(j)**H * A = lambda(j) * u(j)**H
   where u(j)**H denotes the conjugate transpose of u(j).

   The computed eigenvectors are normalized to have Euclidean norm
   equal to 1 and largest component real.

   Arguments
   =========

   JOBVL   (input) CHARACTER*1
           = 'N': left eigenvectors of A are not computed;
           = 'V': left eigenvectors of A are computed.

   JOBVR   (input) CHARACTER*1
           = 'N': right eigenvectors of A are not computed;
           = 'V': right eigenvectors of A are computed.

   N       (input) INTEGER
           The order of the matrix A. N >= 0.

   A       (input/output) DOUBLE PRECISION array, dimension (LDA,N)
           On entry, the N-by-N matrix A.
           On exit, A has been overwritten.

   LDA     (input) INTEGER
           The leading dimension of the array A.  LDA >= max(1,N).

   WR      (output) DOUBLE PRECISION array, dimension (N)
   WI      (output) DOUBLE PRECISION array, dimension (N)
           WR and WI contain the real and imaginary parts,
           respectively, of the computed eigenvalues.  Complex
           conjugate pairs of eigenvalues appear consecutively
           with the eigenvalue having the positive imaginary part
           first.

   VL      (output) DOUBLE PRECISION array, dimension (LDVL,N)
           If JOBVL = 'V', the left eigenvectors u(j) are stored one
           after another in the columns of VL, in the same order
           as their eigenvalues.
           If JOBVL = 'N', VL is not referenced.
           If the j-th eigenvalue is real, then u(j) = VL(:,j),
           the j-th column of VL.
           If the j-th and (j+1)-st eigenvalues form a complex
           conjugate pair, then u(j) = VL(:,j) + i*VL(:,j+1) and
           u(j+1) = VL(:,j) - i*VL(:,j+1).

   LDVL    (input) INTEGER
           The leading dimension of the array VL.  LDVL >= 1; if
           JOBVL = 'V', LDVL >= N.

   VR      (output) DOUBLE PRECISION array, dimension (LDVR,N)
           If JOBVR = 'V', the right eigenvectors v(j) are stored one
           after another in the columns of VR, in the same order
           as their eigenvalues.
           If JOBVR = 'N', VR is not referenced.
           If the j-th eigenvalue is real, then v(j) = VR(:,j),
           the j-th column of VR.
           If the j-th and (j+1)-st eigenvalues form a complex
           conjugate pair, then v(j) = VR(:,j) + i*VR(:,j+1) and
           v(j+1) = VR(:,j) - i*VR(:,j+1).

   LDVR    (input) INTEGER
           The leading dimension of the array VR.  LDVR >= 1; if
           JOBVR = 'V', LDVR >= N.

   WORK    (workspace/output) DOUBLE PRECISION array, dimension (LWORK)
           On exit, if INFO = 0, WORK(1) returns the optimal LWORK.

   LWORK   (input) INTEGER
           The dimension of the array WORK.  LWORK >= max(1,3*N), and
           if JOBVL = 'V' or JOBVR = 'V', LWORK >= 4*N.  For good
           performance, LWORK must generally be larger.

           If LWORK = -1, then a workspace query is assumed; the routine
           only calculates the optimal size of the WORK array, returns
           this value as the first entry of the WORK array, and no error
           message related to LWORK is issued by XERBLA.

   INFO    (output) INTEGER
           = 0:  successful exit
           < 0:  if INFO = -i, the i-th argument had an illegal value.
           > 0:  if INFO = i, the QR algorithm failed to compute all the
                 eigenvalues, and no eigenvectors have been computed;
                 elements i+1:N of WR and WI contain eigenvalues which
                 have converged.

   =====================================================================
"));
end dgeev;
