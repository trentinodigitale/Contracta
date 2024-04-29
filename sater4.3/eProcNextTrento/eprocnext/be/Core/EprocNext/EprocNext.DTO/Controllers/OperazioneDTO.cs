using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

using System.Threading.Tasks;

namespace FTM.Cloud.Services.DTO
{
    
    public partial class OperazioneDTO 
    {

        
        
        
        public String KeyVi01Operazione { get; set; }

        
        
        public String Vi01Descrizione { get; set; }

        
        
        public Boolean Vi01Flgdocumento { get; set; }

        
        
        public Int16 Vi01Ordinamento { get; set; }

        
        
        public Boolean Vi01Tipomovcoll { get; set; }

        
        
        public Boolean Vi01Flgfascette { get; set; }

        
        
        public Boolean Vi01Flgvalido { get; set; }
        
    }
}

