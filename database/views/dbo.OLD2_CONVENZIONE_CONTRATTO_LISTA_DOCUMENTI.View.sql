USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CONVENZIONE_CONTRATTO_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_CONVENZIONE_CONTRATTO_LISTA_DOCUMENTI] as
select 
	C1.id,
	C.id as LinkedDoc,
	c1.TipoDoc,
	C1.Protocollo,
	C1.Titolo,
	C1.Data,
	C1.DataInvio
	from ctl_doc C
			inner join ctl_doc C1 on C.linkeddoc= C1.linkeddoc
		where c.tipodoc='CONTRATTO_CONVENZIONE' and c.deleted = 0
				and c1.tipodoc in ('CONVENZIONE_VALORE','CONVENZIONE_PROROGA') and c1.deleted=0
				and C1.StatoDoc='Sended'
GO
