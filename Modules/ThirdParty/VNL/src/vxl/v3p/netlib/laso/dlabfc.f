C
C***********************************************************************
C
      SUBROUTINE DLABFC(N, NBAND, A, SIGMA, NUMBER, LDE,
     1  EIGVEC, NUML, LDAD, ATEMP, D, ATOL)
C
C  THIS SUBROUTINE FACTORS (A-SIGMA*I) WHERE A IS A GIVEN BAND
C  MATRIX AND SIGMA IS AN INPUT PARAMETER.  IT ALSO SOLVES ZERO
C  OR MORE SYSTEMS OF LINEAR EQUATIONS.  IT RETURNS THE NUMBER
C  OF EIGENVALUES OF A LESS THAN SIGMA BY COUNTING THE STURM
C  SEQUENCE DURING THE FACTORIZATION.  TO OBTAIN THE STURM
C  SEQUENCE COUNT WHILE ALLOWING NON-SYMMETRIC PIVOTING FOR
C  STABILITY, THE CODE USES A GUPTA'S MULTIPLE PIVOTING
C  ALGORITHM.
C
C  FORMAL PARAMETERS
C
      INTEGER N, NBAND, NUMBER, LDE, NUML, LDAD
      DOUBLE PRECISION A(NBAND,1), SIGMA, EIGVEC(LDE,1),
     1  ATEMP(LDAD,1), D(LDAD,1), ATOL
C
C  LOCAL VARIABLES
C
      INTEGER I, J, K, KK, L, LA, LD, LPM, M, NB1
      DOUBLE PRECISION ZERO(1)
C
C  FUNCTIONS CALLED
C
      INTEGER MIN0
      DOUBLE PRECISION DABS
C
C  SUBROUTINES CALLED
C
C     DAXPY, DCOPY, DSWAP
C
C
C  INITIALIZE
C
      ZERO(1) = 0.0D0
      NB1 = NBAND - 1
      NUML = 0
      CALL DCOPY(LDAD*NBAND, ZERO, 0, D, 1)
C
C   LOOP OVER COLUMNS OF A
C
      DO 100 K = 1, N
C
C   ADD A COLUMN OF A TO D
C
         D(NBAND, NBAND) = A(1,K) - SIGMA
         M = MIN0(K, NBAND) - 1
         IF(M .EQ. 0) GO TO 20
         DO 10 I = 1, M
            LA = K - I
            LD = NBAND - I
            D(LD,NBAND) = A(I+1, LA)
   10    CONTINUE
C
   20    M = MIN0(N-K, NB1)
         IF(M .EQ. 0) GO TO 40
         DO 30 I = 1, M
            LD = NBAND + I
            D(LD, NBAND) = A(I+1, K)
   30    CONTINUE
C
C   TERMINATE
C
   40    LPM = 1
         IF(NB1 .EQ. 0) GO TO 70
         DO 60 I = 1, NB1
            L = K - NBAND + I
            IF(D(I,NBAND) .EQ. 0.0D0) GO TO 60
            IF(DABS(D(I,I)) .GE. DABS(D(I,NBAND))) GO TO 50
            IF((D(I,NBAND) .LT. 0.0D0 .AND. D(I,I) .LT. 0.0D0)
     1        .OR. (D(I,NBAND) .GT. 0.0D0 .AND. D(I,I) .GE. 0.0D0))
     2        LPM = -LPM
            CALL DSWAP(LDAD-I+1, D(I,I), 1, D(I,NBAND), 1)
            CALL DSWAP(NUMBER, EIGVEC(L,1), LDE, EIGVEC(K,1), LDE)
   50       CALL DAXPY(LDAD-I, -D(I,NBAND)/D(I,I), D(I+1,I), 1,
     1        D(I+1,NBAND), 1)
            CALL DAXPY(NUMBER, -D(I,NBAND)/D(I,I), EIGVEC(L,1),
     1        LDE, EIGVEC(K,1), LDE)
   60    CONTINUE
C
C  UPDATE STURM SEQUENCE COUNT
C
   70    IF(D(NBAND,NBAND) .LT. 0.0D0) LPM = -LPM
         IF(LPM .LT. 0) NUML = NUML + 1
         IF(K .EQ. N) GO TO 110
C
C   COPY FIRST COLUMN OF D INTO ATEMP
         IF(K .LT. NBAND) GO TO 80
         L = K - NB1
         CALL DCOPY(LDAD, D, 1, ATEMP(1,L), 1)
C
C   SHIFT THE COLUMNS OF D OVER AND UP
C
         IF(NB1 .EQ. 0) GO TO 100
   80    DO 90 I = 1, NB1
            CALL DCOPY(LDAD-I, D(I+1,I+1), 1, D(I,I), 1)
            D(LDAD,I) = 0.0D0
   90    CONTINUE
  100 CONTINUE
C
C  TRANSFER D TO ATEMP
C
  110 DO 120 I = 1, NBAND
         L = N - NBAND + I
         CALL DCOPY(NBAND-I+1, D(I,I), 1, ATEMP(1,L), 1)
  120 CONTINUE
C
C   BACK SUBSTITUTION
C
      IF(NUMBER .EQ. 0) RETURN
      DO 160 KK = 1, N
         K = N - KK + 1
         IF(DABS(ATEMP(1,K)) .LE. ATOL)
     1     ATEMP(1,K) = DSIGN(ATOL,ATEMP(1,K))
C
  130    DO 150 I = 1, NUMBER
            EIGVEC(K,I) = EIGVEC(K,I)/ATEMP(1,K)
            M = MIN0(LDAD, K) - 1
            IF(M .EQ. 0) GO TO 150
            DO 140 J = 1, M
                L = K - J
                EIGVEC(L,I) = EIGVEC(L,I) - ATEMP(J+1,L)*EIGVEC(K,I)
  140       CONTINUE
  150    CONTINUE
  160 CONTINUE
      RETURN
      END
