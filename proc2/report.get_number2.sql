CREATE FUNCTION [report].[get_number2] (@S [VARCHAR](100)) RETURNS VARCHAR(100)
AS
BEGIN
WHILE PATINDEX('%[^0-9]%',@S) > 0
BEGIN
set @s=stuff(@s,patindex('%[^0-9]%',@s),1,'')
END
RETURN @S
END
