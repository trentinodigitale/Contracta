using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

using System.Threading.Tasks;

namespace FTM.Cloud.Services.DTO
{
	
	public partial class ValidazioneDTO 
	{

		
		public String KeyVi44Validazione { get; set; }		
		
		public String Vi44Descrizione { get; set; }		
		public Boolean Vi44Flgvalido { get; set; }

	}
}

