using System.ComponentModel.DataAnnotations;
using System.Runtime.InteropServices;
using Xunit.Sdk;

namespace eProcurementNext.WebAPI.Model
{
    public class UserHistoryModel
    {
		//Format dd/MM/yyyy hh:mm:ss
		const string regexDate = @"^([1-9]|([012][0-9])|(3[01]))\/([0]{0,1}[1-9]|1[012])\/\d\d\d\d\s([0-1]?[0-9]|2?[0-3]):([0-5]\d):([0-5]\d)$";

		[DataType(DataType.Url, ErrorMessage = "Link not validated as Url"),
			StringLength(1000, ErrorMessage = "Please do not enter values over 1000 characters")]
        public string Link { get; set; }

		[DataType(DataType.Text, ErrorMessage = "Title not validated as Text"),
			StringLength(150, ErrorMessage = "Please do not enter values over 150 characters")]
		public string Title { get; set; }

		[DataType(DataType.Text, ErrorMessage = "Breadcrumb not validated as Text"),
			StringLength(350, ErrorMessage = "Please do not enter values over 350 characters")]
		public string Breadcrumb { get; set; }

		[RegularExpression(regexDate, ErrorMessage = "Date is not valid.")]
		public string Date { get; set; }
		public bool IsFavorite { get; set; }
		public bool IsBookmark { get; set; }


    }
}
