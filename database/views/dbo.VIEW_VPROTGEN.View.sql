USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VPROTGEN]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_VPROTGEN] AS

	select  id,
			Modalita as protgen_modalita,
			Data_Documento as DataDocumento,
			Oggetto,
			Descrizione,
			Appl_Id_Evento,
			Flag_Annullato as Annullato,
			ltrim(rtrim(prot_acquisito)) as protgen_avanzamento,
			Appl_Sigla as TipoDoc,
			Appl_Sigla as OPEN_DOC_NAME,
			jumpCheck as JumpCheck,
			sottoTipo,
			Numero_Protocollo as ProtocolloGenerale,
			Data_Protocollo as DataProtocolloGenerale
		from v_protgen with(nolock)
GO
