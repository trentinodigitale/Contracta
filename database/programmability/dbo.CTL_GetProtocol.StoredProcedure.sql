USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CTL_GetProtocol]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[CTL_GetProtocol] ( @idPfu int  , @Prot as varchar(50) output )
--RETURNS VARCHAR(200)
AS
BEGIN 
 	set nocount on

	declare @max varchar(20)
	declare @last int
	declare @id int
	declare @CAR_Plant varchar(20)
	declare @BaseProt varchar(20)
	declare @pfuidazi int
	declare @SQL varchar(2000)

	set @max = ''


	select @pfuidazi  =  pfuidazi , @BaseProt  = pfuprefissoprot  from profiliutente where idpfu = @idPfu


	set @id = -1
	select @id = contatore
			from TabPrefissoProtocollo 
			where idAzi = @pfuidazi and 
					prefissoprot = @BaseProt

	if @id = -1 
	begin
		insert into TabPrefissoProtocollo  ( idAzi , prefissoprot , contatore ) 
							values( @pfuidazi    ,@BaseProt , 1 )
		set @max = left( @BaseProt + '   ' ,3 ) + '000001'

	end
	else
	begin		

		update TabPrefissoProtocollo set contatore = contatore  + 1
			where idAzi = @pfuidazi and 
					prefissoprot = @BaseProt
		
		select @id = contatore
				from TabPrefissoProtocollo 
				where idAzi = @pfuidazi and 
						prefissoprot = @BaseProt

		set @max =  left( @BaseProt + '   ' ,3 )  + right( '000000' + cast( @id as varchar(6) ) , 6 )

	end

	set nocount off
	
	--print @max
	set @Prot = @max

END


GO
