!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!C  PROGRAMA PARA GENERAR ARCHIVO DE ENTRADA PARA EL PROGRAMA DE ELEMENTOS    C
!C                   FINITOS DESARROLLADO POR JUAN CARLOS.                    C
!C                                                                            C
!C EL PROGRAMA SE ALIMENTA POR EL ARCHIVO *.msh GENERADO POR EL PROGRAMA GMSH C
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!C
!C
PROGRAM MALLAS
!
!
USE OMP_LIB
IMPLICIT NONE
!
!
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!    DECLARACIÓN DE VARIABLES
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!
!
!VARIABLES GENERALES.
INTEGER I, J, K, L, M, N, O, P, Q, F
INTEGER II, JJ, KK, LL, MM, NN, NPINCO
INTEGER NIMPRIME, IFLAG, IPOS
INTEGER NP, ND, NEL, NMAT, PROBLEM
INTEGER NGF
INTEGER NX, NY, NLF, NTC, TONDA
INTEGER NG  !NÚMERO DE PUNTOS DE GAUSS.
INTEGER PARA    !PARA SABER SI SE IMPRIME O NO INFORMACIÓN PARA EL PARAVIEW.
INTEGER CONTA1, CONTA2, CONTA3, CONTA4, CONTA5, CONTA6
INTEGER NP1
REAL*8 JUAN
REAL*8 NUHS, BETAHS, RHOHS                  !PROPIEDADES DEL HALF-SPACE
REAL*8, ALLOCATABLE, DIMENSION(:):: X, Y    !COORDINATES POINTS.
INTEGER, ALLOCATABLE, DIMENSION(:):: IDN    !LABEL POINTS.
INTEGER, ALLOCATABLE, DIMENSION(:):: TP     !ELEMENT TYPE 2: TRIANGLE, 3: CUADRILATERAL
INTEGER, ALLOCATABLE, DIMENSION(:):: TPB    !AUXILIAR
INTEGER, ALLOCATABLE, DIMENSION(:):: TLRX   !NÚMERO DE LINEAS CON RESTRICCIONES EN X.
INTEGER, ALLOCATABLE, DIMENSION(:):: TLRY   !NÚMERO DE LINEAS CON RESTRICCIONES EN Y.
INTEGER, ALLOCATABLE, DIMENSION(:):: TLF    !NÚMERO DE LINEAS CARGADAS.
INTEGER, ALLOCATABLE, DIMENSION(:):: NODEIZ, NODEDER, NODECEN
INTEGER, ALLOCATABLE, DIMENSION(:,:):: BOUNDARYH
INTEGER, ALLOCATABLE, DIMENSION(:,:):: BOUNDARYS
INTEGER, ALLOCATABLE, DIMENSION(:,:):: INCOH
INTEGER, ALLOCATABLE, DIMENSION(:,:):: INCOS
INTEGER, ALLOCATABLE, DIMENSION(:):: NODEIZINCO, NODEDERINCO, NODECENINCO
INTEGER, ALLOCATABLE, DIMENSION(:):: PROP   !VECTOR PARA DETERMINAR LAS PROPIEDADES DE LOS ELEMENTOS.
INTEGER, ALLOCATABLE, DIMENSION(:,:):: MIE  !CONECTIVIDADES.
INTEGER, ALLOCATABLE, DIMENSION(:):: UX, UY !GRADOS DE LIBERTAD DESPLAZAMIENTOS.
INTEGER, ALLOCATABLE, DIMENSION(:,:):: NODEX, NODEY !GRADOS DE LIBERTAD RESTRINGIDOS EN CADA DIRECCIÓN.
INTEGER, ALLOCATABLE, DIMENSION(:,:):: NF   !NODOS CARGADOS
INTEGER, ALLOCATABLE, DIMENSION(:,:):: TPLOAD   !TIPO DE CARGA SOBRE EL NODO. HACE REFERENCIA AL NÚMERO DE CARGA Y SE COMPLEMENTA CON EL VALOR Y LA DIRECCIONALIDAD.
REAL*8, ALLOCATABLE, DIMENSION(:,:):: MATERIAL  !VECTOR CON LA INFORMACIÓN DE LOS MATERIALES A UTILIZAR. POISSON Y MÓDULO DE ELASTICIDAD.
REAL*8, ALLOCATABLE, DIMENSION(:):: BETA    !VELOCIDAD ONDA DE CORTE.
REAL*8, ALLOCATABLE, DIMENSION(:):: NU      !COEFICIENTE DE POISSON.
REAL*8, ALLOCATABLE, DIMENSION(:):: RHO     !DENSIDAD.
INTEGER NT      !NÚMERO DE TIEMPOS PARA EL PULSO DE RICKER.
REAL*8 FC       !FRECUENCIA CARACTERISTICA DEL PULSO DE RICKER
REAL*8 TINI     !CENTRO DEL PULSO DE RICKER.
REAL*8 TTOT     !TIEMPO TOTAL DE LA SEÑAL
REAL*8 FI       !ÁNGULO DE INCIDENCIA DE LA ONDA
INTEGER SUM
INTEGER NELINCO, NB, NELINCOM, NTH
INTEGER NBH     !ABSORBING ELEMENTS IN THE HALF-SPACE.
INTEGER NBS     !ABSORBING ELEMENTS IN THE STRATA.
INTEGER, ALLOCATABLE, DIMENSION(:):: IDPR
INTEGER, ALLOCATABLE, DIMENSION(:):: U
REAL*8 X1, X2, X3, X4, Y1, Y2, Y3, Y4
REAL*8 LONG, ALT


