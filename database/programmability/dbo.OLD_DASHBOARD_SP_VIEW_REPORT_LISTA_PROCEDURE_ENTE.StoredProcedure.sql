USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_ENTE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD_DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE_ENTE]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin

	declare @idAzi as int;
	declare @myfilter varchar(100)

	set @myfilter = ''

	--richiamo la stored dell'elenco procedure aggiungento il filtro per ente
	--aggiungendo il filtro per ente collegato

	--recuper l'aziuenda dall'idpfu 
	select @idAzi = pfuIdAzi from ProfiliUtente with(nolock) where IdPfu = @IdPfu

	set @myfilter = ' AZI_Ente =' +  CAST(@idAzi as varchar(100))

	if @Filter <> ''
		set @Filter = @Filter +  ' and ' + @myfilter
	else
		set @Filter = @myfilter

	exec DASHBOARD_SP_VIEW_REPORT_LISTA_PROCEDURE
													@IdPfu,
													@AttrName,
													@AttrValue,
													@AttrOp,
													@Filter,
													@Sort,
													@Top,
													@Cnt output


end





GO
