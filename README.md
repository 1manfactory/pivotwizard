# pivotwizard
Creating a pivot table with a MySQL procedure

1. create procedure "pivotwizard"

2. run it: CALL pivotwizard(P_From, P_Row_Field, P_Column_Field, P_Value, P_Where, P_Rowsumname, P_Orderby, P_Collimit, P_Savetable);

- P_From: Source table

- P_Row_Field:      Field of source table which will become the row in result

- P_Column_Field:   Field of source table which will become the column in result

- P_Value:          Field of source table which will become the value cells in result

- P_Where:          Where statement to be applied to source table to narrow results, e.g. source.column>1000 (can be null)

- P_Rowsumname:     Gives the resulting row a new name (can be null)

- P_Orderby:        Order by applied to result (can be null)

- P_Collimit:       Limit the result rows (can be null)

- P_Savetable:			Save the result as a new table, otherwise (if left null) print result on screen

