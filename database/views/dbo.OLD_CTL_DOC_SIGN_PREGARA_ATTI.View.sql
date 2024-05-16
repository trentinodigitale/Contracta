USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CTL_DOC_SIGN_PREGARA_ATTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_CTL_DOC_SIGN_PREGARA_ATTI] as
select 
	[idRow], 
	[idHeader], 
	[F1_DESC], 
	[F1_SIGN_HASH], 
	[F1_SIGN_ATTACH], 
	[F1_SIGN_LOCK], 
	[F2_DESC], 
	[F2_SIGN_HASH], 
	[F2_SIGN_ATTACH], 
	[F2_SIGN_LOCK], 
	[F3_DESC], 
	[F3_SIGN_HASH], 
	[F3_SIGN_ATTACH], 
	[F3_SIGN_LOCK], 
	[F4_DESC], 
	[F4_SIGN_HASH], 
	[F4_SIGN_ATTACH], 
	[F4_SIGN_LOCK] ,  
	--F4_SIGN_LOCK = '1' allegato inserito dalla lista degli atti
	case 
		when C.StatoFunzionale IN ('CompilazioneAtti','ParereLegaleNonApp') AND F4_SIGN_LOCK = '1' then ' F3_DESC F1_SIGN_ATTACH F2_SIGN_ATTACH '  
		when C.StatoFunzionale IN ('CompilazioneAtti','ParereLegaleNonApp') AND F4_SIGN_LOCK <> '1' then ' F1_SIGN_ATTACH F2_SIGN_ATTACH '  
		when C.StatoFunzionale IN ('FirmaAtti') then ' FNZ_DEL F3_DESC F3_SIGN_ATTACH F2_SIGN_ATTACH ' 
		when C.StatoFunzionale IN ('FirmaAttiEDetermina') then ' FNZ_DEL F3_DESC F3_SIGN_ATTACH F1_SIGN_ATTACH '
		else ' FNZ_DEL F3_DESC F3_SIGN_ATTACH F1_SIGN_ATTACH F2_SIGN_ATTACH '  
	end	AS NotEditable
	from CTL_DOC_SIGN CS with(nolock)
		inner join CTL_DOC C with(nolock) on CS.idHeader=C.Id and C.TipoDoc='PREGARA'
	where F4_DESC = 'ATTI'
GO
