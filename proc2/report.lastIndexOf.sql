
CREATE FUNCTION [report].[lastIndexOf] (@target [char],@p_str [VARCHAR](8000)) RETURNS int
AS
begin
declare @Str VARCHAR(8000)='';

Declare @v_index int = -1;
Declare @v_index_tmp int= -1;

SET @Str = @p_str;

SET @Str = REVERSE(@Str)

set @v_index_tmp=CHARINDEX(@target,@Str,0);
if(@v_index_tmp=0)
begin
 return 0;
end
   return len(@Str)-@v_index_tmp+1;
end
