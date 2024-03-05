<%@ Page Language="C#" MasterPageFile="~/VersionViews/Views/Layouts/InternalLayout.master" Inherits="System.Web.Mvc.ViewPage<ClientSiteViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="KLEVACUBE.UIComponents" %>
<%@ Import Namespace="KLEVACUBE.Models" %>
<%@ Import Namespace="KLEVACUBE.Text" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<main aria-labelledby="main-title" class="view content content--sub-page section">
    <div id="main" class="view__anchor"></div>
    <article class="view__in content__in section__in">
        <div class="section__block content__text">
            <h1 id="main-title" class="content__title">Frequently Asked Questions</h1>
            <%
                Response.Write(FAQAccordion.CreateCategorySection(new FAQSection
                {
                    Code = "DEF",
                    Id = "Default",
                    Name = "Default"
                }, ProductFAQ.General, FAQAccordion.HTMLContainer));
            %>
        </div>
    </article>
</main>

</asp:Content>