<%@ Page Language="C#" MasterPageFile="~/VersionViews/Views/Layouts/InternalLayout.master" Inherits="System.Web.Mvc.ViewPage<ClientSiteViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="KLEVACUBE.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script async src="https://cdn-static.okendo.io/reviews-widget-plus/js/okendo-reviews.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<main aria-labelledby="main-title" class="view reviews section">
    <div id="main" class="view__anchor"></div>
    <article class="view__in section__in">
        <div class="section__block">
            <h1 id="main-title" class="reviews__title">Real Customer Reviews</h1>
            <div class="reviews__reviews">
                <div>
                    <div classname="okendo-widget-container">
                        <div
                            data-oke-widget
                            data-oke-reviews-product-id="shopify-7580397928630">
                        </div>
                    </div> 
                </div>
                
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        if (window.okeWidgetApi) {
                            window.okeWidgetApi.initAllWidgets();
                        } else {
                            setTimeout(function () { window.okeWidgetApi.initAllWidgets(); }, 1000);
                        }
    
                    });
                </script>
            </div>
        </div>
    </article>
</main>

</asp:Content>