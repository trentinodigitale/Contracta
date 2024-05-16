USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_DASHBOARD_VIEW_CATALOGO_INTEGRATIVI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[SP_DASHBOARD_VIEW_CATALOGO_INTEGRATIVI]
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

	--set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CATALOGO' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	set @Macro_Convenzione			=  dbo.GetParam( 'Macro_Convenzione' , @Param ,1) 
	set @Convenzione_Lotto			=  dbo.GetParam( 'Convenzione_Lotto' , @Param ,1) 
	
	--set @SQLCmd =  'select 
	--		   c.Idpfu  
	--		 , pr.id as idRow
	--		 , pr.idHeader
	--		 , pr.Codice_Regionale as Codice
	--		 , pr.ValoreEconomico as PrezzoUnitario
	--		 , pr.AliquotaIva
	--		 , pr.DESCRIZIONE_CODICE_REGIONALE as Descrizione
	--		 , c.ID_RIGA 
	--		 , c.Convenzione
	--		 , c.QTDisp
	--		 , c.IdentificativoIniziativa
	--		 , PR.ValoreAccessorioTecnico
	--		 , c.Not_Editable
	--		 , c.TipoImporto
	--		 , c.Macro_Convenzione_Filtro
	--		 , c.Lotto
	--		 , c.NumOrd
	--		 , PR.unitadimisura
	--		 , c.AZI_Dest
	--		 , pr.NumeroLotto
	--		 , c.Titolo

	--		from DASHBOARD_VIEW_CATALOGO c
	--			inner join document_microlotti_dettagli pr on pr.idheader = ' + @Filter + ' and pr.tipodoc = ''ODC'' and c.idRow = pr.idHeaderLotto
	--	where idpfu = ' + cast( @IdPfu as varchar (20)) +  ' ' + @CrLf

		set @SQLCmd =  'select 
			   c.Idpfu  
			 , DCL.id as idRow
			 , DCL.idHeader
			 , DCL.Codice_Regionale as Codice
			 , DCL.ValoreEconomico as PrezzoUnitario
			 , DCL.AliquotaIva
			 , DCL.DESCRIZIONE_CODICE_REGIONALE as Descrizione
			 , DCL.id as ID_RIGA
			 , DC.id as Convenzione
			 , ''1'' as QTDisp
			 , DC.IdentificativoIniziativa
			 , DCL.ValoreAccessorioTecnico
			 
			 ,CASE TipoAcquisto	
				WHEN ''quantita'' then
					case ConAccessori
						when ''si'' then '' PrezzoUnitario ''
						else '' PrezzoUnitario  ValoreAccessorioTecnico ''
					end
				ELSE
					case ConAccessori
						when ''si'' then '' QTDisp ''
						else '' QTDisp  ValoreAccessorioTecnico ''
					end
				END   as Not_Editable

			 , DC.TipoImporto
			 , DC.Macro_Convenzione as Macro_Convenzione_Filtro
			 --, l.idRow as Lotto
			 , DC.NumOrd
			 , DCL.unitadimisura
			 , DC.AZI_Dest
			 , DCL.NumeroLotto
			 , c.Titolo

			from ctl_doc O with (nolock)
				--inner join document_microlotti_dettagli OD with (nolock) on  OD.idheader=O.id and  OD.idheader = ' + @Filter + ' and OD.tipodoc = ''ODC'' 
				inner join ctl_doc C with (nolock) on C.id=O.linkeddoc 
				inner join Document_Convenzione DC with (nolock) ON C.id = DC.id 
				inner join document_microlotti_dettagli DCL with (nolock) on DCL.idheader = DC.id and DCL.tipodoc = ''CONVENZIONE'' 
					and DCL.numerolotto in (select numerolotto from document_microlotti_dettagli where idheader=' + @Filter + ' and tipodoc = ''ODC'' ) 
					and DCL.statoriga in ('''',''saved'',''inserito'',''variato'')
			where O.id =' + @Filter + '
			'
			--where  PU.Idpfu = ' + cast( @IdPfu as varchar (20)) +  ' ' + @CrLf


	--if rtrim( @SQLWhere ) <> ''
	--	set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf

	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf
	
	--print @SQLCmd
	exec (@SQLCmd)
	--print @SQLCmd


GO
