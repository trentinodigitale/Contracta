USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ODA_Product_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[Document_ODA_Product_view]
AS
SELECT       
	d.Id,
	d.IdHeader,
	d.TipoDoc,
	d.StatoRiga,
	d.EsitoRiga,
	d.Descrizione,
	d.UnitadiMisura,
	d.Quantita,
	ISNULL(d.AliquotaIva, 0) as AliquotaIva,
	d.CodiceProdotto,
	d.CampoTesto_1,
	d.idHeaderLotto,
	d.NumeroRiga,
	d.PREZZO_OFFERTO_PER_UM,
	d.ALL_FIELD,
	d.ClasseIscriz_S,
	d.AREA_DI_CONSEGNA,
	d.FotoProdotto,
	d.ValoreEconomico,
	d.VALORE_COMPLESSIVO_OFFERTA
FROM           
	ctl_doc c with (nolock)
		inner join document_microlotti_dettagli d with (nolock) on C.id = D.idheader and C.tipodoc = D.Tipodoc
where
	C.tipodoc='ODA'
GO
