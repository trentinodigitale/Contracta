USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_AMPIEZZA_FIRME_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [dbo].[OLD_OFFERTA_AMPIEZZA_FIRME_VIEW] as

	select 
		--C.Id, 
		m.id,
		df.idRow,
		m.idHeaderLotto AS idheader,
		C.IdPfu, 		
		C.LinkedDoc, 
		df.f4_SIGN_HASH as SIGN_HASH,
		DF.f4_SIGN_ATTACH as SIGN_ATTACH, 
		df.f4_SIGN_LOCK as SIGN_LOCK, 
		Df.F4_DESC as [desc],
		C.JumpCheck	
			from Document_MicroLotti_Dettagli m with (nolock)	
				inner join CTL_DOC c with(nolock) ON c.id = m.idheader --offerta
				left join Document_Microlotto_Firme DF with(nolock)  on DF.idheader=C.id 
					where m.tipodoc = 'OFFERTA_AMPIEZZA' and c.tipodoc='OFFERTA' and c.deleted=0 and ISNULL(DF.F4_SIGN_ATTACH,'') <> ''
	union 

	select 
		--C.Id, 
		m.id,
		df.idRow,
		m.idHeaderLotto AS idheader,
		C.IdPfu, 		
		C.LinkedDoc, 
		df.f4_SIGN_HASH as SIGN_HASH,
		DF.f4_SIGN_ATTACH as SIGN_ATTACH, 
		df.f4_SIGN_LOCK as SIGN_LOCK, 
		Df.F4_DESC as [desc],
		C.JumpCheck	
			from Document_MicroLotti_Dettagli m with (nolock)	
				inner join CTL_DOC c with(nolock) ON c.id = m.idheader --offerta
				left join CTL_DOC_SIGN DF with(nolock)  on DF.idheader=C.id 
					where m.tipodoc = 'OFFERTA_AMPIEZZA' and c.tipodoc='OFFERTA' and c.deleted=0 and ISNULL(DF.F4_SIGN_ATTACH,'') <> ''
			
GO
