USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_SCRITTURA_PRIVATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[DOCUMENT_CK_TOOLBAR_SCRITTURA_PRIVATA]  ( @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
BEGIN
	
	SET NOCOUNT ON

	--controllo se attiva interop sulla gara associata
	DECLARE @IdGara int 
	declare @attivo_INTEROP_Gara as int
	set @attivo_INTEROP_Gara = 0


	select 
		@IdGara = B.ID 
	from 
		CTL_DOC C with(nolock) 
			inner join CTL_DOC PDA_COM with(nolock)  on PDA_COM.Id=C.LinkedDoc
			inner join CTL_DOC PDA with(nolock)  on PDA.Id=PDA_COM.LinkedDoc
			inner join ctl_doc B with(nolock)  on B.ID = PDA.LinkedDoc AND B.TIPODOC IN ( 'BANDO_GARA')
			inner join document_bando DETT_B with(nolock)  on DETT_B.idheader = B.ID
			inner join Document_PCP_Appalto A with(nolock)  on A.idheader = B.ID
	where	C.Id = @IdDoc

	set @attivo_INTEROP_Gara = dbo.attivo_INTEROP_Gara( @IdGara )

	select 
	   Id, 
	   IdPfu, 
	   IdDoc, 
	   TipoDoc, 
	   StatoDoc, 
	   Data, 
	   Protocollo, 
	   PrevDoc, 
	   Deleted, 
	   Titolo, 
	   Body, 
	   Azienda, 
	   StrutturaAziendale, 
	   DataInvio, 
	   DataScadenza, 
	   ProtocolloRiferimento, 
	   ProtocolloGenerale, 
	   Fascicolo, 
	   Note, 
	   DataProtocolloGenerale, 
	   LinkedDoc, 
	   SIGN_HASH, 
	   SIGN_ATTACH, 
	   SIGN_LOCK, 
	   JumpCheck, 
	   StatoFunzionale, 
	   Destinatario_User, 
	   Destinatario_Azi, 
	   RichiestaFirma, 
	   NumeroDocumento, 
	   DataDocumento, 
	   Versione, 
	   VersioneLinkedDoc, 
	   GUID, 
	   idPfuInCharge, 
	   CanaleNotifica, 
	   URL_CLIENT, 
	   Caption,
	   c1.value as DataRiferimento,
	   c2.value as DataRiferimentoInizio,
	   c3.value as DataRisposta,
	   c4.value as DataScadenzaOfferta,
	   c5.value as ProtocolloOfferta,
	   ISNULL(cs.F1_SIGN_HASH,'') as F1_SIGN_HASH,
	   ISNULL(cs.F1_SIGN_LOCK,'') as F1_SIGN_LOCK,
	   ISNULL(cs.F1_SIGN_ATTACH,'') as  F1_SIGN_ATTACH,
	   ISNULL(cs.F2_SIGN_ATTACH,'') as  F2_SIGN_ATTACH,
	   ISNULL(cs.F2_SIGN_HASH,'') as F2_SIGN_HASH,

	   c6.value as CodiceIPA,
	   c7.value as firmatario,

	   ' CodiceIPA , firmatario , CF_FORNITORE , Firmatario_OE ' as NotEditable,
	   case 
			when isnull(c8.Value,'') = '' then 'no'
			else 'si'
		end as FlagScadenza,
		c9.value as CF_FORNITORE,
		c10.value as Firmatario_OE,
		@attivo_INTEROP_Gara as attivo_INTEROP_Gara

		from 
			ctl_doc with(nolock)
				inner join ctl_doc_value c1 with(nolock) on c1.idheader=id and c1.DSE_ID='DOCUMENT' and c1.dzt_name='DataBando' and c1.row=0
				inner join ctl_doc_value c2 with(nolock) on c2.idheader=id and c2.DSE_ID='DOCUMENT' and c2.dzt_name='DataRiferimentoInizio' and c2.row=0
				inner join ctl_doc_value c3 with(nolock) on c3.idheader=id and c3.DSE_ID='DOCUMENT' and c3.dzt_name='DataRisposta' and c3.row=0
				inner join ctl_doc_value c4 with(nolock) on c4.idheader=id and c4.DSE_ID='DOCUMENT' and c4.dzt_name='DataScadenzaOfferta' and c4.row=0
				inner join ctl_doc_value c5 with(nolock) on c5.idheader=id and c5.DSE_ID='DOCUMENT' and c5.dzt_name='ProtocolloOfferta' and c5.row=0
				left join ctl_doc_sign cs with(nolock) on cs.idheader=id 

				left join ctl_doc_value c6 with(nolock) on c6.idheader=id and c6.DSE_ID='CONTRATTO' and c6.dzt_name='CodiceIPA' 
				left join ctl_doc_value c7 with(nolock) on c7.idheader=id and c7.DSE_ID='CONTRATTO' and c7.dzt_name='firmatario' 

				left join CTL_DOC_Value c8 with(nolock) on c8.IdHeader = Id and c8.DSE_ID ='CONTRATTO' and c8.dzt_name='DataScadenza' 
				left join ctl_doc_value c9 with(nolock) on c9.idheader=id and c9.DSE_ID='CONTRATTO' and c9.dzt_name='CF_FORNITORE' 
				left join ctl_doc_value c10 with(nolock) on c10.idheader=id and c10.DSE_ID='CONTRATTO' and c10.dzt_name='Firmatario_OE' 

			where 
				Id =@IdDoc
			--tipodoc='SCRITTURA_PRIVATA' and deleted=0

end


GO
