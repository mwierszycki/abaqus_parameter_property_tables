      SUBROUTINE UTEMP(TEMP,NSECPT,KSTEP,KINC,TIME,NODE,COORDS)
      include 'aba_param.inc'
      include 'aba_tcs_param.inc'

      real(kind=8), dimension(nsecpt) :: temp
      real(kind=8), dimension(2) :: time
      real(kind=8), dimension(3) :: coords 

      integer :: i
      common /counters/ i

      character (len=80) :: TabColName
      character (len=80) :: parameterTableLabel

      integer :: numParams
      integer :: numRows
      integer :: JERROR

      integer, dimension (:), allocatable :: iParamsDataType
      integer, dimension (:), allocatable :: iParams
      real(kind=8), dimension (:), allocatable :: rParams
      character (len=80), dimension (:), allocatable :: cParams

      integer :: jRow

      character (len=80) :: propertyTableLabel
      character (len=80) :: cPropTable(n_tcsC_PRT_size)

      integer, dimension (n_tcsI_PRT_size) :: jPropTable
      real(kind=8), dimension (i_tcsR_PRT_rTol) :: rPropTable

      integer :: numIndVars
      integer :: numFieldVars
      integer :: numProps
      integer :: maxVars

      real(kind=8), dimension (:), allocatable :: field
      real(kind=8), dimension (:), allocatable :: rIndepVars
      real(kind=8), dimension (:), allocatable :: rProps
      real(kind=8), dimension (:), allocatable :: dPropDVar

C     Table collection activation
      TabColName = 'TABLE_1'
      call setTableCollection(TabColName, JERROR)
     
C     Query the number of parameters in the parameter table 
      parameterTableLabel="LABEL_1"
      call queryParameterTable(parameterTableLabel, numParams, numRows,
     1  JERROR)
      
      allocate(iParamsDataType(numParams)) 
      allocate(iParams(numParams*numRows)) 
      allocate(rParams(numParams*numRows)) 
      allocate(cParams(numParams*numRows)) 
     
C     Access parameters from the parameter table
      call getParameterTable(parameterTableLabel, numParams,
     1 iParamsDataType, iParams, rParams, cParams, jError)

C     Table collection activation
      TabColName = 'TABLE_2'
      call setTableCollection(TabColName, JERROR)

C     Query properties of the property table
      propertyTableLabel = 'LABEL_3'
      call queryPropertyTable(propertyTableLabel, jPropTable,
     1 rPropTable, cPropTable, jError)
      
C     Number of independent variables in the property table 
      numIndVars = jPropTable(i_tcsI_PRT_numIndVars)
C     Number of field variables in the property table
      numFieldVars = jPropTable(i_tcsI_PRT_numFieldVars)
C     Number of properties in the property table
      numProps = jPropTable(i_tcsI_PRT_numProps)
C     the sum of independent variables, temperature, and field variables
C     in the table.
      maxVars = numIndVars + numFieldVars + 
     1 jPropTable(i_tcsI_PRT_tempDep)
        
C     If properties are not field variable dependend allocate mem
C     for non-zero size of field var and set field(1) to zero 
      if (jPropTable(i_tcsI_PRT_numFieldVars) == 0) then
        allocate(field(1))
        field(1) = 0.0
      else
C     If properties are field variable dependend allocate mem for them
        allocate(field(jPropTable(i_tcsI_PRT_numFieldVars)))
      end if
C     If properties are not temperature dependend set temp to zero
      if  (jPropTable(i_tcsI_PRT_tempDep) == 0) then
        temp = 0.0
      end if
C     If properties are not independent variable dependend allocate mem
C     for non-zero size of rIndepVars var and set rIndepVars(1) to zero 
      if (numIndVars == 0) then
        allocate(rIndepVars(1))
        rIndepVars(1) = 0.0
      else
C     If properties are independent variable dependend allocate mem for them
        allocate(rIndepVars(numIndVars))
      end if
      allocate(rProps(numProps))
      allocate(dPropDVar(numProps*maxVars))

C     Set values of independent variables and temperature for which
C     property value is interolated
      rIndepVars(1) = 15.0
      temp = 150.0
      numDervs=0

C     Interpolate properties defined in the property table
      call getPropertyTable(propertyTableLabel, rIndepVars, temp, field,
     1 numProps, rProps, dPropDVar, numDervs, jError)

C     It's UTEMP - the temperature should be returned
      TEMP(1) = 100.0

C     Print data from parameter and property tables to stdout
C     To reduce no of outputs for 1st node only
      if (node.eq.1) then
        print *, '---------------------------------------------'
        print *, 'queryParameterTable'
        print *, ' numParams=',numParams
        print *, ' numRows=',numRows
        print *, '---------------------------------------------'
        print *, 'getParameterTable'
        print *, ' iParamsDataType=',iParamsDataType
        print *, ' iParams=',iParams(1)
        print *, ' rParams=',rParams(2)
        print *, ' cParams=',cParams(3)
        print *, ' iParams=',iParams(1+numParams*(numRows-1))
        print *, ' rParams=',rParams(2+numParams*(numRows-1))
        print *, ' cParams=',cParams(3+numParams*(numRows-1))
        print *, '---------------------------------------------'
        print *, 'queryPropertyTable'
        print *, ' jPropTable=',jPropTable
        print *, ' rPropTable=',rPropTable
C        print *, ' cPropTable=',cPropTable
        print *, '---------------------------------------------'
        print *, 'getPropertyTable'
        print *, ' rProps=',rProps
        print *, '---------------------------------------------'
        print *, ''
      end if

      deallocate(iParamsDataType) 
      deallocate(iParams) 
      deallocate(rParams) 
      deallocate(cParams) 

      deallocate(field)
      deallocate(rIndepVars)
      deallocate(rProps)
      deallocate(dPropDVar)

      return
      END
