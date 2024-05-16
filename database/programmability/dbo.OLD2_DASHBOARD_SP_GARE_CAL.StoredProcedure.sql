USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_GARE_CAL]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OLD2_DASHBOARD_SP_GARE_CAL] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
AS
BEGIN


	declare @Param varchar(max)
	declare @SuffLNG varchar(50)
	declare @Profilo varchar(150)
	declare @aziEnte varchar(4000)

	
	SET NOCOUNT ON

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(max)
	

	-- criteri di ricerca
	set @aziEnte = replace( dbo.GetParam( 'AZI_Ente' , @Param ,1) ,'''','''''')

	IF @aziEnte <> '' and CHARINDEX( '###', @aziEnte) > 0 
	BEGIN
		set @SQLWhere = ' AZI_Ente in ( select items from dbo.split(''' + @aziEnte + ''',''###'') ) '
	END
	ELSE
	BEGIN
		set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_GARE_CAL' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )
	END

	declare @CrLf varchar (10)
	set @CrLf = '
'


	-- criteri di ricerca
	set @Profilo				= replace( dbo.GetParam( 'Profilo' , @Param ,1) ,'''','''''')
-------------------------------------------------------------------
-- recupero la lingua dell'utente 
-------------------------------------------------------------------
	set @SuffLNG = 'I'

	select @SuffLNG = lngSuffisso from ProfiliUtente inner join Lingue on pfuIdLng = IdLng where idpfu = @IdPfu

-------------------------------------------------------------------
-- Verifico la presenza di eventuali restrizioni sull'utente
-------------------------------------------------------------------



-------------------------------------------------------------------
-- creo la query di estrazione
-------------------------------------------------------------------


	set @SQLCmd =  'select 

		idpfu, 
		id,
		Descrizione , 
		DataRiferimento, 
		DescTipoProcedura,
		sum( Num ) as Num
		
	 from DASHBOARD_VIEW_GARE_CAL where 1 = 1 ' + @CrLf


	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf

	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	set @SQLCmd = @SQLCmd + ' GROUP BY  idpfu, id, Descrizione , DataRiferimento, DescTipoProcedura '	  + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf



	exec (@SQLCmd)    
	--print @SQLCmd

	--select 
	--	idpfu, 
	--	id,
	--	Descrizione , 
	--	DataRiferimento, 
	--	DescTipoProcedura,
	--	AZI_Ente ,
	--	Num

	-- from DASHBOARD_VIEW_GARE_CAL 


	
END


GO