INTEGER, ALLOCATABLE, DIMENSION(:,:):: EXPMESH
INTEGER, ALLOCATABLE, DIMENSION(:):: HMEPN

INTEGER, ALLOCATABLE, DIMENSION(:,:):: INCO1, IMPRIME, IMPRIME1
INTEGER, ALLOCATABLE, DIMENSION(:,:):: INCO
INTEGER, ALLOCATABLE, DIMENSION(:,:):: NODESDRMMOD
INTEGER, ALLOCATABLE, DIMENSION(:)  :: NIMPDRM
INTEGER, ALLOCATABLE, DIMENSION(:)  :: NODEIMP
INTEGER, ALLOCATABLE, DIMENSION(:)  :: POSREP, VECIMP
INTEGER, ALLOCATABLE, DIMENSION(:)  :: V1, V2

CHARACTER(15):: NCOMPLE
CHARACTER(15):: FILENAME
INTEGER LST

REAL*8 elapsed_time
INTEGER tclock1, tclock2, clock_rate
call system_clock(tclock1)  ! start wall timer

NTH=4

OPEN(10,FILE='DatGenEst06.txt')
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*) NMAT
ALLOCATE(MATERIAL(NMAT,3))
READ(10,*)

DO I=1, NMAT
    READ(10,*) MATERIAL(I,1), MATERIAL(I,2), MATERIAL(I,3)
END DO 

READ(10,*)
READ(10,*)
READ(10,*) TONDA

READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*) FC, TTOT, TINI, NT, FI

CLOSE(10)


WRITE(*,*) 'Input the name of the *.msh file: '
READ(*,*) FILENAME
LST=LEN_TRIM(FILENAME)


OPEN(10,FILE='gmesh_files/'//FILENAME(1:LST)//'.msh')!'gmesh_files/Model_01.msh')
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,'(1I10)') NP        !NUMBER OF NODES.

ALLOCATE(X(NP), Y(NP), IDN(NP))

DO I=1, NP

    READ(10,*) IDN(I), X(I), Y(I), JUAN

END DO

READ(10,*)
READ(10,*)

READ(10,'(1I10)') ND        !DATA TO READ.

!ALLOCATE(TPB(ND))

NEL=0
NIMPRIME=0
NELINCO=0
NELINCOM=0
NBH=0
NBS=0
!TPB=1000

!ACÁ VOY A CONTAR LOS ELEMENTOS DE LA FRONTERA SOBRE LOS CUALES SE VA A PONER UN ELEMENTO
!ABSORBENTE. DE PASO SALE EL NÚMERO DE ELEMENTOS DEL PROBLEMA.

DO I=1, ND

    READ(10,*) J, L, K, M

    IF (L==8 .AND. M==1) THEN
        NBH=NBH+1
    END IF
    
    IF (L==8 .AND. M==2) THEN
        NBH=NBH+1
    END IF

    IF (L==8 .AND. M==3) THEN
        NBS=NBS+1
    END IF

    IF (L==8 .AND. M==4) THEN       !Elements in the free surface.
        NIMPRIME=NIMPRIME+1
    END IF
    
    IF (L==8 .AND. M==5) THEN       !Line elements of the incoming in the half-space.
        NELINCO=NELINCO+1
    END IF
    
    IF (L==8 .AND. M==6) THEN       !Line elements of the incoming in the strata.
        NELINCOM=NELINCOM+1
    END IF

    IF (L>8) THEN                   !Nine nodes elements.
        NEL=NEL+1
    END IF

