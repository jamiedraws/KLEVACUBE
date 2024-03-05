using Dtm.Framework.ClientSites.Web;
using Dtm.Framework.Services.DtmApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace KLEVACUBE.PageHandlers
{
    public class ConfirmationPageHandler : PageHandler
    {
        private const string CONFIRMATION_EMAIL_ADD_DATE_ORDER_CODE = "ConfirmationEmailMessageAddDate";
        public override void PageLoaded(HttpRequestBase request, HttpResponseBase response)
        {
            base.PageLoaded(request, response);

            if(DtmContext.Order != null && DtmContext.Order.OrderStatusId == 3)
            {
                var confEmailMessageAddDate = DtmContext.Order.Codes[CONFIRMATION_EMAIL_ADD_DATE_ORDER_CODE].Code;

                if(string.IsNullOrWhiteSpace(confEmailMessageAddDate))
                {
                    var confirmationSql = string.Format("SELECT COUNT(*) FROM DtmInternational.dbo.Orders WHERE OrderId = {0} AND ConfirmationEmailSent <> 1", DtmContext.OrderId);
                    var hasSentConfirmationEmail = Context.ExecuteQuery<int>(confirmationSql).FirstOrDefault() <= 0;
                    if (!hasSentConfirmationEmail)
                    {
                        var dtmAPiClient = new DtmApiClient();
                        dtmAPiClient.PostWorkerAsync("ConfirmationEmail", "SendConfirmationMessages", new
                        {
                            OrderIds = DtmContext.Order.OrderID.ToString()
                        });

                        DtmContext.Order.AddOrderCode(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss"), "ConfirmationEmailMessageAddDate");
                    }
                }
            }

           
        }

    }
}