USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_USER_DOC]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_VIEW_USER_DOC]
as
SELECT 
   C.[Id], C.[IdPfu], C.[IdDoc], C.[TipoDoc], C.[StatoDoc], C.[Data], C.[Protocollo], C.[PrevDoc], C.[Deleted], C.[Titolo], C.[Body], 
   C.[Azienda], C.[StrutturaAziendale], C.[DataInvio], C.[DataScadenza], C.[ProtocolloRiferimento], C.[ProtocolloGenerale], 
   C.[Fascicolo], ISNULL(C.[Note],'') as Note, C.[DataProtocolloGenerale], C.[LinkedDoc], 
   C.[SIGN_HASH], C.[SIGN_ATTACH], C.[SIGN_LOCK], C.[JumpCheck], C.[StatoFunzionale], C.[Destinatario_User],
    C.[Destinatario_Azi], C.[RichiestaFirma], C.[NumeroDocumento], C.[DataDocumento], C.[Versione], C.[VersioneLinkedDoc],
	 C.[GUID], C.[idPfuInCharge], C.[CanaleNotifica], C.[URL_CLIENT], C.[Caption], C.[FascicoloGenerale], C.[CRYPT_VER]
   ,pfuDataCreazione
   ,CASE ISNULL(pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti 
   , pfuProfili
   ,case when a1.aziProfili IS null then a2.aziProfili else a1.aziProfili end as aziProfili
   , case when p1.IdPfu is null then 0 else 1 end as ProfiloAlbo
  FROM 	CTL_DOC C with(nolock)
	left outer join profiliutente p with (nolock) on p.idpfu=Destinatario_USer
	left outer join  aziende a1 with (nolock) on p.pfuidazi = a1.idazi
	-- gestione del caso di un utente creato nuovo (la join di sopra fallisce)
	left outer join  aziende a2 with (nolock) on C.Azienda  = a2.idazi
	left outer join profiliutenteattrib p1 with (nolock) on p1.idpfu=Destinatario_USer  and p1.dztNome = 'Profilo' and p1.attValue in (  'ALBO_VALUTATORE'  )
	where tipodoc in('user_doc','user_doc_oe')

GO
