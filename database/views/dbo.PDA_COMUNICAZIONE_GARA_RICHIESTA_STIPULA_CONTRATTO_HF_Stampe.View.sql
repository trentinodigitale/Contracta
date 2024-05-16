USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_COMUNICAZIONE_GARA_RICHIESTA_STIPULA_CONTRATTO_HF_Stampe]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PDA_COMUNICAZIONE_GARA_RICHIESTA_STIPULA_CONTRATTO_HF_Stampe]
AS
	select 
		id as idRow , 
		ID AS idDoc ,
		'header1' as tipo ,
		'<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       .contenitore_stampa    {          margin: 0 auto;     width:950px ;       }        
			table     {     width: 100%;               }       
			</style>   
		    </head> 
			<div class="contenitore_stampa" ><table style="font-weight:bold; align=center; vertical-align:center;" width="100%" >' +
			+ '<tr><td height="50px" align="left" valign="top" >'				 
			+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') + '"/>"' end
			+ '</td></tr>
			    <tr><td height="50px" align="center" valign="top" >
			    <div><h3><center>' + dbo.CNV('nome_portale','I') + '</center></h3></div><div><b></b><center><b>' + aziRagioneSociale + '</b><b></b></center></div>
			    </td></tr>
			 </table></div>' 
		as  htmlValue

	from ctl_doc with(nolock) 
		inner join Aziende with(nolock) on IdAzi=Azienda
		
union
	
	select 
		id as idRow , 
		ID AS idDoc ,
		'headerN' as tipo ,
		'<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       .contenitore_stampa    {          margin: 0 auto;    width:950px ;        }        
			table     {     width: 100%;               }       
			</style>   
		    </head> 
			<div class="contenitore_stampa" ><table style="font-weight:bold; align=center; vertical-align:center;"   width="100%" >' +
			+ '<tr><td height="50px" align="left" valign="top" >'				 
			+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') + '"/>"' end
			+ '</td></tr>
			    
			 </table></div>' 
		as  htmlValue

	from ctl_doc with(nolock)
			inner join Aziende with(nolock) on IdAzi=Azienda
union

	select 
		id as idRow , 
		ID AS idDoc ,
		'footer' as tipo ,
		'<html>     
			<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>    
			<style>       .contenitore_stampa    {          margin: 0 auto;     width:950px ;     }        
			table     {     width: 100%;               }       
			</style>   
		    </head>     <body>      <div class="contenitore_stampa" >       
			<table id="TABLE_CONTENTITORE" align="" style="width: 100%;" >     
			<tr><td>   <table width="100%" height="10px" style="vertical-align: bottom; bottom: 0px">
			<tr><td valign="bottom" align="right" ><br> Pag. &p; / &P;
			</td></tr></table>
			</td></tr></table>
			</div></body>
			</html>' as  htmlValue

	from ctl_doc with(nolock)
GO
