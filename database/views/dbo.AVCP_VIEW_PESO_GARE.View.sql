USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_VIEW_PESO_GARE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AVCP_VIEW_PESO_GARE] AS

	select a.Id, a.codiceEstrazione,

				case when a.origine = 'DOC_CTL' and a.divisioneInLotti = '1' then isnull(b.peso,1) 
					 else 1 
			     end as peso

		from avcp_import_bandi a with(nolock)
				left join (
								select count(b1.idheader) as peso, b1.idheader, b1.TipoDoc
								from avcp_import_bandi a1 with(nolock)
										inner join Document_MicroLotti_Dettagli b1 with(nolock) on b1.IdHeader = a1.idMsg and b1.TipoDoc = a1.TipoDocBando and ISNULL(b1.Voce,0) = 0
								group by b1.IdHeader, b1.TipoDoc
					) b on b.IdHeader = a.idMsg and b.TipoDoc = a.TipoDocBando


GO
