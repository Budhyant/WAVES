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
INTEGER II, JJ
INTEGER NP, ND, NEL, NMAT, PROBLEM
INTEGER NGF, NGLXY, NGLX, NGLY
INTEGER NX, NY, NLF, NTC
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
INTEGER, ALLOCATABLE, DIMENSION(:):: TL     !NÚMERO DE LINEAS A LAS CUALES SE LES APLICA UN GRUPO FISICO.
INTEGER, ALLOCATABLE, DIMENSION(:):: TLRX   !NÚMERO DE LINEAS CON RESTRICCIONES EN X.
INTEGER, ALLOCATABLE, DIMENSION(:):: TLRY   !NÚMERO DE LINEAS CON RESTRICCIONES EN Y.
INTEGER, ALLOCATABLE, DIMENSION(:):: TLF    !NÚMERO DE LINEAS CARGADAS.
INTEGER, ALLOCATABLE, DIMENSION(:):: BOUNDARY, NODEIZ, NODEDER, NODECEN
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
REAL*8 C        !CENTRO DEL PULSO DE RICKER.
REAL*8 TF       !TIEMPO TOTAL DE LA SEÑAL
INTEGER SUM
INTEGER, ALLOCATABLE, DIMENSION(:):: IDPR
INTEGER, ALLOCATABLE, DIMENSION(:):: U
REAL*8 X1, X2, X3, X4, Y1, Y2, Y3, Y4
REAL*8 LONG, ALT
!
!
INTEGER, ALLOCATABLE, DIMENSION(:,:):: EXPMESH
INTEGER, ALLOCATABLE, DIMENSION(:):: HMEPN

INTEGER, ALLOCATABLE, DIMENSION(:,:):: INCO1, INCO
INTEGER, ALLOCATABLE, DIMENSION(:):: POSREP

CHARACTER(15):: NCOMPLE
INTEGER NTHREADS
INTEGER POINTS_PER_THREAD
INTEGER THREAD_NUM
INTEGER ISTART, IEND
INTEGER NPL

INTEGER PARAL                                   !VARIABLE DONDE LE DIGO EL NÚMERO DE HILOS
INTEGER REP


REAL*8 elapsed_time
INTEGER tclock1, tclock2, clock_rate
call system_clock(tclock1)  ! start wall timer
!
!
OPEN(10,FILE='Entrada/untitled3.msh')
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,*)
READ(10,'(1I10)') NP        !NUMBER OF NODES.
!
ALLOCATE(X(NP), Y(NP), IDN(NP))
!
DO I=1, NP
!
    READ(10,*) IDN(I), X(I), Y(I), JUAN
!
END DO
!
READ(10,*)
READ(10,*)
!
READ(10,'(1I10)') ND        !DATA TO READ.
!
!
!ALLOCATE(TPB(ND))
!
NEL=0
!TPB=1000
!
!ACÁ VOY A CONTAR LOS ELEMENTOS DE LA FRONTERA SOBRE LOS CUALES SE VA A PONER UN ELEMENTO
!ABSORBENTE. DE PASO SALE EL NÚMERO DE ELEMENTOS DEL PROBLEMA.
!
DO I=1, ND
!
    READ(10,*) J, L
!
    IF (L>8) THEN
!
        NEL=NEL+1
!
    END IF
!
END DO
!
CLOSE(10)
!
!
OPEN (10, FILE='Coord.txt')
!
DO I=1, NP
    WRITE(10, '(2F10.6)') X(I), Y(I)
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
    READ(10, '(2F10.6)') X(I), Y(I)
END DO
!
CLOSE(10, STATUS='DELETE')
!
LONG=MAXVAL(X)
ALT=MAXVAL(Y)
!
NPL=0
DO I=1, NP
    IF (Y(I)==0.0D0) THEN
        NPL=NPL+1
    END IF
END DO
!
!
!NEL:NUMERO DE ELEMENTOS.
!
OPEN(10,FILE='Entrada/untitled3.msh')
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
!
ALLOCATE(BOUNDARY(ND-NEL), NODEIZ(ND-NEL), NODEDER(ND-NEL), &
         NODECEN(ND-NEL), TL(ND-NEL))
!
NGLX=0
NGLY=0
!
!ACÁ YA IDENTIFICO POR COMPLETO LOS ELEMENTOS SOBRE LOS CUALES SE VAN A PONER LAS
!FRONTERAS ABSORBENTES.
!
DO I=1, ND-NEL
!
    READ(10,*) J, K, L, BOUNDARY(I), TL(I), NODEIZ(I), NODEDER(I), NODECEN(I)   
                            !LOS VECTORES NODEIZ Y NODEDER ME DICEN LOS NODOS CON 
                            !FRONTERAS ABSORBENTES.
!
    IF (BOUNDARY(I)==1) THEN
