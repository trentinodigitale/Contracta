using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

using System.Threading.Tasks;

namespace FTM.Cloud.Services.DTO
{
    
    public partial class ProfiloutentiDTO 
    {

        
        
        
        public Int64 Si07Id { get; set; }

        
        
        public String Si07Nome { get; set; }

        
        
        public String Si07Cognome { get; set; }

        
        
        public String Si07Email { get; set; }

        
        
        public String Si07Datainserimento { get; set; }

        
        
        public String Si07Utenteinserimento { get; set; }

        
        
        public Boolean? Si07Deleted { get; set; }
        
    }
}

