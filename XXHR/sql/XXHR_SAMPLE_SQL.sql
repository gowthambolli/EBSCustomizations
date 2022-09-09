BEGIN
DBMS_STATS.GATHER_TABLE_STATS ('TARGET','DUMMY');
END;
/;
-- Testing for 6.0 Tomcat Oracle.
