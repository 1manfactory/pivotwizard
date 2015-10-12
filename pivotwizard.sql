CREATE DEFINER = 'root'@'%'
PROCEDURE DB.pivotwizard(IN `P_Row_Field` VARCHAR(255), IN `P_Column_Field` VARCHAR(255), IN `P_Value` VARCHAR(255), IN `P_From` VARCHAR(4000), IN `P_Where` VARCHAR(4000), IN `P_Rowsumname` VARCHAR(255), IN `P_Orderby` VARCHAR(255), IN `P_Savetable` VARCHAR(255)
  )
ThisSP:BEGIN
 DECLARE done INT DEFAULT 0;
 DECLARE colsum float DEFAULT 0;
 DECLARE M_Count_Columns int DEFAULT 0;
 DECLARE M_Column_Field varchar(60);
 DECLARE M_Columns VARCHAR(8000) DEFAULT '';
 DECLARE M_orderbyfield VARCHAR(60);
 DECLARE M_sqltext, M_sqltext2, M_rowsumstring, M_wherestring VARCHAR(8000);
 DECLARE M_stmt VARCHAR(8000);
 DECLARE cur1 CURSOR FOR SELECT CAST(Column_Field AS CHAR) FROM Temp;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


    IF (P_Where<>'') then
      SET M_wherestring=P_Where;
    ELSE
      SET M_wherestring='1=1';
    END IF;

 DROP TABLE IF EXISTS Temp;
 SET @M_sqltext = CONCAT('CREATE TEMPORARY TABLE Temp ',
                   ' SELECT DISTINCT ',P_Column_Field, 
				' AS Column_Field',
                   ' FROM ',P_From,
                   ' WHERE ', M_wherestring,
                   ' ORDER BY ', P_Column_Field);

 #SELECT @M_sqltext;LEAVE ThisSP;
 PREPARE M_stmt FROM @M_sqltext;
 EXECUTE M_stmt;

 SELECT COUNT(*) INTO M_Count_Columns 

 FROM Temp 

 WHERE Column_Field IS NOT NULL;

 IF (M_Count_Columns > 0) THEN
    OPEN cur1;
    REPEAT
      FETCH cur1 INTO M_Column_Field;
      IF (NOT done) and (M_Column_Field IS NOT NULL) THEN
         SET M_Columns = CONCAT(M_Columns,

 	' CAST(REPLACE( GROUP_CONCAT( CASE WHEN ',P_Column_Field,'=''',M_Column_Field,'''',
         		' THEN ',P_Value,
                  ' ELSE NULL END, ''''), '','', '''') AS DECIMAL(20,10)) AS ''', M_Column_Field ,''',');
          
      END IF;
    UNTIL done END REPEAT;
#SELECT colsum;LEAVE ThisSP;
    SET M_Columns = Left(M_Columns,Length(M_Columns)-1);
#SELECT M_Columns;LEAVE ThisSP;
    
    IF (P_Rowsumname<>'') THEN
      SET M_rowsumstring=CONCAT(', (SELECT SUM(',P_Value,') FROM ',P_From,' tab2 WHERE ',M_wherestring,' AND tab1.',P_Row_Field,'=tab2.',P_Row_Field,') AS ', P_Rowsumname);
    ELSE
      SET M_rowsumstring='';
    END IF;
#SELECT M_rowsumstring;LEAVE ThisSP;


    IF (P_Orderby<>'') THEN
      SET M_orderbyfield=P_Orderby;
    ELSE
      SET M_orderbyfield=P_Row_Field;
    END IF;
#SELECT M_orderbyfield;LEAVE ThisSP;
    SET @M_sqltext = CONCAT('SELECT ',P_Row_Field,', ',M_Columns, M_rowsumstring,
                            ' FROM ', P_From,' AS tab1',
                            ' WHERE ', M_wherestring,
                            ' GROUP BY ', P_Row_Field,
                            ' ORDER BY ', M_orderbyfield);

#SELECT @M_sqltext;LEAVE ThisSP;
 
 # save or print on screen?
IF (P_Savetable<>'') THEN
  SET @M_sqltext2=CONCAT('DROP TABLE IF EXISTS ', P_Savetable);
  #SELECT @M_sqltext2;LEAVE ThisSP;
  PREPARE M_stmt FROM @M_sqltext2;
  EXECUTE M_stmt;
  SET @M_sqltext=CONCAT('CREATE TABLE ',P_Savetable,' ', @M_sqltext);
  #SELECT @M_sqltext;LEAVE ThisSP;
ELSE
  # do nothing, but we have to do somthing otherwise we can't compile
  SET @M_sqltext=@M_sqltext;
END IF;
#SELECT @M_sqltext;LEAVE ThisSP;
 
 
 PREPARE M_stmt FROM @M_sqltext;

    EXECUTE M_stmt;
  END IF;
  
END