USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_DASHBOARD_VIEW_CATALOGO_RIDUZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_SP_DASHBOARD_VIEW_CATALOGO_RIDUZIONE]
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
--Versione=1&data=2017-11-21&Attivita=157714&Nominativo=Federico


	declare @Param						varchar(8000)
	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @Macro_Convenzione			varchar(250)
	declare @Convenzione_Lotto			varchar(8000)
	declare @SQLCmd			varchar(max)
	declare @SQLWhere		varchar(8000)
		
	SET NOCOUNT ON

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CATALOGO' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	set @Macro_Convenzione			=  dbo.GetParam( 'Macro_Convenzione' , @Param ,1) 
	set @Convenzione_Lotto			=  dbo.GetParam( 'Convenzione_Lotto' , @Param ,1) 
	
	set @SQLCmd =  'select 
			   c.Idpfu  
			 , pr.id as idRow
			 , pr.idHeader
			 , pr.Codice_Regionale as Codice
			 , pr.ValoreEconomico as PrezzoUnitario
			 , pr.AliquotaIva
			 , pr.DESCRIZIONE_CODICE_REGIONALE as Descrizione
			 , c.ID_RIGA 
			 , c.Convenzione
			 , c.QTDisp
			 , c.IdentificativoIniziativa
			 , PR.ValoreAccessorioTecnico
			 , c.Not_Editable
			 , c.TipoImporto
			 , c.Macro_Convenzione_Filtro
			 , c.Lotto
			 , c.NumOrd
			 , PR.unitadimisura
			 , c.AZI_Dest
			 , pr.NumeroLotto
			 , c.Titolo

			from DASHBOARD_VIEW_CATALOGO c
				inner join document_microlotti_dettagli pr on pr.idheader = ' + @Filter + ' and pr.tipodoc = ''ODC'' and c.idRow = pr.idHeaderLotto
		where idpfu = ' + cast( @IdPfu as varchar (20)) +  ' ' + @CrLf


	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf

	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--print @SQLCmd



GO
