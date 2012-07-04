within Modelica_LinearSystems2.Math.Matrices.LAPACK;
function dpotrf
  "Computes the Cholesky factorization of a real symmetric positive definite matrix A"

  extends Modelica.Icons.Function;
  input Real A[:, size(A,1)] "Real symmetric positive definite matrix A";
  input Boolean upper=true "True if the upper triangle of A is provided";

  output Real Acholesky[size(A,1),size(A,1)]=A "Cholesky factor";
  output Integer info;
protected
  String uplo=if upper then "U" else "L";
  Integer n=size(A,1);
  Integer lda=max(1,n);
  external "FORTRAN 77" dpotrf(uplo, n, Acholesky, lda, info) annotation (Library="Lapack");

  annotation (
    Documentation(info="Lapack documentation:

   Purpose
   =======

   DPOTRF computes the Cholesky factorization of a real symmetric
   positive definite matrix A.

   The factorization has the form
      A = U**T * U,  if UPLO = 'U', or
      A = L  * L**T,  if UPLO = 'L',
   where U is an upper triangular matrix and L is lower triangular.

   This is the block version of the algorithm, calling Level 3 BLAS.

   Arguments
   =========

   UPLO    (input) CHARACTER*1
           = 'U':  Upper triangle of A is stored;
           = 'L':  Lower triangle of A is stored.

   N       (input) INTEGER
           The order of the matrix A.  N >= 0.

   A       (input/output) DOUBLE PRECISION array, dimension (LDA,N)
           On entry, the symmetric matrix A.  If UPLO = 'U', the leading
           N-by-N upper triangular part of A contains the upper
           triangular part of the matrix A, and the strictly lower
           triangular part of A is not referenced.  If UPLO = 'L', the
           leading N-by-N lower triangular part of A contains the lower
           triangular part of the matrix A, and the strictly upper
           triangular part of A is not referenced.

           On exit, if INFO = 0, the factor U or L from the Cholesky
           factorization A = U**T*U or A = L*L**T.

   LDA     (input) INTEGER
           The leading dimension of the array A.  LDA >= max(1,N).

   INFO    (output) INTEGER
           = 0:  successful exit
           < 0:  if INFO = -i, the i-th argument had an illegal value
           > 0:  if INFO = i, the leading minor of order i is not
                 positive definite, and the factorization could not be
                 completed.

   =====================================================================  "));

end dpotrf;
