USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboProf_HF_Stampe]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	
		

CREATE view [dbo].[ISTANZA_AlboProf_HF_Stampe]
AS
	select 
		id as idRow , 
		ID AS idDoc ,
		'header1' as tipo ,
		'<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head> 
		 <style>       .contenitore_stampa    {          margin: 0 auto;     width:950px ;     }        
		 table     {     width: 100%;               }       
		 </style>   
		 </head>     <body>      <div class="contenitore_stampa" > 
		 <table id="TABLE_CONTENTITORE" align=" style="width: 100%;" ' 
		+ case when Statodoc = 'Annullato' then + 'style="background-image:url(../images/annullato.gif) ; background-repeat:no-repeat;" >'
			else '>'
		  end
		+ '<tr><td height="50px" align="center" valign="top" >'
		+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') +  '"/>"' end
		+ '</td></tr></table></div>'
		as  htmlValue
	from ctl_doc with(nolock) 		
		
union
	
		select 
		id as idRow , 
		ID AS idDoc ,
		'headerN' as tipo ,
		'<head>   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head> 
		 <style>       .contenitore_stampa    {          margin: 0 auto;     width:950px ;     }        
		 table     {     width: 100%;               }       
		 </style>   
		 </head>     <body>      <div class="contenitore_stampa" > 
		 <table id="TABLE_CONTENTITORE" align=" style="width: 100%;" ' 
		+ case when Statodoc = 'Annullato' then + 'style="background-image:url(../images/annullato.gif) ; background-repeat:no-repeat;" >'
			else '>'
		  end
		+ '<tr><td height="50px" align="center" valign="top" >'
		+ case when dbo.CNV('HEADER_STAMPE','I') <> 'HEADER_STAMPE' then dbo.CNV('HEADER_STAMPE','I') else '<img height="50px" src="logo_new.gif" border="0" alt="' + dbo.CNV('ALT LOGO','I') +  '"/>"' end
		+ '</td></tr></table></div>'
		as  htmlValue
	from ctl_doc with(nolock) 		

union
	
	select 
		id as idRow , 
		ID AS idDoc ,
		'footer' as tipo ,			
		 '<!DOCTYPE html>
		<html>
			<head/>
			<style>       .contenitore_stampa    {          margin: 0 auto;     width:800px ;     }        
				table     {     width: 100%;               }       
			 </style>  
		<div class="contenitore_stampa" >
			  <center>
				<body style="font-family: ''arial''; font-size: 14px">
					<table style="font-size:9pt;width: 100%; height:40px; border-top:1px solid #333;border-bottom:1px solid #333;">				 
					   <tr>
						   <td style="width: 90%; height:40px; vertical-align:center; text-align:center"><b>
						   Domanda di Ammissione all''Albo Prestatori di Servizi di Architettura e Ingegneria</b><br/>
						   Pagina <span style=" font-weight: bold">&p;</span> di <span style="font-size: 16px; color: #333; font-weight: bold">&P;</span> pagine</td>
					   </tr>
				   </table>
			   </body>
			</center>
		</div>
		</html>'  as  htmlValue

	from ctl_doc with(nolock)


GO
