USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_LOAD_SEC_BANDO_COPERTINA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- in sostituzione della vista document_bando_copertina

CREATE PROCEDURE [dbo].[OLD_DOCUMENT_LOAD_SEC_BANDO_COPERTINA](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on


	
	select * 
		into #D
		from ctl_doc d with (nolock) 
			left outer join Document_Bando B with (nolock) on b.idheader=d.id
		where id=@IdDoc


	declare @aziRagioneSociale as nvarchar(1000) -- da riportare in output
	declare @StazioneAppaltante as int -- da riportare in output
	select  @aziRagioneSociale=az1.aziRagioneSociale , @StazioneAppaltante=az1.idazi
		from  aziende az1
			cross join #D
		where az1.idazi = azienda



	declare @TipoBandoScelta as nvarchar(max) -- da riportare in output
	select @TipoBandoScelta=ct.value  
		from CTL_DOC_Value CT with(nolock)
			where CT.idHeader=@IdDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBandoScelta'


	declare @id_modello as nvarchar(max) -- da riportare in output
	select  @id_modello=CT2.value
		from CTL_DOC_Value CT2 with(nolock)
		where CT2.idHeader=@IdDoc and CT2.DSE_ID='TESTATA_PRODOTTI' and CT2.DZT_Name='id_modello'	

	declare @ClasseIscriz_Sospese as nvarchar(max) -- da riportare in output
	select  @ClasseIscriz_Sospese=CT3.Value 
		from CTL_DOC_Value CT3  with(nolock)
		where CT3.idHeader=@IdDoc and CT3.DSE_ID='CLASSI' and CT3.DZT_Name='ClasseIscriz_Sospese'


	declare @ClasseIscriz_Revocate as nvarchar(max) -- da riportare in output
	select  @ClasseIscriz_Revocate=CT4.Value
			from CTL_DOC_Value CT4 with(nolock)
			where CT4.idHeader=@IdDoc and CT4.DSE_ID='CLASSI' and CT4.DZT_Name='ClasseIscriz_Revocate'


	declare @Categorie_Merceologiche as nvarchar(max) -- da riportare in output
	select  @Categorie_Merceologiche=CT5.Value
		from CTL_DOC_Value CT5 with(nolock)
		where CT5.idHeader=@IdDoc and CT5.DSE_ID='TESTATA_PRODOTTI' and CT5.DZT_Name='Categorie_Merceologiche'

	declare @Elenco_Categorie_Merceologiche  as nvarchar(max) -- da riportare in output
	select  @Elenco_Categorie_Merceologiche=CT6.Value
		from CTL_DOC_Value CT6 with(nolock)
		where CT6.idHeader=@IdDoc and CT6.DSE_ID='TESTATA_PRODOTTI' and CT6.DZT_Name='Elenco_Categorie_Merceologiche'


	declare @Livello_Categorie_Merceologiche as nvarchar(max) -- da riportare in output
	select  @Livello_Categorie_Merceologiche=CT7.Value
		from CTL_DOC_Value CT7  with(nolock)
		where CT7.idHeader=@IdDoc and CT7.DSE_ID='TESTATA_PRODOTTI' and CT7.DZT_Name='Livello_Categorie_Merceologiche'


	declare @NumGiorniDomandaPartecipazione as nvarchar(max) -- da riportare in output
	select  @NumGiorniDomandaPartecipazione=CT8.Value
		from CTL_DOC_Value CT8  with(nolock)
		where CT8.idHeader=@IdDoc and CT8.DSE_ID='TESTATA_PRODOTTI' and CT8.DZT_Name='NumGiorniDomandaPartecipazione'


	declare @Richiesta_Info as nvarchar(max) -- da riportare in output
	select  @Richiesta_Info=CT9.Value
		from CTL_DOC_Value CT9  with(nolock)
		where CT9.idHeader=@IdDoc and CT9.DSE_ID='TESTATA_PRODOTTI' and CT9.DZT_Name='Richiesta_Info'

	
	
	declare @NoteScheda as nvarchar(max) -- da riportare in output
	select  @NoteScheda = CT10.Value
		from CTL_DOC_Value CT10  with(nolock)
		where CT10.idHeader=@IdDoc and CT10.DSE_ID='CLASSI' and CT10.DZT_Name='NoteScheda'
	

	declare @FLAG_NUOVA_ESTRAZIONE_OE as int -- da riportare in output
	set @FLAG_NUOVA_ESTRAZIONE_OE=1
	select @FLAG_NUOVA_ESTRAZIONE_OE = case when  count(c.id)<1  then 1 else 0 end
		from CTL_DOC c with(nolock) 
		where TipoDoc='OE_DA_CONTROLLARE' and StatoFunzionale='InLavorazione' and deleted=0 and LinkedDoc=@IdDoc




	select 
		D.* 
		,@TipoBandoScelta as TipoBandoScelta
		,@id_modello as id_modello
		,@ClasseIscriz_Sospese as ClasseIscriz_Sospese
		,@ClasseIscriz_Revocate as ClasseIscriz_Revocate
		,@Categorie_Merceologiche as Categorie_Merceologiche
		,@Elenco_Categorie_Merceologiche as Elenco_Categorie_Merceologiche
		,@Livello_Categorie_Merceologiche as Livello_Categorie_Merceologiche
		,@NumGiorniDomandaPartecipazione as NumGiorniDomandaPartecipazione
		,@Richiesta_Info as Richiesta_Info
		,@NoteScheda as NoteScheda
		,@aziRagioneSociale as aziRagioneSociale
		,@StazioneAppaltante as StazioneAppaltante
		,@FLAG_NUOVA_ESTRAZIONE_OE as FLAG_NUOVA_ESTRAZIONE_OE

		from #D D

	
	





end

GO
