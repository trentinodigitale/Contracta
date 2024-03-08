using System;

namespace FTM.Cloud.Services.DTO
{
    public partial class IdentityusersDTO 
    {
        public String Si10Id { get; set; }
        public Int64? Si10Idprofiloutentisi07 { get; set; }
        public String Si10Username { get; set; }
        public Int32 Si10Accessfailedcount { get; set; }
        public String Si10Concurrencystamp { get; set; }
        public String Si10Email { get; set; }
        public Boolean Si10Emailconfirmed { get; set; }
        public Boolean Si10Lockoutenabled { get; set; }
        public Object Si10Lockoutend { get; set; }
        public String Si10Normalizedemail { get; set; }
        public String Si10Normalizedusername { get; set; }
        public String S10Passwordhash { get; set; }
        public String Si10Phonenumber { get; set; }
        public Boolean Si10Phonenumberconfirmed { get; set; }
        public String Si10Securitystamp { get; set; }
        public Boolean Si10Twofactorenabled { get; set; }
        public String Si10Firstname { get; set; }
        public String Si10Lastname { get; set; }
        public DateTime? Si10Lastaccess { get; set; }
        public String Si10Lastip { get; set; }
    }
}

