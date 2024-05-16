USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AVVISI_GARA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_AVVISI_GARA_VIEW] as

	select
			Id,
			cast (Body as varchar(8000)) as Body,
			DataInvio,
			Fascicolo,		
			ctl_doc.IdPfu,
			JumpCheck,
			LinkedDoc,
			'' as Note,
			PrevDoc,
			Protocollo,
			StatoDoc,
			StatoFunzionale,
			TipoDoc,
			ISNULL(rup.Value,DC.idpfu) as UserRUP,
			--rif.idpfu as UserRiferimento,
			dbo.ListRiferimentiBando(id,'Bando') as ListRiferimentiBando
			
		from ctl_doc
				left outer join ctl_doc_value rup on id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
				--Aggiungo l'utente usato come riferimento per la consultazione gare
				--left join Document_Bando_Riferimenti rif on rif.idHeader = Id and RuoloRiferimenti = 'Bando'
				--AGGIUNTA LA SECONDA LEFT PER RENDERLO COMPATIBILE ANCHE CON IL DOC BANDO E BANDO_SDA
				left outer join Document_Bando_Commissione DC on tipodoc in ('BANDO','BANDO_SDA') and DC.idHeader=id and DC.RuoloCommissione='15550'

	--UNION PER PRENDERE I RECORD DEL DOC GEN CON ID NEGATIVO
	UNION

	select
			-IdMsg as Id,
			Object_Cover1 as Body,
			Data as DataInvio,
			ProtocolBg as Fascicolo,		
			IdMittente as IdPfu,
			'' as JumpCheck,
			'' as LinkedDoc,
			'' as Note,
			'' as PrevDoc,
			Protocol as Protocollo,
			Stato as StatoDoc,
			'' as StatoFunzionale,
			'' asTipoDoc,
			 dbo.GetField_NEW('UtenteIncaricato',IdMsg) as  UserRUP,
			 --null as UserRiferimento
			 null as ListRiferimentiBando
		from TAB_MESSAGGI_FIELDS

GO
