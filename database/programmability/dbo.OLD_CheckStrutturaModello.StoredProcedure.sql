USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CheckStrutturaModello]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_CheckStrutturaModello]
	 @modellobando as varchar(200), 	@idpfu as int  , @extra_hide_cols as nvarchar(max) = ''
AS
BEGIN

	SET NOCOUNT ON

	--declare @modellobando as varchar(500)
	declare @ColonneImportate as nvarchar(max)
	declare @NomiColonne as nvarchar(max)
	declare @NomiColonne_HIDE as nvarchar(max)
	declare @NomiColonneSource as nvarchar(max)
	declare @NomiColonneInt as int	
    declare @strScriptColonneImportate as nvarchar(max)

	--recupero modello bando associato
	--select @modellobando=modellobando from Document_Modelli_MicroLotti where codice=@CodModello
	set @NomiColonne=''
	set @NomiColonneSource=''
	set @NomiColonneInt=0

	set @NomiColonne_HIDE=' ToDelete,FNZ_OPEN,EsitoRiga,StatoRiga,NotEditable,Fnz_Del,TipoDoc,Aggiudicata,ValoreImportoLotto,FNZ_ADD,AmpiezzaGamma'
	set @NomiColonne_HIDE= @NomiColonne_HIDE + ',' + @extra_hide_cols
	select 
	   @NomiColonne = @NomiColonne + ',' + replace(dbo.StripHTML( rtrim(ltrim( isnull( cast( ML_Description as nvarchar(500)), Ma_descml))) ) ,'''',''''''),
	   --@NomiColonneSource = @NomiColonneSource + ' + '',''' + dbo.GenerateSequence( @NomiColonneInt ) + ','''')))' ,
	   @NomiColonneSource = @NomiColonneSource + ' + '',''' + ' + rtrim(ltrim(isnull(' + dbo.GenerateSequence( @NomiColonneInt ) + ','''')))' ,
	   @NomiColonneInt = @NomiColonneInt +1	

	   --from LIB_ModelAttributes 
	   from CTL_ModelAttributes with(nolock)
		  inner join dbo.LIB_Dictionary L with(nolock) on L.DZT_Name = MA_DZT_Name and L.DZT_Type not in (18) 
		  --left outer join LIB_Multilinguismo on ML_KEY = Ma_descml and ML_LNG = 'I' and ML_Context = 0
		  left outer join CTL_Multilinguismo with(nolock) on ML_KEY = Ma_descml and ML_LNG = 'I' and ML_Context = 0
		   left outer join CTL_ModelAttributeProperties with (nolock) on MAP_MA_MOD_ID = MA_MOD_ID and MAP_MA_DZT_Name =MA_DZT_Name and MAP_Propety ='Hide' and MAP_Value ='1'
	   where 
		  MA_MOD_ID=@modellobando 
		  and Ma_DZT_Name not in (select items from dbo.Split(@NomiColonne_HIDE,',') ) 
		  and map_id is null
		  order by ma_pos
		  

	set @NomiColonne = SUBSTRING ( @NomiColonne , 2 , len(@NomiColonne) ) 
	set @NomiColonneSource = SUBSTRING ( @NomiColonneSource , 9 , len(@NomiColonneSource) ) 
	
	

	--recupero colonne importate
	set @strScriptColonneImportate=
	'select  * from 
		ctl_import with(nolock)
	where idpfu=' + cast(@idpfu as varchar) + ' and ' +
	  @NomiColonneSource + '=''' + @NomiColonne + ''''

	--print @strScriptColonneImportate
	exec (@strScriptColonneImportate)
	

END

GO
