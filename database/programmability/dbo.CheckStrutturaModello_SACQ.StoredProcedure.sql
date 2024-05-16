USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CheckStrutturaModello_SACQ]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[CheckStrutturaModello_SACQ]
	 @modellobando as varchar(200), 	@idpfu as int 
AS
BEGIN

	SET NOCOUNT ON

	--declare @modellobando as varchar(500)
	declare @ColonneImportate as nvarchar(4000)
	declare @NomiColonne as nvarchar(4000)
	declare @NomiColonneSource as nvarchar(4000)
	declare @NomiColonneInt as int	
     declare @strScriptColonneImportate as nvarchar(4000)

	--recupero modello bando associato
	--select @modellobando=modellobando from Document_Modelli_MicroLotti where codice=@CodModello
	set @NomiColonne=''
	set @NomiColonneSource=''
	set @NomiColonneInt=0

	

	select 
		   @NomiColonne = @NomiColonne + ',' + replace(dbo.StripHTML( rtrim(ltrim( isnull( cast( ML_Description as nvarchar(500)), Ma_descml))) ) ,'''',''''''),
		  --@NomiColonneSource = @NomiColonneSource + ' + '',''' + dbo.GenerateSequence( @NomiColonneInt ) + ','''')))' ,
		  @NomiColonneSource = @NomiColonneSource + ' + '',''' + ' + rtrim(ltrim(isnull(' + dbo.GenerateSequence( @NomiColonneInt ) + ','''')))' ,
		  @NomiColonneInt = @NomiColonneInt +1	

	    --from LIB_ModelAttributes 
	    from 
		  CTL_ModelAttributes 
		  inner join dbo.LIB_Dictionary L on L.DZT_Name = MA_DZT_Name and L.DZT_Type not in (18) 
		  --left outer join LIB_Multilinguismo on ML_KEY = Ma_descml and ML_LNG = 'I' and ML_Context = 0
		  left outer join CTL_Multilinguismo on ML_KEY = Ma_descml and ML_LNG = 'I' and ML_Context = 0
		  left outer join CTL_ModelAttributeProperties with (nolock) on MAP_MA_MOD_ID = MA_MOD_ID and MAP_MA_DZT_Name =MA_DZT_Name and MAP_Propety ='Hide' and MAP_Value ='1'
	    where 
		  MA_MOD_ID=@modellobando 
		  and Ma_DZT_Name not in ('EsitoRiga','StatoRiga','NotEditable','Fnz_Del','TipoDoc','TipoAcquisto' ) 
		  and map_id is null
		  order by ma_pos
	
	set @NomiColonne = SUBSTRING ( @NomiColonne , 2 , len(@NomiColonne) ) 
	set @NomiColonneSource = SUBSTRING ( @NomiColonneSource , 9 , len(@NomiColonneSource) ) 
	
	

	--recupero colonne importate
	set @strScriptColonneImportate=
	'select  * from 
		ctl_import 
	where idpfu=' + cast(@idpfu as varchar) + ' and ' +
	  @NomiColonneSource + '=''' + @NomiColonne + ''''

	--print @strScriptColonneImportate
	exec (@strScriptColonneImportate)
	

END





GO