!
        NGLX=NGLX+1     !LÍNEAS HORIZONTALES
!
    END IF
!
    IF (BOUNDARY(I)==2) THEN
!
        NGLY=NGLY+1   !LÍNEAS VERTICALES
!
    END IF
!
END DO
!
!
!NGLX:ELEMENTOS CON NORMAL N= 0i +/- 1j
!NGLY:ELEMENTOS CON NORMAL N= +/- 1i + 0j
!
!
ALLOCATE(NODEX(NGLX,3))
ALLOCATE(NODEY(NGLY,2))
!
NODEX=0
NODEY=0
!
O=0
P=0
Q=0
!
DO I=1, ND-NEL
!
!
    IF (BOUNDARY(I)==1) THEN
!
        O=O+1
!
        NODEX(O,1)=NODEIZ(I)
        NODEX(O,2)=NODEDER(I)
        NODEX(O,3)=NODECEN(I)
!
    END IF
!
    IF (BOUNDARY(I)==2) THEN
!
        P=P+1
!
        NODEY(P,1)=NODEIZ(I)
        NODEY(P,2)=NODEDER(I)
!
    END IF
!
END DO
!
DEALLOCATE(BOUNDARY)
!
!
ALLOCATE(IDPR(NP))
!
IDPR=0
SUM=0
!
DO I=1, NP
!
    K=0
!
    DO J=1, NGLX
    !
        IF (IDN(I)==NODEX(J,1)) THEN
            K=K+1
        END IF
        !
        IF (IDN(I)==NODEX(J,2)) THEN
            K=K+1
        END IF
    !
    END DO
    !
    IF (K>0) THEN
        IDPR(I)=-1
        SUM=SUM+1
    END IF
!
END DO     
!
!
!
!ACÁ VOY A ENCONTRAR LA MATRIZ INDICADORA DE ECUACIÓN Y LAS PROPIEDADES DE CADA
!ELEMENTO DEL DOMINIO
!
ALLOCATE(TP(NEL), MIE(8,NEL), PROP(NEL))
!
TP=0
MIE=0
PROP=0
!
DO I=1, NEL
!
    READ(10,*) J, TP(I), K, PROP(I), L, MIE(1,I), MIE(2,I), MIE(3,I), MIE(4,I), &
                                        MIE(5,I), MIE(6,I), MIE(7,I), MIE(8,I)
    PROP(I)=PROP(I)/1000
!
END DO
!
!
NMAT=1
!
!
!NMAT: NÚMERO DE MATERIALES A UTILIZAR.
!
!
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!
!
TP=TP+1     !AJUSTA EL TIPO DE ELEMENTO AL QUE NECESITA EL PROGRAMA DE FEM DE NOSOTROS
            !PUES PARA EL TRIANGLE:3 NODES Y CUADRILATERAL: 4 NODES
!
!
OPEN(10,FILE='../barra.inp')
!
WRITE(10, '(1A20)') 'simple square mesh'
WRITE(10, '(3I8, 1F10.2, 7I5)') NP, NEL+NGLX, 1, 1.50D0, 3001, 2, 8, 16, 5, 0, NPL
!
DO I=1, NP
!
    IF (X(I)==0.0D0 .OR. X(I)==LONG) THEN
            WRITE(10, '(4I6, 2F10.4)') I, 2, -1, 0, X(I), Y(I)
        ELSE
            WRITE(10, '(4I6, 2F10.4)') I, 2, 0, 0, X(I), Y(I)
    END IF
!
END DO
!
!
WRITE(10, '(3I4, 5F10.2)') 1, 5, 0, 2.0D0, 1.0D0, 1.0D0, 0.0D0, 0.0D0
WRITE(10, '(1I1, 1F7.2, 1F11.2, 3F17.2)') 2, 1.50D0, 0.10D0, 16.0D0, 0.10D0, 0.0D0
!
!
DO I=1, NEL
!
    WRITE(10,'(13I8)') I, 1, 16, 1, 8, MIE(1,I), MIE(2,I), MIE(3,I), &
                       MIE(4,I), MIE(5,I), MIE(6,I), MIE(7,I), MIE(8,I)
!
END DO
!
DO I=1, NGLX
!
    WRITE(10,'(13I8)') I+NEL, 7, 6, 1, 3, NODEX(I,2), NODEX(I,3), NODEX(I,1)
!
END DO
!
DO I=1, NP
    IF (Y(I)==0.0D0) THEN
        WRITE(10, '(2I6)') I, 2
    END IF
END DO
!
!
call system_clock(tclock2, clock_rate)
elapsed_time = float(tclock2 - tclock1) / float(clock_rate)
print 11, elapsed_time
11 format("Elapsed time = ",f12.4, " seconds")

END PROGRAM MALLAS
























