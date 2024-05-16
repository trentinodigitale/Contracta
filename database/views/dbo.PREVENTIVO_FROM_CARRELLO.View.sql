USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREVENTIVO_FROM_CARRELLO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[PREVENTIVO_FROM_CARRELLO] as
SELECT distinct  b.idPfu as ID_FROM 
                    , b.Plant as StrutturaAziendale
					, cast( Id_Convenzione  as int ) as Id_Convenzione
					, NumOrd as ProtocolloRiferimento -- NumeroConvenzione
					, AZI_Dest as IdAziDest
					, c.IVA
					, c.TipoOrdine
					, c.ID as LinkedDoc
					, AZI_Dest as Destinatario_Azi
	
					, a.aziIndirizzoLeg
					, a.aziRagioneSociale				
					, a.aziTelefono1
					, a.aziFAX
					, p.pfuNome , p.pfuRuoloAziendale
					, a1.aziRagioneSociale as RagioneSocialeMittente
					, isnull( attValue , '' ) DirezioneMittente
					, p.pfuidAzi as Azienda
					, DataInizio
FROM         Carrello b
	inner join dbo.Document_Convenzione c on c.ID = cast( b.Id_Convenzione  as int )
	inner join aziende a on AZI_Dest = a.idazi
	inner join  profiliutente p on p.idpfu = b.idpfu
	inner join aziende a1 on p.PfuidAzi = a1.idazi
	left outer join profiliutenteattrib pa on b.idpfu = pa.idpfu and dztnome = 'Direzione'



GO
