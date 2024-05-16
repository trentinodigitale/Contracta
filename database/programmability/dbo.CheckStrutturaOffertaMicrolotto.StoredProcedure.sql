USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CheckStrutturaOffertaMicrolotto]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CheckStrutturaOffertaMicrolotto]
	-- Add the parameters for the stored procedure here
	@iddoc as int, 
	@idpfu as int
AS
BEGIN



	SET NOCOUNT ON;

	--declare @iddoc as int
	--declare @idpfu as int
	--set @iddoc=100920
	--set @idpfu=42690	

	declare @modello as varchar(500)
	declare @modelloofferta as varchar(500)
	declare @ColonneImportate as nvarchar(4000)
	declare @NomiColonne as nvarchar(4000)
	declare @NomiColonneSource as nvarchar(4000)
	declare @NomiColonneInt as int	

	--recupero modello selezionato
	select @modello=listamodellimicrolotti from tab_messaggi_fields where idmsg=@iddoc

	--recupero modello bando associato
	select @modelloofferta=modelloofferta from Document_Modelli_MicroLotti where codice=@modello
	
	set @NomiColonne=''
	set @NomiColonneSource=''
	set @NomiColonneInt=0

	select 
		   @NomiColonne = @NomiColonne + ',' + rtrim(ltrim(replace(Ma_descml,'''',''''''))) ,
		   @NomiColonneSource = @NomiColonneSource + ' + '',''' + ' + rtrim(ltrim(isnull(' + dbo.GenerateSequence( @NomiColonneInt ) + ','''')))' ,
		   @NomiColonneInt = @NomiColonneInt +1	

	from LIB_ModelAttributes 
	where 
		MA_MOD_ID=@modelloofferta and Ma_DZT_Name not in ('EsitoRiga' , 'ValoreOfferta') order by ma_pos

	set @NomiColonne = SUBSTRING ( @NomiColonne , 2 , len(@NomiColonne) ) 
	set @NomiColonneSource = SUBSTRING ( @NomiColonneSource , 9 , len(@NomiColonneSource) ) 
	
	--print @NomiColonne
	--print @NomiColonneSource

	--recupero colonne importate
	declare @strScriptColonneImportate as nvarchar(4000)

	
	set @strScriptColonneImportate=
	'select  * from 
		ctl_import 
	where idpfu=' + cast(@idpfu as varchar) + ' and ' +
	  @NomiColonneSource + '=''' + @NomiColonne + ''''

	--print @strScriptColonneImportate
	exec (@strScriptColonneImportate)


END

GO
