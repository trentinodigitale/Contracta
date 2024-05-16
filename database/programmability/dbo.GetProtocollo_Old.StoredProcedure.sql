USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetProtocollo_Old]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[GetProtocollo_Old]( @AttribName varchar(100), @Protocollo varchar(100) output )
as
begin

	declare @i int
	declare @fine varchar(50)
	declare @resto varchar(50)
	declare @pref varchar(50)
	declare @num int
	declare @cvlastvalue varchar(100)
	declare @idcv int 

	set @Protocollo = null
	set @cvlastvalue = null

	select @idcv = idcv,@cvlastvalue = cvlastvalue from CountersValue with (nolock)
			inner join Counters with (nolock) on idcnt = cvIdCnt 
			inner join DizionarioAttributi  with (nolock) on iddzt=cntIdDzt
				where dztNome = @AttribName

	if @cvlastvalue is not null
	begin

		set @i = CHARINDEX ( '-' , @cvlastvalue)

		if @i > 0
		begin
			set @fine = substring(@cvlastvalue, @i, len(@cvlastvalue) )
			set @resto = substring(@cvlastvalue, 1 , @i - 1 )
		end 
		else
		begin
			set @fine = ''
			set @resto = @cvlastvalue
		end 

		--select @fine
		--select @resto

		set @pref = substring(@resto, 1, 2)
		set @num = cast(substring(@resto, 3, len(@resto)) as int) + 1

		--select @pref
		--select @num

		set @Protocollo = @pref + right( '000000' + cast(@num as varchar(6)) , 6 ) + @fine

		--select @cvlastvalue
		--select @Protocollo
		update CountersValue set cvLastValue = @Protocollo where idcv = @idcv

	end

end
GO
