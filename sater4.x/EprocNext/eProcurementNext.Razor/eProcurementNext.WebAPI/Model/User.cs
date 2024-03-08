using System.ComponentModel.DataAnnotations;
using Xunit.Sdk;

namespace eProcurementNext.WebAPI.Model
{
    public class User
    {
		[Required(ErrorMessage = "Email required"),
            DataType(DataType.EmailAddress, ErrorMessage = "Email not validated"),
			StringLength(320, ErrorMessage = "Please do not enter values over 320 characters")]
		public string Email { get; set; }

		[Required(ErrorMessage = "Password required"),
            DataType(DataType.Password, ErrorMessage = "Password not validated"),
			StringLength(320, ErrorMessage = "Please do not enter values over 320 characters")]
        public string Password { get; set; }

    }
}