END DO

CLOSE(10)

ALLOCATE(BOUNDARYH(NBH,3), BOUNDARYS(NBS,3))
BOUNDARYH=0
BOUNDARYS=0

ALLOCATE(IMPRIME(NIMPRIME,3))
IMPRIME=0

OPEN (10, FILE='Coord.txt')
!
DO I=1, NP
    WRITE(10, '(2F15.10)') X(I)/10.0D0, Y(I)/10.0D0
END DO
!
CLOSE(10)
!
X=0.0D0
Y=0.0D0
!
OPEN (10, FILE='Coord.txt')
!
DO I=1, NP
    READ(10, '(2F15.10)') X(I), Y(I)
END DO
!
X=X!/10.0D0
Y=Y!/10.0D0
!
CLOSE(10, STATUS='DELETE')
!
LONG=MAXVAL(X)
ALT=MAXVAL(Y)


!NEL:NUMERO DE ELEMENTOS.

OPEN(10,FILE='gmesh_files/'//FILENAME(1:LST)//'.msh')!'gmesh_files/Model_01.msh')
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
!
DO I=1, NP
!
    READ(10,*)
!
END DO
!
READ(10,*)
READ(10,*)
READ(10,*)

ALLOCATE(INCOH(NELINCO,3), INCOS(NELINCOM,3))
INCOH=0
INCOS=0

!ACÁ YA IDENTIFICO POR COMPLETO LOS ELEMENTOS SOBRE LOS CUALES SE VAN A PONER LAS
!FRONTERAS ABSORBENTES.

II=0
JJ=0
KK=0
LL=0
MM=0
NN=0

DO I=1, NBH+NBS+NIMPRIME+NELINCO+NELINCOM

    READ(10,*) J, K, L, M, N, O, P, Q

    IF (K==8 .AND. M==1) THEN
        II=II+1
        BOUNDARYH(II,1)=P
        BOUNDARYH(II,2)=Q
        BOUNDARYH(II,3)=O
!         NODEIZ(JJ) =O
!         NODEDER(JJ)=P
!         NODECEN(JJ)=Q
    END IF

    IF (K==8 .AND. M==2) THEN
        II=II+1
        BOUNDARYH(II,1)=P
        BOUNDARYH(II,2)=Q
        BOUNDARYH(II,3)=O
!         NODEIZ(JJ) =O
!         NODEDER(JJ)=P
!         NODECEN(JJ)=Q
    END IF

    IF (K==8 .AND. M==3) THEN
        JJ=JJ+1
        BOUNDARYS(JJ,1)=P
        BOUNDARYS(JJ,2)=Q
        BOUNDARYS(JJ,3)=O
    END IF

    IF(K==8 .AND. M==4) THEN
        KK=KK+1
        IMPRIME(KK,1)=O
        IMPRIME(KK,2)=P
        IMPRIME(KK,3)=Q
    END IF

    IF (K==8 .AND. M==5) THEN
        LL=LL+1
        INCOH(LL,1)=P!O
        INCOH(LL,2)=Q
        INCOH(LL,3)=O!Q
!         NODEIZINCO(MM) =O
!         NODEDERINCO(MM)=P
!         NODECENINCO(MM)=Q
    END IF

    IF (K==8 .AND. M==6) THEN
        MM=MM+1
        INCOS(MM,1)=P!O
        INCOS(MM,2)=Q
        INCOS(MM,3)=O!Q
!         INCO(KK,1) =O
!         INCO(KK,2) =P
!         INCO(KK,3) =Q
    END IF

END DO

ALLOCATE(IMPRIME1(NIMPRIME,3))

IMPRIME1=IMPRIME

!$ CALL OMP_SET_NUM_THREADS(NTH)
!$OMP PARALLEL DO PRIVATE(IFLAG, IPOS)

DO I=1, NIMPRIME
    IFLAG=1
    IPOS=0
    DO WHILE (IFLAG==1)
        CALL BELONGS(IMPRIME1(:,2),NIMPRIME,IMPRIME(I,1),IFLAG)
        IF(IFLAG==1) THEN
            CALL SEARCHPOS(IMPRIME1(:,2),NIMPRIME,IMPRIME(I,1),IPOS)
            IMPRIME1(IPOS,2)=0
        END IF
    END DO
END DO

!$OMP END PARALLEL DO

J=0
K=0

DO I=1, NIMPRIME
    IF (IMPRIME1(I,2).NE.0) THEN
        K=K+1
    END IF
END DO

ALLOCATE(VECIMP(NIMPRIME*2+K))
VECIMP=0
!
J=1
DO I=1, NIMPRIME
    VECIMP(J)=IMPRIME1(I,1)
    J=J+1

    VECIMP(J)=IMPRIME(I,3)
    J=J+1

    IF (IMPRIME1(I,2).NE.0) THEN
        VECIMP(J)=IMPRIME1(I,2)
        J=J+1
    END IF
END DO

NIMPRIME=NIMPRIME*2+K

!ACÁ VOY A ENCONTRAR LA MATRIZ INDICADORA DE ECUACIÓN Y LAS PROPIEDADES DE CADA
!ELEMENTO DEL DOMINIO

ALLOCATE(TP(NEL), MIE(9,NEL))

TP=0
MIE=0

ALLOCATE(INCO1(NEL,3))
ALLOCATE(INCO(NEL,3))
INCO=0

INCO1(:,1)=3
INCO1(:,2)=1

DO I=1, NEL
    READ(10,*) J,TP(I),K,INCO1(I,2),L,MIE(1,I), MIE(2,I), MIE(3,I), MIE(4,I), &
                                      MIE(5,I), MIE(6,I), MIE(7,I), MIE(8,I), &
                                      MIE(9,I)

    IF (INCO1(I,2).EQ.1000) THEN
        INCO1(I,2)=1
    END IF

    IF (INCO1(I,2).EQ.2000) THEN
        INCO1(I,2)=10
    END IF

    IF (INCO1(I,2)>2000) THEN
        INCO1(I,2)=INCO1(I,2)/1000+12
    END IF

END DO

!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

INCO=INCO1

DO I=1, NELINCO

    NX=INCOH(I,1)       !NODEIZINCO(I)
    NY=INCOH(I,3)       !NODEDERINCO(I)

    DO J=1, NEL

        IF (NX==MIE(1,J) .AND. NY==MIE(2,J) .AND. INCO1(J,2)==1) THEN
            INCO1(J,1)=5
            INCO1(J,2)=2
            INCO1(J,3)=3
            EXIT

        END IF

        IF (NX==MIE(2,J) .AND. NY==MIE(3,J) .AND. INCO1(J,2)==1) THEN
            INCO1(J,1)=5
            INCO1(J,2)=3
            INCO1(J,3)=4
            EXIT

        END IF

        IF (NX==MIE(3,J) .AND. NY==MIE(4,J) .AND. INCO1(J,2)==1) THEN
            INCO1(J,1)=5
            INCO1(J,2)=4
            INCO1(J,3)=1
            EXIT

        END IF

        IF (NX==MIE(4,J) .AND. NY==MIE(1,J) .AND. INCO1(J,2)==1) THEN
            INCO1(J,1)=5
            INCO1(J,2)=5
            INCO1(J,3)=2
            EXIT

        END IF

    END DO

END DO

DO I=1, NELINCOM

    NX=INCOS(I,1)       !NODEIZINCO(I)
    NY=INCOS(I,3)       !NODEDERINCO(I)

    DO J=1, NEL

        IF (NX==MIE(1,J) .AND. NY==MIE(2,J) .AND. INCO1(J,2)==10) THEN
            WRITE(*,*) MIE(9,J)
            INCO1(J,1)=5
            INCO1(J,2)=11
            INCO1(J,3)=3
            EXIT

        END IF

        IF (NX==MIE(2,J) .AND. NY==MIE(3,J) .AND. INCO1(J,2)==10) THEN
            INCO1(J,1)=5
            INCO1(J,2)=12
            INCO1(J,3)=4
            EXIT

        END IF

        IF (NX==MIE(3,J) .AND. NY==MIE(4,J) .AND. INCO1(J,2)==10) THEN
            INCO1(J,1)=5
            INCO1(J,2)=13
            INCO1(J,3)=1
            EXIT

        END IF

        IF (NX==MIE(4,J) .AND. NY==MIE(1,J) .AND. INCO1(J,2)==10) THEN
            INCO1(J,1)=5
            INCO1(J,2)=14
            INCO1(J,3)=2
            EXIT

        END IF

    END DO

END DO

ALLOCATE(NODESDRMMOD(NELINCO+NELINCOM,9))
NODESDRMMOD=0

JJ=0

DO I=1, NELINCO

    NX=INCOH(I,1)
    NY=INCOH(I,3)

    DO J=1, NEL

        IF (NX==MIE(1,J) .AND. NY==MIE(2,J) .AND. INCO(J,2)==1) THEN
            JJ=JJ+1
            NODESDRMMOD(I,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(2,J) .AND. NY==MIE(3,J) .AND. INCO(J,2)==1) THEN
            JJ=JJ+1
            NODESDRMMOD(I,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(3,J) .AND. NY==MIE(4,J) .AND. INCO(J,2)==1) THEN
            JJ=JJ+1
            NODESDRMMOD(I,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(4,J) .AND. NY==MIE(1,J) .AND. INCO(J,2)==1) THEN
            JJ=JJ+1
            NODESDRMMOD(I,:)=MIE(:,J)
            EXIT
        END IF

    END DO

END DO

DO I=1, NELINCOM

    NX=INCOS(I,1)
    NY=INCOS(I,3)

    DO J=1, NEL

        IF (NX==MIE(1,J) .AND. NY==MIE(2,J) .AND. INCO(J,2)==10) THEN
            JJ=JJ+1
            NODESDRMMOD(JJ,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(2,J) .AND. NY==MIE(3,J) .AND. INCO(J,2)==10) THEN
            JJ=JJ+1
            NODESDRMMOD(JJ,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(3,J) .AND. NY==MIE(4,J) .AND. INCO(J,2)==10) THEN
            JJ=JJ+1
            NODESDRMMOD(JJ,:)=MIE(:,J)
            EXIT
        END IF

        IF (NX==MIE(4,J) .AND. NY==MIE(1,J) .AND. INCO(J,2)==10) THEN
            JJ=JJ+1
            NODESDRMMOD(JJ,:)=MIE(:,J)
            EXIT
        END IF

    END DO

END DO

ALLOCATE(V1((NELINCO+NELINCOM)*8),V2((NELINCO+NELINCOM)*8))

V1=0
JJ=0
DO J=1, 8
    DO I=1, NELINCO+NELINCOM
        JJ=JJ+1
        V1(JJ)=NODESDRMMOD(I,J)
    END DO
END DO

V2=0

DO I=1, (NELINCO+NELINCOM)*8
    IF (V1(I).NE.0) THEN
        V2(I)=V1(I)
        V1(I)=0
        IFLAG=1
    
        DO WHILE (IFLAG==1)
            CALL BELONGS(V1,(NELINCO+NELINCOM)*8,V2(I),IFLAG)
            IF(IFLAG==1) THEN
                CALL SEARCHPOS(V1,(NELINCO+NELINCOM)*8,V2(I),IPOS)
                V1(IPOS)=0
            END IF
        END DO
        
    END IF
END DO

JJ=0
DO I=1, (NELINCO+NELINCOM)*8
    IF (V2(I).NE.0) THEN
        JJ=JJ+1
    END IF
END DO

DEALLOCATE(V1)

NPINCO=JJ+NELINCO+NELINCOM
ALLOCATE(V1(NPINCO))

V1=0

JJ=0
DO I=1, (NELINCO+NELINCOM)*8
    IF (V2(I).NE.0) THEN
        JJ=JJ+1
        V1(JJ)=V2(I)
    END IF
END DO

DO I=1, (NELINCO+NELINCOM)
    JJ=JJ+1
    V1(JJ)=NODESDRMMOD(I,9)
END DO

DEALLOCATE(V2, NODESDRMMOD)

!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

OPEN(10,FILE='../'//FILENAME(1:LST)//'.inp')!'../Model_01.inp')

WRITE(10, '(1A20)') 'Mountain'
WRITE(10, '(3I8, 1F8.3, 8I6)') NP, NEL+NBH+NBS, NMAT+12, TTOT, NT, 2, &
                               9, 18, 5, 1, 0, NIMPRIME!NPINCO!
                                !ACÁ ADICIONÉ UNA POSICIÓN MÁS, LA CUAL
                                !ME SIRVE PARA DECIRLE AL PROGRAMA QUE VA A
                                !IMPRIMIR HISTORIAS EN UN NÚMERO DETERMINADO
                                !DE PUNTOS NIMPRIME: NUMERO DE PUNTOS
                                !EN LOS CUALES SE VA A IMPRIMIR HISTORIAS.

DO I=1, NP

    WRITE(10, '(1I16, 3I6, 2F15.10)') I, 2, 0, 0, X(I), Y(I)

END DO


!FRONTERAS ABSORBENTES EN EL SEMIESPACIO

WRITE(10, '(3I4, 5F10.2, 1I4)') 1, 5, 0, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0

!EL SIGUIENTE BLOQUE CORRESPONDE A LOS ELEMENTOS QUE HACEN PARTE DEL INCOMING
!EN EL HALF-SPACE.

WRITE(10, '(3I4, 5F10.2, 1I4)') 2, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 3
WRITE(10, '(3I4, 5F10.2, 1I4)') 3, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 4
WRITE(10, '(3I4, 5F10.2, 1I4)') 4, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 1
WRITE(10, '(3I4, 5F10.2, 1I4)') 5, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 2
WRITE(10, '(3I4, 5F10.2, 1I4)') 6, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 5
WRITE(10, '(3I4, 5F10.2, 1I4)') 7, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 6
WRITE(10, '(3I4, 5F10.2, 1I4)') 8, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 7
WRITE(10, '(3I4, 5F10.2, 1I4)') 9, 5, 1, MATERIAL(1,1), MATERIAL(1,2), &
                                MATERIAL(1,3), 0.0D0, 0.0D0, 8

!FRONTERAS ABSORBENTES EN EL ESTRATO

WRITE(10, '(3I4, 5F10.2, 1I4)') 10, 5, 0, MATERIAL(2,1), MATERIAL(2,2), &
                                MATERIAL(2,3), 0.0D0, 0.0D0

!EL SIGUIENTE BLOQUE CORRESPONDE A LOS ELEMENTOS QUE HACEN PARTE DEL INCOMING
!EN EL ESTRATO.

WRITE(10, '(3I4, 5F10.2, 1I4)') 11, 5, 1, MATERIAL(2,1), MATERIAL(2,2), &
                                MATERIAL(2,3), 0.0D0, 0.0D0, 3
WRITE(10, '(3I4, 5F10.2, 1I4)') 12, 5, 1, MATERIAL(2,1), MATERIAL(2,2), &
                                MATERIAL(2,3), 0.0D0, 0.0D0, 4
WRITE(10, '(3I4, 5F10.2, 1I4)') 13, 5, 1, MATERIAL(2,1), MATERIAL(2,2), &
                                MATERIAL(2,3), 0.0D0, 0.0D0, 1
WRITE(10, '(3I4, 5F10.2, 1I4)') 14, 5, 1, MATERIAL(2,1), MATERIAL(2,2), &
                                MATERIAL(2,3), 0.0D0, 0.0D0, 2

DO I=1, NMAT-2
    WRITE(10, '(3I4, 5F10.2, 1I4)') 14+I, 5, 0, MATERIAL(2+I,1), &
                                    MATERIAL(2+I,2),MATERIAL(2+I,3), &
                                    0.0D0, 0.0D0
END DO

!1: TIPO DE ONDA, 1: P-WAVE, 2: S-WAVE, 3: DISPLACEMENT FIELD
!2: TIEMPO TOTAL DE LA SEÑAL
!3: TIEMPO CENTRAL DEL PUSLO
!4: FRECUENCIA CARACTERISTICA DEL PULSO
!5: AMPLITUD DE LA SEÑAL
!6: ÁNGULO DE INCIDENCIA DE LA ONDA

WRITE(10, '(1I6, 5F8.4)') TONDA, TTOT, TINI, FC, 1.0D0, FI


DO I=1, NEL
    IF (MIE(9,I)==155573 .OR. MIE(9,I)==157979) THEN
        WRITE(10,'(1I7, 4I4, 9I8)') I, INCO1(I,1), 18, 7, 9, MIE(1,I), MIE(2,I), &
                           MIE(3,I), MIE(4,I), MIE(5,I), MIE(6,I), &
                           MIE(7,I), MIE(8,I), MIE(9,I)
!     ELSE
!         IF (MIE(9,I)==125804) THEN
!             WRITE(10,'(1I7, 4I4, 9I8)') I, INCO1(I,1), 18, 6, 9, MIE(1,I), &
!                    MIE(2,I), MIE(3,I), MIE(4,I), MIE(5,I), MIE(6,I), &
!                    MIE(7,I), MIE(8,I), MIE(9,I)
        ELSE
            WRITE(10,'(1I7, 4I4, 9I8)') I, INCO1(I,1), 18, INCO1(I,2), 9, &
                   MIE(1,I), MIE(2,I), &
                   MIE(3,I), MIE(4,I), MIE(5,I), MIE(6,I), &
                   MIE(7,I), MIE(8,I), MIE(9,I)
!         END IF
    END IF
END DO

DO I=1, NBH
    WRITE(10,'(1I7, 4I4, 3I8)') I+NEL, 7, 6, 1, 3, &
                                BOUNDARYH(I,1), BOUNDARYH(I,2), BOUNDARYH(I,3)
!                                 NODEDER(I), NODECEN(I), NODEIZ(I)
END DO

DO I=1, NBS
    WRITE(10,'(1I7, 4I4, 3I8)') I+NEL+NBH, 7, 6, 10, 3, &
                                BOUNDARYS(I,1), BOUNDARYS(I,2), BOUNDARYS(I,3)
END DO

DO I=1, NIMPRIME
    WRITE(10,'(1I16)') VECIMP(I)
END DO

! DO J=1, NPINCO
!     WRITE(10, '(1I7)') V1(J)
! END DO
 
CLOSE(10)

OPEN (10, FILE='Z.txt')

! K=0
! DO I=1, NP
!     IF (X(I)<2.66D0) THEN
!         K=K+1
!     END IF
!     
!     IF (X(I)>3.34D0) THEN
!         K=K+1
!     END IF
!     
!     IF (Y(I)>0.34D0) THEN
!         IF (X(I)>=2.66D0 .AND. X(I)<=3.34D0) THEN
!             K=K+1
!         END IF
!     END IF
! END DO
!     
! WRITE(10, '(1I7)') K
! 
! DEALLOCATE(V1)
! ALLOCATE(V1(K))
! V1=0
! 
! K=0
! DO I=1, NP
!     IF (X(I)<2.66D0) THEN
!         K=K+1
!         V1(K)=I
!     END IF
!     
!     IF (X(I)>3.34D0) THEN
!         K=K+1
!         V1(K)=I
!     END IF
!     
!     IF (Y(I)>0.34D0) THEN
!         IF (X(I)>=2.66D0 .AND. X(I)<=3.34D0) THEN
!             K=K+1
!             V1(K)=I
!         END IF
!     END IF
! END DO
! 
! DO I=1, K
!     WRITE(10, '(1I7, 1F18.14)') V1(I), Y(I)
! END DO

WRITE(10, '(1I7)') NPINCO

DO I=1, NPINCO
    WRITE(10, '(1I7, 1F18.14)') V1(I), Y(V1(I))
END DO

CLOSE(10)
! 
! 
! OPEN (10, FILE='MallaInco.txt')
! 
! WRITE(10,'(1I8)') NP
!     
!     DO I=1, NP
!         WRITE(10,'(2F15.10)') X(I), Y(I)
!     END DO
! 
! WRITE(10,'(1I8)') NEL
! 
!     DO I=1, NEL
!         WRITE(10,'(9I8)') MIE(1,I), MIE(2,I), &
!                    MIE(3,I), MIE(4,I), MIE(5,I), MIE(6,I), &
!                    MIE(7,I), MIE(8,I), MIE(9,I)
!     END DO
! 
! CLOSE(10)



call system_clock(tclock2, clock_rate)
elapsed_time = float(tclock2 - tclock1) / float(clock_rate)
print 11, elapsed_time
11 format("Elapsed time = ",f12.4, " seconds")

END PROGRAM MALLAS






SUBROUTINE BELONGS(LIST,NDAT,IVAL,IFLAG)

INTEGER NDAT, IVAL, IFLAG, I
DIMENSION LIST(NDAT)

IFLAG=0
DO I=1,NDAT
    IF(IVAL.EQ.LIST(I)) THEN
        IFLAG=1
        EXIT
    END IF
END DO

RETURN

END


SUBROUTINE SEARCHPOS(LIST,NDAT,NVAL,IPOS)

INTEGER NDAT, NVAL, IPOS, I
DIMENSION LIST(NDAT)

DO I=1,NDAT
    IF(LIST(I).EQ.NVAL) THEN
        IPOS=I
        EXIT
    END IF
END DO

RETURN

END

















