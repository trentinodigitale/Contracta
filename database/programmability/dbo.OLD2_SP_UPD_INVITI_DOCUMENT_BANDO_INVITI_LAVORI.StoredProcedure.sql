USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_UPD_INVITI_DOCUMENT_BANDO_INVITI_LAVORI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_SP_UPD_INVITI_DOCUMENT_BANDO_INVITI_LAVORI] ( @idDoc int , @IdUser int , @operation varchar(200) )
AS
BEGIN
	declare @categoriaSOA as varchar(200)
	declare @classificaSOA as varchar(200)
		
	--PRENDO LE INFO DALLA MIA RICERCA OE, VISTO CHE SULLA CLICK RICERCA VENGONO STATICIZZATI SUL DOC		
	select @categoriaSOA=value from CTL_DOC_Value with(nolock) where  IdHeader=@idDoc and DSE_ID='InfoTec_CategoriaPrevalente' and DZT_Name='CategoriaSOA' and Row=0
	select @classificaSOA=value from CTL_DOC_Value with(nolock) where  IdHeader=@idDoc and DSE_ID='InfoTec_CategoriaPrevalente' and DZT_Name='classificaSOA' and Row=0
		
	if @operation = 'INCREMENTO'
	BEGIN
		--AGGIORNO QUELLI PRESENTI
		update DL set DL.NumInvitiReali=ISNULL(DL.NumInvitiReali,0)+1
			from DOCUMENT_BANDO_INVITI_LAVORI DL
				inner join CTL_DOC_Destinatari CD on CD.idHeader=@idDoc and Seleziona='Includi' and DL.idAzi=CD.IdAzi 
			where DL.CategoriaSOA=@categoriaSOA and DL.ClassificaSOA=@classificaSOA
		
		--INSERISCE QUELLI NUOVI
		insert into DOCUMENT_BANDO_INVITI_LAVORI ( [idAzi], [CategoriaSOA], [ClassificaSOA], [NumInvitiReali], [Iscritto])
			select CD.IdAzi,@categoriaSOA,@classificaSOA,ISNULL(DL.NumInvitiReali,0)+1,0
				from CTL_DOC_Destinatari CD
					--left join DOCUMENT_BANDO_INVITI_LAVORI DL on DL.idAzi=CD.IdAzi
					--bugfix kpf 441654 per inserire se non presenti per quelle categiorie
					left join DOCUMENT_BANDO_INVITI_LAVORI DL on DL.idAzi=CD.IdAzi and  DL.CategoriaSOA=@categoriaSOA and DL.ClassificaSOA=@classificaSOA
					where CD.idHeader=@idDoc and Seleziona='Includi' and DL.idAzi is null
	END

	if @operation = 'STORNO'
	BEGIN
		update DL set DL.NumInvitiReali=ISNULL(DL.NumInvitiReali,0)-1
			from DOCUMENT_BANDO_INVITI_LAVORI DL
				inner join CTL_DOC_Destinatari CD on CD.idHeader=@idDoc and Seleziona='Includi' and DL.idAzi=CD.IdAzi 
			where DL.CategoriaSOA=@categoriaSOA and DL.ClassificaSOA=@classificaSOA and ISNULL(DL.NumInvitiReali,0) > 0
	END






END
GO
