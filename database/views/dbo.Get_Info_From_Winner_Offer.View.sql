USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Get_Info_From_Winner_Offer]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[Get_Info_From_Winner_Offer]
as
	select  
				a.id as IdDoc, -- id offerta vincente
				b.IdMsg as IdOfferta,
				d.LinkedDoc as IdRDA,			
				b2.Id as idRigaPDA,
				b.IdHeader as idPDA,
				az.idazi as IdAzi,
				az.aziRagioneSociale ,
				d.Id as IdBando	

			from Document_MicroLotti_Dettagli a with(nolock)		--PDA_OFFERTE

					inner join Document_PDA_OFFERTE b with(nolock) on b.Idrow = a.IdHeader

					inner join document_microlotti_dettagli b2 with(nolock) on b2.IdHeader = b.IdHeader 
										and b2.TipoDoc = 'PDA_MICROLOTTI' and b2.voce = 0
										and isnull(a.NumeroLotto,0) = isnull(b2.NumeroLotto,0)

					inner join CTL_DOC c with(nolock) on c.Id = b.IdHeader and c.Deleted = 0 -- VDA
					inner join CTL_DOC d with(nolock) on d.Id = c.LinkedDoc and d.Deleted = 0 -- GARA
					inner join CTL_DOC offer with(nolock) on offer.Id = b.IdMsg and offer.Deleted = 0 -- offerta
					inner join Aziende az with(nolock) on az.Idazi = offer.Azienda and aziDeleted = 0 -- offerta

			--where a.Id = 449
GO
