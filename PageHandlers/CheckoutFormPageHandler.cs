using Dtm.Framework.ClientSites.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace KLEVACUBE.PageHandlers
{
    public class CheckoutFormPageHandler : PageHandler
    {

        public override void PostProcessPageActions()
        {
            if (DtmContext.OrderId > 0 && DtmContext.Order != null)
            {
                DtmContext.Order.AddOrderCode(DtmContext.Order.OrderID.ToString(), "ShopifyOrderTags");
            }
        }

    }
}